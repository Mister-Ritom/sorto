// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Use Poppins with a fallback to Arial and standard sans-serif
  static final TextStyle _poppinsBase = GoogleFonts.poppins(
    textStyle: TextStyle(fontFamilyFallback: const ['Arial', 'sans-serif']),
  );

  static TextStyle get headlineLarge => _poppinsBase.copyWith(
    fontSize: 32.0,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textOnDarkHighContrast,
  );

  static TextStyle get headlineMedium => _poppinsBase.copyWith(
    fontSize: 28.0,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textOnDarkHighContrast,
  );

  static TextStyle get titleLarge => _poppinsBase.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.w600, // Semi-Bold
    color: AppColors.textOnDarkHighContrast,
  );

  static TextStyle get titleLargeGold => _poppinsBase.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDarkLowContrast,
  );

  static TextStyle get bodyLargeOnDark => _poppinsBase.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textOnDarkHighContrast,
  );

  static TextStyle get bodyLargeOnLight => _poppinsBase.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textOnLight,
  );

  static TextStyle get bodyMediumOnDarkGold => _poppinsBase.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textOnDarkLowContrast,
  );

  static TextStyle get bodyMediumOnDarkWhite => _poppinsBase.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textOnDarkHighContrast,
  );

  static TextStyle get labelLarge => _poppinsBase.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textOnDarkHighContrast,
  );

  static TextStyle get labelSmallGold => _poppinsBase.copyWith(
    fontSize: 11.0,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textOnDarkLowContrast,
  );

  static TextStyle get labelSmallWhite => _poppinsBase.copyWith(
    fontSize: 11.0,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textOnDarkHighContrast,
  );
}
