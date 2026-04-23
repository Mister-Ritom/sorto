// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // ─── DISPLAY (Syne — bold, editorial) ───────────────────────────────────
  static TextStyle displayXL({Color? color}) => GoogleFonts.syne(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: color ?? AppColors.darkTextPrimary,
    letterSpacing: -1.5,
    height: 1.0,
  );

  static TextStyle displayL({Color? color}) => GoogleFonts.syne(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: color ?? AppColors.darkTextPrimary,
    letterSpacing: -1.2,
    height: 1.05,
  );

  static TextStyle displayM({Color? color}) => GoogleFonts.syne(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.darkTextPrimary,
    letterSpacing: -0.8,
    height: 1.1,
  );

  static TextStyle displayS({Color? color}) => GoogleFonts.syne(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.darkTextPrimary,
    letterSpacing: -0.5,
    height: 1.15,
  );

  // ─── BODY (DM Sans) ──────────────────────────────────────────────────────
  static TextStyle headingL({Color? color}) => GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.darkTextPrimary,
    height: 1.2,
  );

  static TextStyle headingM({Color? color}) => GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.darkTextPrimary,
    height: 1.25,
  );

  static TextStyle headingS({Color? color}) => GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.darkTextPrimary,
    height: 1.3,
  );

  static TextStyle bodyL({Color? color}) => GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.darkTextPrimary,
    height: 1.5,
  );

  static TextStyle bodyM({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.darkTextSecondary,
    height: 1.5,
  );

  static TextStyle bodyS({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.darkTextMuted,
    height: 1.5,
  );

  static TextStyle labelL({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.darkTextPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle labelM({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.darkTextSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle labelS({Color? color}) => GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: color ?? AppColors.darkTextMuted,
    letterSpacing: 0.5,
  );

  // ─── SPECIAL ─────────────────────────────────────────────────────────────
  /// Typewriter display — same as displayL but monospace feel
  static TextStyle typewriter({Color? color}) => GoogleFonts.syne(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: color ?? AppColors.darkTextPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Username in creator card (display style)
  static TextStyle usernameDisplay({Color? color}) => GoogleFonts.syne(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.darkTextPrimary,
    letterSpacing: -0.5,
  );

  /// Coin amount (bold, gold)
  static TextStyle coinAmount({Color? color}) => GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.coinGold,
    height: 1.0,
  );

  static TextStyle coinAmountLarge({Color? color}) => GoogleFonts.syne(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: color ?? AppColors.coinGold,
    height: 1.0,
    letterSpacing: -0.5,
  );

  // ─── TEXT THEME ──────────────────────────────────────────────────────────
  static TextTheme buildTextTheme({bool dark = true}) {
    final primary = dark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondary = dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return TextTheme(
      displayLarge: displayXL(color: primary),
      displayMedium: displayL(color: primary),
      displaySmall: displayM(color: primary),
      headlineLarge: headingL(color: primary),
      headlineMedium: headingM(color: primary),
      headlineSmall: headingS(color: primary),
      titleLarge: headingL(color: primary),
      titleMedium: headingM(color: primary),
      titleSmall: headingS(color: primary),
      bodyLarge: bodyL(color: primary),
      bodyMedium: bodyM(color: secondary),
      bodySmall: bodyS(color: secondary),
      labelLarge: labelL(color: primary),
      labelMedium: labelM(color: secondary),
      labelSmall: labelS(color: secondary),
    );
  }
}
