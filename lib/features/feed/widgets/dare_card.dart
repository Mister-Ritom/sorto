// lib/features/feed/widgets/dare_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/dare.dart';
import '../../../shared/widgets/coin_chip.dart';
import '../../../shared/widgets/dare_mode_badge.dart';

class DareCard extends StatefulWidget {
  const DareCard({
    super.key,
    required this.dare,
    this.onClaim,
    this.animationDelay = Duration.zero,
  });

  final Dare dare;
  final VoidCallback? onClaim;
  final Duration animationDelay;

  @override
  State<DareCard> createState() => _DareCardState();
}

class _DareCardState extends State<DareCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dare = widget.dare;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AnimatedBuilder(
      animation: _scale,
      builder: (ctx, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          HapticFeedback.lightImpact();
          context.push(Routes.dareDetailPath(dare.id));
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    // Avatar
                    _Avatar(url: dare.posterAvatarUrl, username: dare.posterUsername ?? '?'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${dare.posterUsername ?? 'unknown'}',
                            style: AppTypography.labelM(color: textPrimary),
                          ),
                          Text(
                            Formatters.shortDate(dare.createdAt),
                            style: AppTypography.bodyS(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    DareModeBadge(mode: dare.dareMode, compact: true),
                  ],
                ),
              ),

              // ── Title ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Text(
                  dare.title,
                  style: AppTypography.headingM(color: textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── Category chip + time ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    _CategoryPill(category: dare.category),
                    const SizedBox(width: 8),
                    if (dare.expiresAt != null)
                      _TimeChip(expiresAt: dare.expiresAt!),
                    if (dare.dareMode != DareMode.solo && dare.submissionCount > 0) ...[
                      const SizedBox(width: 8),
                      _SubmissionCount(count: dare.submissionCount),
                    ],
                  ],
                ),
              ),

              // ── Footer ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CoinAmount(
                      amount: dare.performerShare,
                      size: CoinAmountSize.large,
                    ),
                    Text(
                      ' to win',
                      style: AppTypography.bodyM(color: textSecondary),
                    ),
                    const Spacer(),
                    if (dare.status == DareStatus.open)
                      _ClaimButton(
                        mode: dare.dareMode,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          if (widget.onClaim != null) {
                            widget.onClaim!();
                          } else {
                            context.push(Routes.dareDetailPath(dare.id));
                          }
                        },
                      )
                    else
                      DareStatusBadge(status: dare.status, compact: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: widget.animationDelay).fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0);
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.username});
  final String? url;
  final String username;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _Fallback(username: username),
        ),
      );
    }
    return _Fallback(username: username);
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientDiagonal,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: AppTypography.labelL(color: Colors.white),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        category,
        style: AppTypography.labelS(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.expiresAt});
  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final remaining = Formatters.timeRemaining(expiresAt);
    final isUrgent = expiresAt.difference(DateTime.now()).inHours < 6;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.error.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded,
              size: 11, color: isUrgent ? AppColors.error : AppColors.darkTextMuted),
          const SizedBox(width: 4),
          Text(remaining,
              style: AppTypography.labelS(
                  color: isUrgent ? AppColors.error : AppColors.darkTextMuted)),
        ],
      ),
    );
  }
}

class _SubmissionCount extends StatelessWidget {
  const _SubmissionCount({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('👥', style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 3),
        Text('$count',
            style: AppTypography.labelS()),
      ],
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.mode, required this.onTap});
  final DareMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = mode == DareMode.solo ? 'Claim' : 'Enter';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(label,
            style: AppTypography.labelL(color: Colors.white)),
      ),
    );
  }
}
