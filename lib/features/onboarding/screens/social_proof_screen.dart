// lib/features/onboarding/screens/social_proof_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/sorto_button.dart';

class SocialProofScreen extends StatelessWidget {
  const SocialProofScreen({super.key});

  static const _testimonials = [
    ('Priya, Mumbai', 'Earned ₹3,200 in my first week'),
    ('Arjun, Delhi', 'My dare got 47 performers in 2 days'),
    ('Fatima, Hyderabad', 'Easiest side income I\'ve ever had'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Dark gradient BG ────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0015), AppColors.darkBackground],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Community bento grid (decorative) ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Opacity(
              opacity: 0.35,
              child: _BentoGridDecoration(),
            ),
          ),

          // ── Overlay gradient ────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.darkBackground],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // Stats card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.brandGradient.createShader(bounds),
                          child: Text(
                            '₹12,40,000 paid out\nto creators last month.',
                            style: AppTypography.headingL(
                                color: Colors.white),
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
                        const SizedBox(height: 8),
                        Text(
                          '847 dares completed · 2,103 active right now',
                          style: AppTypography.bodyM(
                              color: AppColors.darkTextSecondary),
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),

                  // Testimonials
                  ..._testimonials.asMap().entries.map((entry) {
                    final i = entry.key;
                    final (name, quote) = entry.value;
                    return _TestimonialChip(name: name, quote: quote)
                        .animate(delay: (300 + i * 200).ms)
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.3, end: 0);
                  }),

                  const SizedBox(height: 32),

                  SortoButton(
                    label: "I'm in →",
                    onPressed: () => context.go(Routes.usernameOnboarding),
                  ).animate(delay: 1000.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestimonialChip extends StatelessWidget {
  const _TestimonialChip({required this.name, required this.quote});
  final String name;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '"$quote"',
                    style: AppTypography.bodyM(color: AppColors.darkTextPrimary),
                  ),
                  TextSpan(
                    text: ' — $name',
                    style: AppTypography.bodyS(color: AppColors.darkTextSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoGridDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary.withOpacity(0.6),
      AppColors.accent.withOpacity(0.6),
      AppColors.success.withOpacity(0.6),
      AppColors.primary.withOpacity(0.4),
      AppColors.accent.withOpacity(0.4),
      AppColors.warning.withOpacity(0.4),
    ];
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: List.generate(12, (i) {
        return Container(
          decoration: BoxDecoration(
            color: colors[i % colors.length],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
