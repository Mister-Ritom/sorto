// lib/features/wallet/payment_provider.dart
import 'dart:developer' as dev;
//
// Riverpod glue between the UI and PaymentService.
// RevenueCat is only initialised on Android/iOS — never on Web/Desktop.
// The UI watches revenueCatOfferingsProvider to show live store prices.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show BuildContext, WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;
import '../../core/constants/api_constants.dart';
import '../../core/constants/coin_tiers.dart';
import '../../core/services/payment_service.dart';

// ─── Debug Overrides ──────────────────────────────────────────────────────────
// Only active in kDebugMode. Allows testing international pricing/flows.

final debugCountryOverrideProvider = StateProvider<String?>((ref) => null);

enum PaymentMethodOverride { none, revenueCat, razorpay }

final debugPaymentOverrideProvider = StateProvider<PaymentMethodOverride>(
  (ref) => PaymentMethodOverride.none,
);

// ─── RevenueCat initialisation + offerings ────────────────────────────────────
// Returns null on Web/Desktop or if the SDK is not available.
// On mobile, initialises with the correct platform key and fetches offerings.

final revenueCatOfferingsProvider = FutureProvider<Offerings?>((ref) async {
  if (kIsWeb) return null;

  try {
    final String rcKey;
    if (Platform.isIOS || Platform.isMacOS) {
      rcKey = ApiConstants.revenuecatAppleKey;
    } else if (Platform.isAndroid) {
      rcKey = ApiConstants.revenuecatGoogleKey;
    } else {
      return null; // Windows / Linux — use Razorpay
    }

    await Purchases.configure(PurchasesConfiguration(rcKey));
    return await Purchases.getOfferings();
  } catch (e, st) {
    dev.log('RevenueCat initialization or offering fetch failed', 
        error: e, stackTrace: st, name: 'PaymentProvider');
    return null; // SDK unavailable or error — fall back to Razorpay
  }
});

// ─── Razorpay Price Previews (Multi-Currency) ─────────────────────────────────
// Fetches accurate exchange-rate converted prices from the backend.
final razorpayPricesProvider = FutureProvider<Map<int, String>>((ref) async {
  try {
    final override = ref.watch(debugCountryOverrideProvider);
    final countryCode =
        override ??
        WidgetsBinding.instance.platformDispatcher.locale.countryCode ??
        'IN';

    final response = await Supabase.instance.client.functions.invoke(
      'create-razorpay-order',
      body: {'get_prices': true, 'country_code': countryCode},
    );

    final List tiers = response.data['tiers'];
    final Map<int, String> priceMap = {};

    for (final t in tiers) {
      final coins = t['coins'] as int;
      final amount = t['amount'];
      final currency = t['currency'] as String;

      if (currency == 'INR') {
        priceMap[coins] = '₹$amount';
      } else {
        priceMap[coins] = '$currency $amount';
      }
    }
    return priceMap;
  } catch (e, st) {
    dev.log('Failed to fetch Razorpay prices from backend', 
        error: e, stackTrace: st, name: 'PaymentProvider');
    return {};
  }
});

// ─── Payment state ────────────────────────────────────────────────────────────

class PaymentState {
  final bool isLoading;
  final PaymentResult? lastResult;

  const PaymentState({this.isLoading = false, this.lastResult});

  PaymentState copyWith({bool? isLoading, PaymentResult? lastResult}) =>
      PaymentState(
        isLoading: isLoading ?? this.isLoading,
        lastResult: lastResult ?? this.lastResult,
      );
}

// ─── Payment notifier ─────────────────────────────────────────────────────────

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  PaymentService get _service => PaymentService(Supabase.instance.client);

  /// The only method the UI calls. Never put payment logic in build() / onPressed.
  Future<PaymentResult> purchaseTier(
    CoinTier tier,
    BuildContext context,
  ) async {
    state = state.copyWith(isLoading: true);

    final countryOverride = ref.read(debugCountryOverrideProvider);
    final providerOverride = ref.read(debugPaymentOverrideProvider);

    final result = await _service.purchaseTier(
      tier,
      context,
      countryCodeOverride: countryOverride,
      paymentMethodOverride: providerOverride == PaymentMethodOverride.none
          ? null
          : providerOverride.name,
    );
    state = state.copyWith(isLoading: false, lastResult: result);
    return result;
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);
