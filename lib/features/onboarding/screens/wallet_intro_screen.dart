// lib/features/onboarding/screens/wallet_intro_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/sorto_button.dart';

class WalletIntroScreen extends StatelessWidget {
  const WalletIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── BG ──────────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D0A00), AppColors.darkBackground],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Coin glow decoration ─────────────────────────────────────────
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text('⚡', style: TextStyle(fontSize: 80))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.1, 1.1),
                    duration: 2000.ms,
                  )
                  .then()
                  .custom(
                    duration: 0.ms,
                    builder: (ctx, val, child) => Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.coinGold.withOpacity(0.4 * val),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 180),

                    Text(
                          'Your coins.\nYour rules.',
                          style: AppTypography.displayM(
                            color: AppColors.darkTextPrimary,
                          ),
                        )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 32),

                    // Stat cards
                    ..._statCards.asMap().entries.map((entry) {
                      final i = entry.key;
                      final card = entry.value;
                      return _WalletStatCard(
                            emoji: card.$1,
                            title: card.$2,
                            value: card.$3,
                            subtitle: card.$4,
                            color: card.$5,
                          )
                          .animate(delay: (400 + i * 150).ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.3, end: 0);
                    }),

                    const SizedBox(height: 16),

                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.coinGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.coinGold.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '1 SortCoin = ₹1 real value. Always.',
                          style: AppTypography.labelM(
                            color: AppColors.coinGold,
                          ),
                        ),
                      ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
                    ),

                    // const Spacer(),
                    SortoButton(
                          label: "Got it. Let's start →",
                          onPressed: () => context.go(Routes.launchOnboarding),
                        )
                        .animate(delay: 1100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _statCards = [
    (
      '💳',
      'Buy coins',
      '₹100 → 80 SortCoins',
      'Top up instantly',
      AppColors.primary,
    ),
    (
      '⚡',
      'Earn coins',
      'Complete → coins in wallet',
      'Dare and win',
      AppColors.accent,
    ),
    (
      '🏦',
      'Cash out',
      '100 coins → ₹100 UPI',
      'Withdraw anytime',
      AppColors.success,
    ),
  ];
}

class _WalletStatCard extends StatelessWidget {
  const _WalletStatCard({
    required this.emoji,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String emoji;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelL(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.headingS(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.bodyS(color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
