// lib/features/settings/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                'Privacy Policy',
                style: AppTypography.headingM(color: Colors.white),
              ),
              background: Stack(
                children: [
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withOpacityNew(0.15),
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
                  'Last Updated: April 2026',
                  'Your privacy is our priority. This policy explains how we collect, use, and protect your data.',
                  delay: 100,
                ),
                _buildSection(
                  '1. Data Collection',
                  'We collect information you provide directly to us (username, email, profile) and transaction data. We also store the images and videos you upload as proof for dares. This media is stored securely on our servers solely to provide the service and is not shared with third parties.',
                  delay: 200,
                ),
                _buildSection(
                  '2. Usage of Information',
                  'Your data is used to maintain Sorto services, process payments, and verify dare completions. We do not use your media or personal info for advertising or marketing outside of Sorto.',
                  delay: 300,
                ),
                _buildSection(
                  '3. Data Sharing',
                  'We do not sell your personal data. Sharing only occurs with essential service providers (like payment processors) or when legally required.',
                  delay: 400,
                ),
                _buildSection(
                  '4. Your Rights',
                  'You can access, update, or delete your account information at any time. For full data deletion requests, you may contact our support team.',
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
            style: AppTypography.labelL(color: AppColors.primary),
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
