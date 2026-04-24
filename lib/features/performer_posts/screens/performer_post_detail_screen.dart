// lib/features/performer_posts/screens/performer_post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/performer_post.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/widgets/coin_chip.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../performer_posts_provider.dart';

class PerformerPostDetailScreen extends ConsumerWidget {
  const PerformerPostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(performerPostDetailProvider(postId));
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Creator Post', style: AppTypography.headingM()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
      body: postAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (post) {
          if (post == null) {
            return Center(
              child: Text('Post not found', style: AppTypography.headingS()),
            );
          }

          final isOwn = user?.id == post.performerId;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Performer header ───────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradientDiagonal,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (post.performerUsername ?? '?')[0].toUpperCase(),
                          style: AppTypography.headingM(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${post.performerUsername ?? 'unknown'}',
                            style: AppTypography.labelL(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                          Text(
                            'Creator · ${post.category}',
                            style: AppTypography.bodyS(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        post.category,
                        style:
                            AppTypography.labelM(color: AppColors.primary),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 20),

                // ── Big quote card ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradientDiagonal,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${post.title}"',
                        style: AppTypography.headingL(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CoinAmount(
                            amount: post.askingPrice,
                            size: CoinAmountSize.large,
                            color: Colors.white,
                          ),
                          const Spacer(),
                          if (post.deadline != null)
                            Text(
                              'Until ${Formatters.shortDate(post.deadline!)}',
                              style: AppTypography.labelM(
                                  color: Colors.white70),
                            ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 20),

                // ── Description ────────────────────────────────────────────
                Text('What they\u2019ll do',
                    style: AppTypography.labelM(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary))
                    .animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 8),
                Text(post.description,
                    style: AppTypography.bodyL(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary))
                    .animate(delay: 250.ms).fadeIn(),

                const SizedBox(height: 20),

                // ── Funders count ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkCardBorder
                          : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🤝', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${post.funders} poster${post.funders == 1 ? '' : 's'} have already funded this dare',
                          style: AppTypography.bodyM(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                      CoinAmount(
                        amount: post.totalFunded,
                        size: CoinAmountSize.medium,
                        color: AppColors.coinGold,
                      ),
                    ],
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // ── Fund CTA ──────────────────────────────────────────────
                if (!isOwn && post.status == PerformerPostStatus.open)
                  SortoButton(
                    label: 'Fund this Dare (${Formatters.coins(post.askingPrice)})',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(fundPostProvider.notifier).fund(postId);
                    },
                  ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0)
                else if (isOwn)
                  Center(
                    child: Text(
                      '✅ This is your creator post',
                      style: AppTypography.bodyM(),
                    ).animate(delay: 400.ms).fadeIn(),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
