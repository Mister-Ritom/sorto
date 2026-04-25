// lib/core/services/payment_service.dart
//
// Routes coin purchases:
//   Android/iOS → RevenueCat (prices come from the store via getOfferings())
//               → falls back to Razorpay if offerings are null/empty (sideloaded)
//   Web/Desktop → Razorpay directly
//
// The Flutter app NEVER converts currency or hardcodes prices.
// RevenueCat prices come from the SDK. Razorpay prices come from the Edge Function.
// Coins are only credited after server-side verification.

import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show BuildContext, WidgetsBinding;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/api_constants.dart';
import '../constants/coin_tiers.dart';

const _tag = 'PaymentService';
void _log(String msg) => dev.log(msg, name: _tag);
void _logError(String msg, Object err, StackTrace st) =>
    dev.log(msg, name: _tag, error: err, stackTrace: st);

// ─── Result ───────────────────────────────────────────────────────────────────

sealed class PaymentResult {
  const PaymentResult();
}

class PaymentSuccess extends PaymentResult {
  final int coinsAdded;
  const PaymentSuccess(this.coinsAdded);
}

class PaymentCancelled extends PaymentResult {
  const PaymentCancelled();
}

class PaymentFailed extends PaymentResult {
  final String reason;
  const PaymentFailed(this.reason);
}

// ─── Service ──────────────────────────────────────────────────────────────────

class PaymentService {
  PaymentService(this._supabase);

  final SupabaseClient _supabase;

  /// Primary entry point. Call from a Riverpod notifier, not from build/onPressed.
  Future<PaymentResult> purchaseTier(
    CoinTier tier,
    BuildContext context, {
    String? countryCodeOverride,
    String? paymentMethodOverride,
  }) async {
    if (paymentMethodOverride == 'revenueCat') {
      final rcResult = await _tryRevenueCat(tier);
      if (rcResult != null) return rcResult;
    } else if (paymentMethodOverride == 'razorpay') {
      return _razorpay(tier, context, countryCodeOverride: countryCodeOverride);
    }

    if (!kIsWeb) {
      // Android / iOS → try RevenueCat first
      final rcResult = await _tryRevenueCat(tier);
      if (rcResult != null) return rcResult;
      // RevenueCat returned null → offerings missing (sideloaded), fall through
    }
    // Web / Desktop — or RevenueCat unavailable — use Razorpay
    return _razorpay(tier, context, countryCodeOverride: countryCodeOverride);
  }

  // ── RevenueCat ─────────────────────────────────────────────────────────────
  // Pricing is owned by the App Store / Play Store.
  // The SDK's getOfferings() returns packages with their store prices.
  // We match by package.identifier (e.g. 'coins_100') to know which tier it is.

  Future<PaymentResult?> _tryRevenueCat(CoinTier tier) async {
    Offerings? offerings;
    try {
      offerings = await Purchases.getOfferings();
    } catch (e, st) {
      _logError('RevenueCat getOfferings failed — falling back to Razorpay', e, st);
      return null;
    }

    if (offerings.current == null || offerings.current!.availablePackages.isEmpty) {
      return null; // Sideloaded or no offerings configured — fall back silently
    }

    // Find the package matching this tier's product identifier
    Package? package;
    try {
      package = offerings.current!.availablePackages.firstWhere(
        (p) => p.identifier == tier.revenueCatId,
      );
    } catch (_) {
      return null; // This specific tier not in offerings — fall back
    }

    try {
      await Purchases.purchasePackage(package);
      _log('RevenueCat purchase succeeded for ${tier.revenueCatId}');
      return PaymentSuccess(tier.coins);
    } on PurchasesError catch (e, st) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        _log('RevenueCat purchase cancelled by user');
        return const PaymentCancelled();
      }
      _logError('RevenueCat purchase error — falling back to Razorpay', e, st);
      return null;
    }
  }

  // ── Razorpay ───────────────────────────────────────────────────────────────
  // Step 1: Edge Function creates a Razorpay order server-side.
  // Step 2: Flutter opens the Razorpay checkout with the returned order_id.
  // Step 3: On success, Edge Function verifies the signature and credits coins.
  // Flutter never converts rupees → paise; the Edge Function does that.

  Future<PaymentResult> _razorpay(
    CoinTier tier,
    BuildContext context, {
    String? countryCodeOverride,
  }) async {
    _log('Starting Razorpay flow for ${tier.coins} coins');
    // Step 1 — create server-side order
    final Map<String, dynamic> orderData;
    try {
      // Get country code without permissions
      final countryCode = countryCodeOverride ??
          WidgetsBinding.instance.platformDispatcher.locale.countryCode ??
          'IN';

      final res = await _supabase.functions.invoke(
        'create-razorpay-order',
        body: {
          'coins': tier.coins,
          'amount': tier.priceInRupees, // We send the raw units
          'country_code': countryCode,
        },
      );
      _log('create-razorpay-order raw response: ${res.data}');
      final data = res.data as Map<String, dynamic>?;
      if (data == null || data['order_id'] == null) {
        _log('ERROR: order_id missing in response: $data');
        return const PaymentFailed('Failed to create payment order');
      }
      orderData = data;
      _log('Order created: ${orderData['order_id']}');
    } catch (e, st) {
      _logError('create-razorpay-order invocation failed', e, st);
      return PaymentFailed('Order creation failed: $e');
    }

    // Step 2 & 3 — open checkout, await result
    return _openCheckout(
      orderId: orderData['order_id'] as String,
      // amount comes back from server in paise (as Razorpay requires for display)
      amountFromServer: orderData['amount'] as int,
      tier: tier,
      context: context,
    );
  }

  Future<PaymentResult> _openCheckout({
    required String orderId,
    required int amountFromServer,
    required CoinTier tier,
    required BuildContext context,
  }) {
    final completer = Completer<PaymentResult>();
    final razorpay = Razorpay();

    void cleanup() => razorpay.clear();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse res) async {
      _log('Razorpay payment success — payment_id: ${res.paymentId}, order_id: ${res.orderId}');
      cleanup();
      try {
        _log('Invoking verify-razorpay-payment...');
        final verifyRes = await _supabase.functions.invoke(
          'verify-razorpay-payment',
          body: {
            'order_id': res.orderId,
            'payment_id': res.paymentId,
            'signature': res.signature,
            'coins': tier.coins,
          },
        );
        _log('verify-razorpay-payment raw response: ${verifyRes.data}');
        final data = verifyRes.data as Map<String, dynamic>?;
        if (data != null && data['success'] == true) {
          _log('Verification succeeded — crediting ${tier.coins} coins');
          completer.complete(PaymentSuccess(tier.coins));
        } else {
          _log('ERROR: Verification returned unexpected data: $data');
          completer.complete(const PaymentFailed('Payment verification failed'));
        }
      } catch (e, st) {
        _logError('verify-razorpay-payment invocation threw an exception', e, st);
        completer.complete(PaymentFailed('Verification error: $e'));
      }
    });

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse res) {
      _log('Razorpay payment error — code: ${res.code}, message: ${res.message}');
      cleanup();
      if (res.code == 2) {
        _log('User cancelled the payment');
        completer.complete(const PaymentCancelled());
      } else {
        completer.complete(PaymentFailed(res.message ?? 'Payment failed'));
      }
    });

    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse _) {
      // External wallet — payment may complete asynchronously via webhook
      cleanup();
      completer.complete(const PaymentCancelled());
    });

    razorpay.open(
      {
        'key': ApiConstants.razorpayKeyId,
        'amount': amountFromServer, // paise, comes from server
        'order_id': orderId,
        'currency': 'INR',
        'name': 'Sorto',
        'description': '${tier.coins} Sorto Coins',
        'theme': {'color': '#7C3AED'},
      },
      context: context,
    );

    return completer.future;
  }
}
