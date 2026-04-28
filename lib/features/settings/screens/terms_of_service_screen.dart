// lib/features/settings/screens/terms_of_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.darkBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Terms of Service',
                style: AppTypography.headingM(color: Colors.white),
              ),
              background: Stack(
                children: [
                  Positioned(
                    left: -50,
                    bottom: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withOpacityNew(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection(
                  'Acceptance of Terms',
                  'By using Sorto, you agree to these terms. If you do not agree, please do not use the app.',
                  delay: 100,
                ),
                _buildSection(
                  '1. Account & Content',
                  'You are responsible for your account security. By uploading images or videos as proof, you grant Sorto a non-exclusive license to host and display this content to verify your dares. You must be at least 18 years old to use financial features.',
                  delay: 200,
                ),
                _buildSection(
                  '2. User Conduct',
                  'All dares and proof must be legal, safe, and respectful. We reserve the right to remove any content or accounts that violate our community standards or engage in fraud.',
                  delay: 300,
                ),
                _buildSection(
                  '3. Payments & Earnings',
                  'Earnings are subject to platform fees as disclosed in the app. All payouts are processed through verified third-party payment providers.',
                  delay: 400,
                ),
                _buildSection(
                  '4. Termination',
                  'We may suspend or terminate your access to Sorto at any time for violations of these terms or for legal compliance.',
                  delay: 500,
                ),
                const SizedBox(height: 60),
                Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Text(
                      'Sorto Legal · 2026',
                      style: AppTypography.bodyS(color: AppColors.darkTextMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, {required int delay}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelL(color: AppColors.accent),
          ).animate(delay: delay.ms).fadeIn().slideX(begin: -0.1, end: 0),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTypography.bodyM(color: AppColors.darkTextSecondary),
          ).animate(delay: (delay + 100).ms).fadeIn().slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}
