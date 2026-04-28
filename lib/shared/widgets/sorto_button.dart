// lib/shared/widgets/sorto_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

enum SortoButtonVariant { primary, secondary, outline, ghost, danger }

class SortoButton extends StatefulWidget {
  const SortoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SortoButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final SortoButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final double borderRadius;
  final double? fontSize;

  @override
  State<SortoButton> createState() => _SortoButtonState();
}

class _SortoButtonState extends State<SortoButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed == null || widget.isLoading) return;
    _ctrl.forward();
    HapticFeedback.mediumImpact();
  }

  void _onTapUp(_) {
    _ctrl.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return AnimatedBuilder(
      animation: _scale,
      builder: (ctx, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: _buildButton(isDisabled),
        ),
      ),
    );
  }

  Widget _buildButton(bool isDisabled) {
    switch (widget.variant) {
      case SortoButtonVariant.primary:
        return _GradientButton(
          label: widget.label,
          isLoading: widget.isLoading,
          isDisabled: isDisabled,
          icon: widget.icon,
          trailingIcon: widget.trailingIcon,
          borderRadius: widget.borderRadius,
          fontSize: widget.fontSize,
        );
      case SortoButtonVariant.secondary:
        return _SolidButton(
          label: widget.label,
          isLoading: widget.isLoading,
          isDisabled: isDisabled,
          icon: widget.icon,
          trailingIcon: widget.trailingIcon,
          borderRadius: widget.borderRadius,
          fontSize: widget.fontSize,
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
        );
      case SortoButtonVariant.outline:
        return _OutlineButton(
          label: widget.label,
          isLoading: widget.isLoading,
          isDisabled: isDisabled,
          icon: widget.icon,
          trailingIcon: widget.trailingIcon,
          borderRadius: widget.borderRadius,
          fontSize: widget.fontSize,
        );
      case SortoButtonVariant.ghost:
        return _GhostButton(
          label: widget.label,
          isLoading: widget.isLoading,
          isDisabled: isDisabled,
          icon: widget.icon,
          borderRadius: widget.borderRadius,
          fontSize: widget.fontSize,
        );
      case SortoButtonVariant.danger:
        return _SolidButton(
          label: widget.label,
          isLoading: widget.isLoading,
          isDisabled: isDisabled,
          icon: widget.icon,
          trailingIcon: widget.trailingIcon,
          borderRadius: widget.borderRadius,
          fontSize: widget.fontSize,
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        );
    }
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.isDisabled,
    this.icon,
    this.trailingIcon,
    required this.borderRadius,
    this.fontSize,
  });

  final String label;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? trailingIcon;
  final double borderRadius;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: isDisabled ? null : AppColors.brandGradient,
          color: isDisabled ? AppColors.darkCardBorder : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacityNew(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(child: _content(Colors.white)),
      ),
    );
  }

  Widget _content(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTypography.labelL(
            color: color,
          ).copyWith(fontSize: fontSize),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, color: color, size: 20),
        ],
      ],
    );
  }
}

class _SolidButton extends StatelessWidget {
  const _SolidButton({
    required this.label,
    required this.isLoading,
    required this.isDisabled,
    this.icon,
    this.trailingIcon,
    required this.borderRadius,
    this.fontSize,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? trailingIcon;
  final double borderRadius;
  final double? fontSize;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.darkCardBorder : backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: foregroundColor,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: foregroundColor, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTypography.labelL(
                        color: foregroundColor,
                      ).copyWith(fontSize: fontSize),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, color: foregroundColor, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.isLoading,
    required this.isDisabled,
    this.icon,
    this.trailingIcon,
    required this.borderRadius,
    this.fontSize,
  });

  final String label;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? trailingIcon;
  final double borderRadius;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTypography.labelL(
                        color: AppColors.primary,
                      ).copyWith(fontSize: fontSize),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, color: AppColors.primary, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.isLoading,
    required this.isDisabled,
    this.icon,
    required this.borderRadius,
    this.fontSize,
  });

  final String label;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double borderRadius;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isDisabled ? 0.4 : 1.0,
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: AppTypography.bodyM(
                      color: color,
                    ).copyWith(fontSize: fontSize),
                  ),
                ],
              ),
      ),
    );
  }
}
