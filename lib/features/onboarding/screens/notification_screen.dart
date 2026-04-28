// lib/features/onboarding/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/sorto_button.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  static const _benefits = [
    ('⚡', 'Know the instant your dare is claimed'),
    ('💰', 'Get notified when your proof is approved'),
    ('🔔', 'See new dares that match your interests'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── BG Gradient ─────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0E0118), AppColors.darkBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ── Decorative split screen illustration ────────────────────────
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            height: 280,
            child: _SplitScreenIllustration(),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(flex: 5),

                  Text(
                    "Don't miss a\nsingle coin.",
                    style: AppTypography.displayM(
                        color: AppColors.darkTextPrimary),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 28),

                  // Benefits
                  ..._benefits.asMap().entries.map((entry) {
                    final i = entry.key;
                    final (emoji, text) = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacityNew(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                                child: Text(emoji,
                                    style:
                                        const TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              text,
                              style: AppTypography.bodyM(
                                  color: AppColors.darkTextPrimary),
                            ),
                          ),
                        ],
                      )
                          .animate(delay: (400 + i * 150).ms)
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.2, end: 0),
                    );
                  }),

                  const SizedBox(height: 32),

                  SortoButton(
                    label: 'Yes, notify me →',
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      // Request OS permissions
                      ref
                          .read(onboardingProvider.notifier)
                          .setNotificationsGranted(true);
                      if (context.mounted) {
                        context.go(Routes.walletIntroOnboarding);
                      }
                    },
                  )
                      .animate(delay: 900.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => context.go(Routes.walletIntroOnboarding),
                    child: Text(
                      'Not now',
                      style: AppTypography.bodyS(
                          color: AppColors.darkTextMuted),
                    ).animate(delay: 1100.ms).fadeIn(duration: 300.ms),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitScreenIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Left: Poster
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacityNew(0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                border: Border.all(
                    color: AppColors.accent.withOpacityNew(0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👀', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text('Poster',
                        style: AppTypography.labelM(
                            color: AppColors.accent)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0),
          ),

          // Center: Verdict
          Container(
            width: 80,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'APPROVED',
                  style: AppTypography.labelS(color: Colors.white),
                ),
              ),
            )
                .animate(delay: 400.ms)
                .scaleXY(begin: 0.7, end: 1.0, curve: Curves.elasticOut)
                .fadeIn(),
          ),

          // Right: Performer
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacityNew(0.15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(
                    color: AppColors.primary.withOpacityNew(0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎬', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text('Performer',
                        style: AppTypography.labelM(
                            color: AppColors.primary)),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.3, end: 0),
          ),
        ],
      ),
    );
  }
}
