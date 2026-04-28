// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';
import 'package:sorto/core/extensions/color_extensions.dart';

class AppColors {
  AppColors._();

  // ─── BRAND ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFA855F7); // Neon Purple
  static const Color primaryDim = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFD8B4FE);
  static const Color accent = Color(0xFFF97316); // Sunset Orange
  static const Color accentDim = Color(0xFFEA580C);
  static const Color accentLight = Color(0xFFFDBA74);

  // ─── DARK MODE ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF080808);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkCardBorder = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF999999);
  static const Color darkTextMuted = Color(0xFF555555);
  static const Color darkDivider = Color(0xFF1E1E1E);
  static const Color darkOverlay = Color(0x99080808);

  // ─── LIGHT MODE ──────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F0FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0ECF9);
  static const Color lightCardBorder = Color(0xFFE0D8F5);
  static const Color lightTextPrimary = Color(0xFF0D0D0D);
  static const Color lightTextSecondary = Color(0xFF555567);
  static const Color lightTextMuted = Color(0xFF9E9EA0);
  static const Color lightDivider = Color(0xFFEAE5F5);
  static const Color lightOverlay = Color(0x99F5F0FF);

  // ─── SEMANTIC (shared) ───────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0xFF052E16);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFF450A0A);
  static const Color warning = Color(0xFFFACC15);
  static const Color warningBg = Color(0xFF422006);
  static const Color info = Color(0xFF38BDF8);

  // ─── COIN / ESCROW COLORS ────────────────────────────────────────────────
  static const Color coinGold = Color(0xFFFFD700);
  static const Color coinGoldDim = Color(0xFFF59E0B);
  static const Color escrowPurple = Color(0xFFA855F7);
  static const Color earnedGreen = Color(0xFF22C55E);

  // ─── DARE MODE COLORS ────────────────────────────────────────────────────
  static const Color modeSolo = Color(0xFFF97316); // Orange
  static const Color modeSplit = Color(0xFFA855F7); // Purple
  static const Color modeBest = Color(0xFFFFD700); // Gold

  // ─── GRADIENTS ───────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient brandGradientDiagonal = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [darkSurface, darkBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightSurfaceGradient = LinearGradient(
    colors: [lightSurface, lightBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient coinGradient = LinearGradient(
    colors: [coinGold, coinGoldDim],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient posterCardGradient = LinearGradient(
    colors: [Color(0x00000000), Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── GLASS ───────────────────────────────────────────────────────────────
  static Color glassDark = Colors.white.withOpacityNew(0.05);
  static Color glassLight = Colors.white.withOpacityNew(0.60);
  static Color glassBorderDark = Colors.white.withOpacityNew(0.10);
  static Color glassBorderLight = Colors.white.withOpacityNew(0.30);

  // ─── COLORSCHEME FACTORIES ───────────────────────────────────────────────
  static ColorScheme darkColorScheme() => ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryDim,
        onPrimaryContainer: primaryLight,
        secondary: accent,
        onSecondary: Colors.white,
        secondaryContainer: accentDim,
        onSecondaryContainer: accentLight,
        error: error,
        onError: Colors.white,
        errorContainer: errorBg,
        onErrorContainer: error,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkCard,
        outline: darkCardBorder,
        outlineVariant: darkDivider,
        shadow: Colors.black,
        inverseSurface: lightSurface,
        onInverseSurface: lightTextPrimary,
        inversePrimary: primaryLight,
        scrim: Colors.black54,
      );

  static ColorScheme lightColorScheme() => ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryLight,
        onPrimaryContainer: primaryDim,
        secondary: accent,
        onSecondary: Colors.white,
        secondaryContainer: accentLight,
        onSecondaryContainer: accentDim,
        error: error,
        onError: Colors.white,
        errorContainer: const Color(0xFFFFDAD6),
        onErrorContainer: error,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        surfaceContainerHighest: lightCard,
        outline: lightCardBorder,
        outlineVariant: lightDivider,
        shadow: const Color(0xFFD6BBFB),
        inverseSurface: darkSurface,
        onInverseSurface: darkTextPrimary,
        inversePrimary: primaryDim,
        scrim: Colors.black26,
      );
}
