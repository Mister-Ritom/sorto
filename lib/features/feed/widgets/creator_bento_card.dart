// lib/features/feed/widgets/creator_bento_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/performer_post.dart';
import '../../../shared/widgets/coin_chip.dart';

class CreatorBentoCard extends StatefulWidget {
  const CreatorBentoCard({
    super.key,
    required this.post,
  });

  final PerformerPost post;

  @override
  State<CreatorBentoCard> createState() => _CreatorBentoCardState();
}

class _CreatorBentoCardState extends State<CreatorBentoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return AnimatedBuilder(
      animation: _scale,
      builder: (ctx, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          HapticFeedback.lightImpact();
          context.push(Routes.performerPostDetailPath(post.id));
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background (avatar or gradient) ──────────────────────────
              if (post.performerAvatarUrl != null)
                CachedNetworkImage(
                  imageUrl: post.performerAvatarUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _GradientBg(username: post.performerUsername ?? '?'),
                )
              else
                _GradientBg(username: post.performerUsername ?? '?'),

              // ── Gradient overlay ──────────────────────────────────────────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.posterCardGradient,
                ),
              ),

              // ── Bottom info ───────────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '@${post.performerUsername ?? 'unknown'}',
                        style: AppTypography.labelM(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        post.title,
                        style: AppTypography.headingS(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CoinAmount(
                            amount: post.askingPrice,
                            size: CoinAmountSize.small,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'Fund',
                              style: AppTypography.labelS(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBg extends StatelessWidget {
  const _GradientBg({required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradientDiagonal),
      child: Center(
        child: Text(initial, style: TextStyle(fontSize: 64, color: Colors.white.withOpacity(0.3))),
      ),
    );
  }
}
