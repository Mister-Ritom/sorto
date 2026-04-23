// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Core Background & Surfaces
  static const Color background = Color(0xFF1F0F29);
  static const Color surfaceBlack = Color(0xFF000000);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textOnDarkHighContrast = Color(0xFFFFFFFF);
  static const Color textOnDarkLowContrast = Color(0xFFDAA565);
  static const Color textOnLight = Color(0xFF1F0F29);

  // Accent & State Colors
  static const Color profileGold = Color(0xFFDAA565);
  static const Color creatorPink = Color(0xFFD48BAF);
  static const Color creatorGreen = Color(0xFF69B0AC);
  static const Color activeGlow = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);

  // Gradients
  // Wavy Divider
  static const Color gradient1Orange = Color(0xFFFF8A65);
  static const Color gradient1Purple = Color(0xFF9C27B0);

  // Sign In Button
  static const Color gradient2Pink = Color(0xFFE91E63);
  static const Color gradient2DeepPurple = Color(0xFF673AB7);

  // Example gradient for list item backgrounds
  static const LinearGradient defaultCreatorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [profileGold, Colors.transparent],
    stops: [0.1, 1.0],
  );
}
