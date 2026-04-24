// lib/features/onboarding/screens/hook_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/sorto_button.dart';

class HookScreen extends StatelessWidget {
  const HookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient ─────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D0010), Color(0xFF080808)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Glow orbs ──────────────────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Illustration area ───────────────────────────────────────────
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Dare card floating
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradientDiagonal,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🍋 Food Dare',
                        style: AppTypography.labelM(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Eat a lemon without making a face',
                        style: AppTypography.headingM(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '⚡ 240 coins',
                              style:
                                  AppTypography.labelL(color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Claim',
                              style: AppTypography.labelL(
                                  color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOut)
                    .then(delay: 1000.ms)
                    .shimmer(duration: 2000.ms),
              ],
            ),
          ),

          // ── Bottom card ────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                    color: AppColors.darkCardBorder.withOpacity(0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real dares.\nReal money.',
                    style: AppTypography.displayM(
                        color: AppColors.darkTextPrimary),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 12),
                  Text(
                    'Post a challenge. Fund it with coins.\nWatch someone actually do it.',
                    style: AppTypography.bodyL(
                        color: AppColors.darkTextSecondary),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 32),
                  SortoButton(
                    label: "Let's go",
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go(Routes.roleOnboarding),
                  )
                      .animate(delay: 700.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.5, end: 0),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Free to join. No credit card needed.',
                      style: AppTypography.bodyS(
                          color: AppColors.darkTextMuted),
                    ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).slideY(begin: 1, end: 0,
                duration: 500.ms, curve: Curves.easeOutCubic),
          ),
        ],
      ),
    );
  }
}
