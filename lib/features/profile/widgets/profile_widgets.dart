// lib/features/profile/widgets/profile_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/profile.dart';
import '../../../shared/models/dare.dart';
import '../../../shared/models/performer_post.dart';
import '../../../shared/widgets/dare_mode_badge.dart';
import '../../../shared/widgets/sorto_button.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, required this.profile, required this.isOwn, this.onEditTap});
  final Profile profile;
  final bool isOwn;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientDiagonal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacityNew(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                profile.username.isNotEmpty
                    ? profile.username[0].toUpperCase()
                    : '?',
                style: AppTypography.displayS(color: Colors.white),
              ),
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),

          const SizedBox(height: 14),

          // Display name
          Text(
            profile.displayName,
            style: AppTypography.headingL(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          // Username
          Text(
            '@${profile.username}',
            style: AppTypography.bodyM(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

          if (profile.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              profile.bio!,
              style: AppTypography.bodyM(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ],

          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatWidget(label: 'Posted', value: profile.totalDaresPosted),
              const StatDivider(),
              StatWidget(label: 'Completed', value: profile.totalDaresCompleted),
              const StatDivider(),
              StatWidget(label: 'Reputation', value: profile.reputationScore),
            ],
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

          if (isOwn) ...[
            const SizedBox(height: 20),
            SortoButton(
              label: 'Edit Profile',
              variant: SortoButtonVariant.outline,
              height: 44,
              onPressed: onEditTap,
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
          ],
        ],
      ),
    );
  }
}

class StatWidget extends StatelessWidget {
  const StatWidget({super.key, required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value.toString(), style: AppTypography.headingL()),
        Text(label, style: AppTypography.bodyS()),
      ],
    );
  }
}

class StatDivider extends StatelessWidget {
  const StatDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Theme.of(context).dividerColor,
    );
  }
}

class EmptyProfileTab extends StatelessWidget {
  const EmptyProfileTab({
    super.key,
    required this.emoji,
    required this.message,
    required this.hint,
  });
  final String emoji;
  final String message;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48))
              .animate().scale(curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text(message, style: AppTypography.headingS())
              .animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 6),
          Text(hint, style: AppTypography.bodyM())
              .animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }
}

class DareMiniCard extends StatelessWidget {
  const DareMiniCard({super.key, required this.dare, this.showEarnings = false});
  final Dare dare;
  final bool showEarnings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(Routes.dareDetailPath(dare.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dare.title,
                      style: AppTypography.labelL(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      DareModeBadge(mode: dare.dareMode, compact: true),
                      const SizedBox(width: 6),
                      DareStatusBadge(status: dare.status, compact: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (showEarnings)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.coins(dare.performerShare),
                      style: AppTypography.labelL(color: AppColors.success)),
                  Text('earned',
                      style: AppTypography.bodyS(color: AppColors.success.withOpacityNew(0.7))),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.coins(dare.bountyAmount),
                      style: AppTypography.labelL(color: AppColors.coinGold)),
                  Text('bounty',
                      style: AppTypography.bodyS(color: AppColors.coinGold.withOpacityNew(0.7))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class PostMiniCard extends StatelessWidget {
  const PostMiniCard({super.key, required this.post});
  final PerformerPost post;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push(Routes.performerPostDetailPath(post.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title,
                      style: AppTypography.labelL(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(post.category,
                      style: AppTypography.bodyS(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.coins(post.askingPrice),
                    style: AppTypography.labelL(color: AppColors.coinGold)),
                Text('asking',
                    style: AppTypography.bodyS(color: AppColors.coinGold.withOpacityNew(0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
