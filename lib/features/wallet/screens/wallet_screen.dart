// lib/features/wallet/screens/wallet_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/constants/coin_tiers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/widgets/coin_chip.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../payment_provider.dart';
import '../wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletStreamProvider);
    final txAsync = ref.watch(transactionAsyncProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet', style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(walletStreamProvider);
          ref.read(transactionProvider.notifier).loadMore();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Balance card ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: walletAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: SkeletonBox(width: double.infinity, height: 200),
                ),
                error: (e, _) => const SizedBox.shrink(),
                data: (wallet) => _BalanceCard(
                  spendable: wallet?.coinBalance ?? 0,
                  escrowed: wallet?.escrowedBalance ?? 0,
                  pendingWithdrawal: wallet?.pendingWithdrawal ?? 0,
                  onAddCoins: () => _showCoinPicker(context, ref),
                  onWithdraw: () => context.push(Routes.withdrawal),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
              ),
            ),

            if (kDebugMode)
              const SliverToBoxAdapter(
                child: _DebugPaymentTools(),
              ),

            // ── Filter chips ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  children: [
                    _TxnFilter(
                      label: 'All',
                      onTap: () => ref
                          .read(transactionProvider.notifier)
                          .filterType(null),
                    ),
                    _TxnFilter(
                      label: 'Purchases',
                      onTap: () => ref
                          .read(transactionProvider.notifier)
                          .filterType('purchase'),
                    ),
                    _TxnFilter(
                      label: 'Earnings',
                      onTap: () => ref
                          .read(transactionProvider.notifier)
                          .filterType('dare_payout'),
                    ),
                    _TxnFilter(
                      label: 'Dares',
                      onTap: () => ref
                          .read(transactionProvider.notifier)
                          .filterType('dare_escrow'),
                    ),
                    _TxnFilter(
                      label: 'Withdrawals',
                      onTap: () => ref
                          .read(transactionProvider.notifier)
                          .filterType('withdrawal'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Section header ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'Transaction history',
                  style: AppTypography.headingS(),
                ),
              ),
            ),

            // ── Transaction list ──────────────────────────────────────────
            txAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => const TransactionSkeleton(),
                  childCount: 5,
                ),
              ),
              error: (e, _) => const SliverToBoxAdapter(
                child: Center(child: Text('Failed to load transactions')),
              ),
              data: (txns) {
                if (txns.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text(
                              '💳',
                              style: TextStyle(fontSize: 48),
                            ).animate().scale(curve: Curves.elasticOut),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions yet',
                              style: AppTypography.headingS(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Buy coins or post a dare to get started.',
                              style: AppTypography.bodyM(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((ctx, i) {
                    if (i == txns.length) {
                      return TextButton(
                        onPressed: () =>
                            ref.read(transactionProvider.notifier).loadMore(),
                        child: const Text('Load more'),
                      );
                    }
                    return _TransactionRow(
                      txn: txns[i],
                      animationDelay: Duration(milliseconds: i * 40),
                    );
                  }, childCount: txns.length + 1),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─── Coin Picker Sheet ────────────────────────────────────────────────────────
// Shown when the user taps "Add Coins". Lists all kCoinTiers.
// On mobile: displays RevenueCat store price (localised, from SDK).
// On Web/Desktop: displays rupee price (coins == rupees).

void _showCoinPicker(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CoinPickerSheet(ref: ref),
  );
}

class _CoinPickerSheet extends ConsumerWidget {
  const _CoinPickerSheet({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final offeringsAsync = widgetRef.watch(revenueCatOfferingsProvider);
    final paymentState = widgetRef.watch(paymentProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCardBorder
                    : AppColors.lightCardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Text('Add Coins', style: AppTypography.headingM()),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '1 Sorto Coin = ₹1. Coins never expire.',
                style: AppTypography.bodyS(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: kCoinTiers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final tier = kCoinTiers[i];

                  // Determine price label:
                  // Mobile → try to get store price from RevenueCat package
                  // Web/Desktop or RC unavailable → use accurate Razorpay preview
                  String priceLabel = tier.razorpayPriceLabel;
                  if (!kIsWeb) {
                    final offerings = offeringsAsync.value;
                    if (offerings?.current != null) {
                      try {
                        final pkg = offerings!.current!.availablePackages
                            .firstWhere(
                              (p) => p.identifier == tier.revenueCatId,
                            );
                        priceLabel = pkg.storeProduct.priceString;
                      } catch (_) {}
                    }
                  }

                  // If still using fallback label, try to get the accurate one from the backend
                  if (priceLabel == tier.razorpayPriceLabel) {
                    final accuratePricesAsync = widgetRef.watch(razorpayPricesProvider);
                    
                    priceLabel = accuratePricesAsync.when(
                      data: (prices) => prices[tier.coins] ?? tier.razorpayPriceLabel,
                      loading: () => 'Loading...',
                      error: (_, __) => tier.razorpayPriceLabel,
                    );
                  }

                  return _TierCard(
                    tier: tier,
                    priceLabel: priceLabel,
                    isLoading: paymentState.isLoading,
                    onTap: () async {
                      final result = await widgetRef
                          .read(paymentProvider.notifier)
                          .purchaseTier(tier, context);

                      if (!context.mounted) return;
                      switch (result) {
                        case PaymentSuccess(:final coinsAdded):
                          Navigator.of(context).pop(); // Force close sheet
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('⚡ $coinsAdded coins added!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          // Refresh everything
                          widgetRef.invalidate(walletStreamProvider);
                          widgetRef.read(transactionProvider.notifier).load(refresh: true);
                        case PaymentCancelled():
                          break;
                        case PaymentFailed(:final reason):
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Payment failed: $reason'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.priceLabel,
    required this.isLoading,
    required this.onTap,
  });
  final CoinTier tier;
  final String priceLabel;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.darkCardBorder
                  : AppColors.lightCardBorder,
            ),
          ),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tier.label, style: AppTypography.headingS()),
                    Text(
                      '${tier.coins} Sorto Coins',
                      style: AppTypography.bodyS(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradientDiagonal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priceLabel,
                  style: AppTypography.labelL(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.spendable,
    required this.escrowed,
    required this.pendingWithdrawal,
    required this.onAddCoins,
    required this.onWithdraw,
  });

  final int spendable;
  final int escrowed;
  final int pendingWithdrawal;
  final VoidCallback onAddCoins;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientDiagonal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spendable Balance',
                    style: AppTypography.labelM(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  CoinAmount(
                    amount: spendable,
                    size: CoinAmountSize.xlarge,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '≈ ${Formatters.rupees(spendable)}',
                    style: AppTypography.bodyM(color: Colors.white70),
                  ),
                  if (escrowed > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '🔒 ${Formatters.coins(escrowed)} in escrow',
                      style: AppTypography.bodyS(color: Colors.white60),
                    ),
                  ],
                  if (pendingWithdrawal > 0) ...[
                    Text(
                      '⏳ ${Formatters.coins(pendingWithdrawal)} pending withdrawal',
                      style: AppTypography.bodyS(color: Colors.white60),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAddCoins,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Coins'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: spendable >= 100 ? onWithdraw : null,
                          icon: const Icon(
                            Icons.arrow_upward_rounded,
                            size: 18,
                          ),
                          label: const Text('Withdraw'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxnFilter extends StatelessWidget {
  const _TxnFilter({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(label, style: AppTypography.labelM()),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.txn,
    this.animationDelay = Duration.zero,
  });
  final SortoTransaction txn;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.type.isCredit;
    final color = isCredit ? AppColors.success : AppColors.error;
    final amountStr =
        '${isCredit ? '+' : '-'}${Formatters.coins(txn.coinAmount)}';

    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkCard
                : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCardBorder
                  : AppColors.lightCardBorder,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    txn.type.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn.type.label, style: AppTypography.labelL()),
                    if (txn.description != null)
                      Text(
                        txn.description!,
                        style: AppTypography.bodyS(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      Formatters.shortDate(txn.createdAt),
                      style: AppTypography.bodyS(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Text(amountStr, style: AppTypography.labelL(color: color)),
            ],
          ),
        )
        .animate(delay: animationDelay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }
}

class _DebugPaymentTools extends ConsumerWidget {
  const _DebugPaymentTools();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(debugCountryOverrideProvider);
    final method = ref.watch(debugPaymentOverrideProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text('DEBUG OVERRIDES', style: AppTypography.labelS(color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Country', style: AppTypography.bodyS()),
                    DropdownButton<String?>(
                      value: country,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('System Default')),
                        DropdownMenuItem(value: 'IN', child: Text('India (INR)')),
                        DropdownMenuItem(value: 'US', child: Text('USA (USD)')),
                        DropdownMenuItem(value: 'GB', child: Text('UK (GBP)')),
                        DropdownMenuItem(value: 'EU', child: Text('Europe (EUR)')),
                        DropdownMenuItem(value: 'AE', child: Text('UAE (AED)')),
                      ],
                      onChanged: (val) => ref.read(debugCountryOverrideProvider.notifier).state = val,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Method', style: AppTypography.bodyS()),
                    DropdownButton<PaymentMethodOverride>(
                      value: method,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: PaymentMethodOverride.none, child: Text('Default Flow')),
                        DropdownMenuItem(value: PaymentMethodOverride.razorpay, child: Text('Force Razorpay')),
                        DropdownMenuItem(value: PaymentMethodOverride.revenueCat, child: Text('Force Store')),
                      ],
                      onChanged: (val) => ref.read(debugPaymentOverrideProvider.notifier).state = val!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
