// lib/features/wallet/screens/withdrawal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/coin_chip.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../../../core/services/pwa_service.dart';
import '../wallet_provider.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _amountCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _coins = 100;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = '100';
    _amountCtrl.addListener(() {
      final val = int.tryParse(_amountCtrl.text) ?? 100;
      setState(() => _coins = val);
    });
    _upiCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    final coins = int.tryParse(_amountCtrl.text) ?? 0;
    return coins >= AppConstants.minWithdrawalCoins &&
        Validators.upiId(_upiCtrl.text.trim()) == null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();

    final coins = int.parse(_amountCtrl.text);
    final ok = await ref
        .read(withdrawalProvider.notifier)
        .initiate(coinAmount: coins, upiId: _upiCtrl.text.trim());

    if (!mounted) return;
    if (ok) {
      HapticFeedback.heavyImpact();
      setState(() => _success = true);
    } else {
      final err = ref.read(withdrawalProvider).error?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Withdrawal failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawState = ref.watch(withdrawalProvider);
    final walletAsync = ref.watch(walletStreamProvider);
    final balance = walletAsync.value?.coinBalance ?? 0;
    final isLoading = withdrawState is AsyncLoading;

    if (_success) return _SuccessScreen();

    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw', style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Available balance ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacityNew(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withOpacityNew(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available to withdraw',
                          style: AppTypography.labelM(
                            color: AppColors.success.withOpacityNew(0.8),
                          ),
                        ),
                        CoinAmount(
                          amount: balance,
                          size: CoinAmountSize.large,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              // ── Amount input ─────────────────────────────────────────────
              Text(
                'Amount to withdraw',
                style: AppTypography.labelL(),
              ).animate(delay: 100.ms).fadeIn(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTypography.displayS(),
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null || val < AppConstants.minWithdrawalCoins) {
                    return 'Minimum ${AppConstants.minWithdrawalCoins} coins';
                  }
                  if (val > balance) return 'Exceeds balance';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: '100',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text('⚡', style: const TextStyle(fontSize: 20)),
                  ),
                  suffixText: '= ${Formatters.rupees(_coins)}',
                  suffixStyle: AppTypography.labelM(color: AppColors.success),
                ),
              ).animate(delay: 200.ms).fadeIn(),

              // Quick amount buttons
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [100, 250, 500, 1000].map((amt) {
                  return GestureDetector(
                    onTap: () {
                      if (amt <= balance) {
                        _amountCtrl.text = amt.toString();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _coins == amt
                            ? AppColors.primary.withOpacityNew(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: _coins == amt
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        '$amt SC',
                        style: AppTypography.labelM(
                          color: _coins == amt ? AppColors.primary : null,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate(delay: 250.ms).fadeIn(),

              const SizedBox(height: 24),

              // ── UPI ID ──────────────────────────────────────────────────
              Text(
                'Your UPI ID',
                style: AppTypography.labelL(),
              ).animate(delay: 300.ms).fadeIn(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _upiCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: Validators.upiId,
                decoration: const InputDecoration(
                  labelText: 'UPI ID',
                  hintText: 'yourname@bank',
                  prefixIcon: Icon(Icons.account_balance_rounded),
                ),
              ).animate(delay: 400.ms).fadeIn(),

              const SizedBox(height: 8),

              // ── Summary ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacityNew(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacityNew(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Coins',
                      value: Formatters.coins(_coins),
                    ),
                    _SummaryRow(
                      label: 'You receive',
                      value: Formatters.rupees(_coins),
                      highlight: true,
                    ),
                    _SummaryRow(
                      label: 'Arrives in',
                      value: '1-2 business days',
                    ),
                  ],
                ),
              ).animate(delay: 450.ms).fadeIn(),

              const SizedBox(height: 32),

              // ── Minimum note ─────────────────────────────────────────────
              Center(
                child: Text(
                  'Minimum withdrawal: ${AppConstants.minWithdrawalCoins} coins (= ₹${AppConstants.minWithdrawalCoins})',
                  style: AppTypography.bodyS(color: AppColors.darkTextMuted),
                ),
              ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: 12),

              SortoButton(
                label: 'Withdraw ${Formatters.rupees(_coins)}',
                isLoading: isLoading,
                onPressed: (_isValid && !isLoading) ? _submit : null,
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: AppTypography.bodyM()),
          const Spacer(),
          Text(
            value,
            style: highlight
                ? AppTypography.labelL(color: AppColors.success)
                : AppTypography.labelM(),
          ),
        ],
      ),
    );
  }
}

class _SuccessScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 72),
                ).animate().scale(curve: Curves.elasticOut, duration: 700.ms),
                const SizedBox(height: 24),
                Text('Withdrawal requested!', style: AppTypography.displayS())
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0)
                    .callback(
                      callback: (controller) {
                        // Trigger PWA banner for first withdrawal
                        ref
                            .read(pwaServiceProvider)
                            .showInstallBanner(
                              context,
                              bannerContext: PwaBannerContext.firstWithdrawal,
                            );
                      },
                    ),
                const SizedBox(height: 12),
                Text(
                  'Your UPI payment will arrive in 1–2 business days.',
                  style: AppTypography.bodyL(),
                  textAlign: TextAlign.center,
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 40),
                SortoButton(
                      label: 'Back to Wallet',
                      onPressed: () => context.go(Routes.wallet),
                    )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
