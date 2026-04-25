// lib/shared/widgets/sorto_fab.dart
//
// SortoFAB — A custom Floating Action Button built from the ground up.
//
// Design language:
//  • Elongated pill shape (not a circle) — feels editorial, not generic
//  • Brand gradient fill (purple → orange) with an inner glow
//  • ⚡ lightning bolt icon + "Dare" label — contextual, not just a plus
//  • Presses in (scale 0.93) with haptic feedback
//  • Idle breathing animation — very subtle scale pulse to draw attention
//  • Casts a coloured shadow that matches the gradient
//  • Collapses to icon-only when scrolled down (via [collapsed] flag)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'sorto_logo.dart';

class SortoFAB extends StatefulWidget {
  const SortoFAB({
    super.key,
    required this.onPressed,
    this.collapsed = false,
  });

  final VoidCallback onPressed;

  /// When true, the label is hidden and the pill shrinks to a square-ish icon.
  /// Use this when the user has scrolled down to give back screen real-estate.
  final bool collapsed;

  @override
  State<SortoFAB> createState() => _SortoFABState();
}

class _SortoFABState extends State<SortoFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
    HapticFeedback.mediumImpact();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    widget.onPressed();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    // The pill width shrinks when collapsed
    final targetWidth = widget.collapsed ? 60.0 : 130.0;
    final targetHeight = 54.0;

    return AnimatedBuilder(
      animation: _breathe,
      builder: (context, child) {
        // Subtle 0 → 4px glow pulse
        final glowSpread = _breathe.value * 4.0;
        final glowBlur = 12.0 + _breathe.value * 10.0;

        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: targetWidth,
              height: targetHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(targetHeight / 2),
                gradient: AppColors.brandGradient,
                // Layered shadows: coloured glow + deep shadow for lift
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.55),
                    blurRadius: glowBlur,
                    spreadRadius: glowSpread,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.30),
                    blurRadius: glowBlur * 1.5,
                    spreadRadius: 0,
                    offset: const Offset(4, 6),
                  ),
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner highlight — thin bright line at the top edge
                  Positioned(
                    top: 1,
                    left: 12,
                    right: 12,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content: icon + animated label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ⚡ Icon with a slight drop shadow for pop
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const SortoLogo(
                            size: 18,
                            style: SortoLogoStyle.monochrome,
                            useContainer: false,
                          ),
                        ),

                        // Label — slides in/out when collapsing
                        ClipRect(
                          child: AnimatedAlign(
                            alignment: Alignment.centerLeft,
                            widthFactor: widget.collapsed ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOutCubic,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Text(
                                'Dare',
                                style: AppTypography.labelL(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    )
        // Entry animation: bounces in from below after a short delay
        .animate(delay: 600.ms)
        .slideY(begin: 1.5, end: 0, duration: 500.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms);
  }
}
