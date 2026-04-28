// lib/shared/widgets/dare_mode_badge.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/models/dare.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class DareModeBadge extends StatelessWidget {
  const DareModeBadge({
    super.key,
    required this.mode,
    this.compact = false,
  });

  final DareMode mode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (mode) {
      DareMode.solo => (AppColors.modeSolo, '🎯', 'Solo'),
      DareMode.openSplit => (AppColors.modeSplit, '🤝', 'Split'),
      DareMode.openBest => (AppColors.modeBest, '🏆', 'Best'),
    };

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacityNew(0.15),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withOpacityNew(0.4), width: 1),
        ),
        child: Text(
          label,
          style: AppTypography.labelS(color: color),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacityNew(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacityNew(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelM(color: color),
          ),
        ],
      ),
    );
  }
}

class DareStatusBadge extends StatelessWidget {
  const DareStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final DareStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (status) {
      DareStatus.open => (AppColors.success, '🟢'),
      DareStatus.locked => (AppColors.accent, '🔒'),
      DareStatus.underReview => (AppColors.warning, '⏳'),
      DareStatus.completed => (AppColors.success, '✅'),
      DareStatus.rejected => (AppColors.error, '❌'),
      DareStatus.cancelled => (AppColors.darkTextMuted, '🚫'),
      DareStatus.disputed => (AppColors.warning, '⚠️'),
    };

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withOpacityNew(0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacityNew(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Text(icon, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: compact
                ? AppTypography.labelS(color: color)
                : AppTypography.labelM(color: color),
          ),
        ],
      ),
    );
  }
}
