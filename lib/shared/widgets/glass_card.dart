// lib/shared/widgets/glass_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 12,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1,
    this.backgroundColor,
    this.onTap,
    this.selected = false,
    this.selectionColor,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool selected;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.glassDark : AppColors.glassLight);
    final frostColor = borderColor ??
        (selected
            ? (selectionColor ?? AppColors.primary).withOpacityNew(0.5)
            : (isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight));

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: gradient,
        color: gradient == null ? bgColor : null,
        border: Border.all(color: frostColor, width: borderWidth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: card,
      ),
    );
  }
}

/// Pressable glass card with scale-down animation
class PressableGlassCard extends StatefulWidget {
  const PressableGlassCard({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = 20,
    this.blur = 12,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.selected = false,
    this.selectionColor,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final double blur;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final Color? selectionColor;
  final Color? borderColor;

  @override
  State<PressableGlassCard> createState() => _PressableGlassCardState();
}

class _PressableGlassCardState extends State<PressableGlassCard>
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
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (ctx, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: GlassCard(
          borderRadius: widget.borderRadius,
          blur: widget.blur,
          padding: widget.padding,
          margin: widget.margin,
          selected: widget.selected,
          selectionColor: widget.selectionColor,
          borderColor: widget.borderColor,
          child: widget.child,
        ),
      ),
    );
  }
}
