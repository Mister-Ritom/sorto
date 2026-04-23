// lib/features/dares/screens/dare_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/dare.dart';
import '../../../shared/widgets/coin_chip.dart';
import '../../../shared/widgets/dare_mode_badge.dart';
import '../../../shared/widgets/sorto_button.dart';
import '../../../features/auth/auth_provider.dart';
import '../dares_provider.dart';

class DareDetailScreen extends ConsumerWidget {
  const DareDetailScreen({super.key, required this.dareId});
  final String dareId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dareAsync = ref.watch(dareDetailProvider(dareId));
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: dareAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Failed to load dare: $e')),
        data: (dare) {
          if (dare == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Dare not found', style: AppTypography.headingM()),
                ],
              ),
            );
          }

          final isMyDare = userAsync.value?.id == dare.posterId;
          final isPerformer = userAsync.value?.id == dare.performerId;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded),
                    onPressed: () => HapticFeedback.lightImpact(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () => HapticFeedback.lightImpact(),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    dare.dareMode.label,
                    style: AppTypography.labelM(color: AppColors.primary),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Poster row ────────────────────────────────────────
                    _PosterRow(dare: dare)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 20),

                    // ── Title ─────────────────────────────────────────────
                    Text(dare.title,
                        style: AppTypography.displayS(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary))
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 12),

                    // ── Description ───────────────────────────────────────
                    Text(dare.description,
                        style: AppTypography.bodyL(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary))
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Mode explanation ──────────────────────────────────
                    _ModeCard(mode: dare.dareMode)
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Bounty breakdown ──────────────────────────────────
                    _BountyBreakdown(dare: dare)
                        .animate(delay: 250.ms)
                        .fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Submission count (open modes) ─────────────────────
                    if (dare.dareMode != DareMode.solo &&
                        dare.submissionCount > 0)
                      _SubmissionInfo(dare: dare)
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Deadline ──────────────────────────────────────────
                    if (dare.expiresAt != null)
                      _DeadlineCard(expiresAt: dare.expiresAt!)
                          .animate(delay: 350.ms)
                          .fadeIn(duration: 400.ms),

                    const SizedBox(height: 32),

                    // ── CTA ───────────────────────────────────────────────
                    _DetailCTA(
                      dare: dare,
                      isMyDare: isMyDare,
                      isPerformer: isPerformer,
                    ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.dare});
  final Dare dare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradientDiagonal,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (dare.posterUsername ?? '?')[0].toUpperCase(),
              style: AppTypography.headingS(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${dare.posterUsername ?? 'unknown'}',
                style: AppTypography.labelL(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
              ),
              Text(
                Formatters.fullDateTime(dare.createdAt),
                style: AppTypography.bodyS(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
              ),
            ],
          ),
        ),
        DareModeBadge(mode: dare.dareMode),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode});
  final DareMode mode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        children: [
          DareModeBadge(mode: mode),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mode.description,
              style: AppTypography.bodyM(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BountyBreakdown extends StatelessWidget {
  const _BountyBreakdown({required this.dare});
  final Dare dare;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rows = [
      ('Total bounty', dare.bountyAmount, AppColors.coinGold),
      ('Platform fee (20%)', -dare.platformFee, AppColors.error),
      ('Your earnings', dare.performerShare, AppColors.success),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bounty breakdown',
              style: AppTypography.labelM(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
          const SizedBox(height: 12),
          ...rows.map((r) {
            final (label, amount, color) = r;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(label, style: AppTypography.bodyM()),
                  const Spacer(),
                  CoinAmount(
                    amount: amount.abs(),
                    size: CoinAmountSize.medium,
                    color: color,
                  ),
                ],
              ),
            );
          }),
          if (dare.dareMode == DareMode.openSplit &&
              dare.submissionCount > 0) ...[
            const Divider(height: 16),
            Row(
              children: [
                Text('Your share if you win (${dare.submissionCount} entries)',
                    style: AppTypography.bodyS()),
                const Spacer(),
                CoinAmount(
                  amount: dare.splitShare,
                  size: CoinAmountSize.medium,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmissionInfo extends StatelessWidget {
  const _SubmissionInfo({required this.dare});
  final Dare dare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('👥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${dare.submissionCount} submissions so far — '
              '${dare.dareMode == DareMode.openSplit ? 'your share would be ~${Formatters.coins(dare.splitShare)}' : 'compete for the top spot'}',
              style: AppTypography.bodyM(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({required this.expiresAt});
  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final remaining = Formatters.timeRemaining(expiresAt);
    final isUrgent = expiresAt.difference(DateTime.now()).inHours < 6;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.error.withOpacity(0.08)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUrgent
              ? AppColors.error.withOpacity(0.3)
              : AppColors.darkCardBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            color: isUrgent ? AppColors.error : AppColors.darkTextSecondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            remaining,
            style: AppTypography.labelM(
                color: isUrgent ? AppColors.error : AppColors.darkTextSecondary),
          ),
          const Spacer(),
          Text(
            Formatters.fullDateTime(expiresAt),
            style: AppTypography.bodyS(color: AppColors.darkTextMuted),
          ),
        ],
      ),
    );
  }
}

class _DetailCTA extends ConsumerWidget {
  const _DetailCTA({
    required this.dare,
    required this.isMyDare,
    required this.isPerformer,
  });
  final Dare dare;
  final bool isMyDare;
  final bool isPerformer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimState = ref.watch(claimDareProvider);
    final isLoading = claimState is AsyncLoading;

    if (isMyDare) {
      return Center(
        child: Text(
          '✅ This is your dare',
          style: AppTypography.bodyM(color: AppColors.darkTextSecondary),
        ),
      );
    }

    if (isPerformer) {
      return SortoButton(
        label: 'Submit Proof',
        variant: SortoButtonVariant.primary,
        onPressed: () => context.push(Routes.submitProofPath(dare.id)),
      );
    }

    if (dare.status == DareStatus.open) {
      if (dare.dareMode == DareMode.solo) {
        return SortoButton(
          label: 'Claim this Dare',
          isLoading: isLoading,
          onPressed: isLoading
              ? null
              : () async {
                  HapticFeedback.mediumImpact();
                  final ok = await ref
                      .read(claimDareProvider.notifier)
                      .claim(dare.id);
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('🎯 Dare claimed! Start filming.')),
                    );
                  }
                },
        );
      } else {
        return SortoButton(
          label: 'Submit Proof',
          onPressed: () => context.push(Routes.submitProofPath(dare.id)),
        );
      }
    }

    if (dare.status == DareStatus.locked && !isPerformer) {
      return SortoButton(
        label: 'This dare is claimed',
        variant: SortoButtonVariant.ghost,
        onPressed: null,
      );
    }

    return const SizedBox.shrink();
  }
}
