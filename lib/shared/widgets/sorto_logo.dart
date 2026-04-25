import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum SortoLogoStyle {
  light,
  dark,
  monochrome,
  auto, // Based on theme
}

class SortoLogo extends StatelessWidget {
  const SortoLogo({
    super.key,
    this.size = 40,
    this.style = SortoLogoStyle.auto,
    this.useContainer = true,
    this.borderRadius,
  });

  final double size;
  final SortoLogoStyle style;
  final bool useContainer;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String assetPath;
    switch (style) {
      case SortoLogoStyle.light:
        assetPath = 'assets/icons/sorto_icon_light.png';
        break;
      case SortoLogoStyle.dark:
        assetPath = 'assets/icons/sorto_icon_dark.png';
        break;
      case SortoLogoStyle.monochrome:
        assetPath = 'assets/icons/sorto_icon_monochrome.png';
        break;
      case SortoLogoStyle.auto:
        assetPath = isDark 
            ? 'assets/icons/sorto_icon_dark.png' 
            : 'assets/icons/sorto_icon_light.png';
        break;
    }

    Widget logo = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (useContainer) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? size * 0.28),
          boxShadow: isDark ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: size * 0.4,
              spreadRadius: size * 0.08,
            ),
          ] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: logo,
      );
    }

    return logo;
  }
}
