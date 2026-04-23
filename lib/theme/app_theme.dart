// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_shapes.dart';

class AppTheme {
  // Use Poppins with a fallback as a base for the entire app.
  // Flutter's fontFamily can take a list.
  static final TextTheme
  _basePoppinsTextTheme = GoogleFonts.poppinsTextTheme().copyWith(
    // It's often cleaner to define specific styles in AppTextStyles and apply them
    // to TextTheme. Here we map standard Material names to our custom styles.
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    titleLarge: AppTextStyles.titleLarge,
    bodyLarge: AppTextStyles.bodyLargeOnDark,
    bodyMedium: AppTextStyles.bodyMediumOnDarkWhite,
    labelLarge: AppTextStyles.labelLarge,
    labelSmall: AppTextStyles.labelSmallWhite,
  );

  // Replicate the list approach in fontFamilyFallback for deeper application
  static const _fallbackFonts = ['Arial', 'sans-serif'];

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark().copyWith(
      primary: AppColors.profileGold,
      secondary: AppColors.activeGlow,
      background: AppColors.background,
      surface: AppColors.surfaceBlack,
      error: AppColors.error,
      onPrimary: AppColors.textOnLight,
      onSecondary: AppColors.textOnDarkHighContrast,
      onSurface: AppColors.textOnDarkHighContrast,
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: _basePoppinsTextTheme.apply(
        fontFamilyFallback: _fallbackFonts,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      fontFamilyFallback: _fallbackFonts,

      // Apply ColorScheme
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.surfaceBlack,

      // Widget-Specific Themes
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceWhite, // For the Sign In screen header
        elevation: 0,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.textOnLight,
        ),
        iconTheme: IconThemeData(color: AppColors.textOnLight),
      ),

      // Configure Card Theme to match shapes.dart
      cardTheme: CardThemeData(
        shape: AppShapes.primaryCardShape,
        color: AppColors.surfaceBlack,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
      ),

      // Configure Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite.withOpacity(
          0.05,
        ), // A dark, transparent fill
        border: AppShapes.customInputFieldBorder,
        enabledBorder: AppShapes.customInputFieldBorder,
        focusedBorder: AppShapes.customInputFieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.activeGlow, width: 2.0),
        ),
        labelStyle: AppTextStyles.bodyLargeOnDark.copyWith(
          color: AppColors.textOnDarkLowContrast,
        ),
        floatingLabelStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColors.profileGold,
        ),
        hintStyle: AppTextStyles.bodyLargeOnDark.copyWith(
          color: AppColors.textOnDarkLowContrast,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 16.0,
        ),
      ),

      // Configure Button Themes
      // Example of custom styling for the "Sign In" button (gradient handling is complex, so we'll likely make it a widget, but this defines other button styles)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: AppShapes.secondaryButtonShape,
          elevation: 4,
          backgroundColor:
              AppColors.profileGold, // Base color for primary actions
          foregroundColor: AppColors.textOnLight,
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textOnLight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.profileGold,
          textStyle: AppTextStyles.bodyMediumOnDarkGold,
          padding: const EdgeInsets.all(8.0),
        ),
      ),

      // FloatingActionButton example (e.g. the '+' icon)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors
            .transparent, // Making the '+' just the symbol on a transparent background
        foregroundColor: AppColors.activeGlow,
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
      ),

      // Bottom Navigation example
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceBlack,
        selectedItemColor: AppColors.activeGlow,
        unselectedItemColor: AppColors.textOnDarkLowContrast,
        selectedLabelStyle: AppTextStyles.labelSmallWhite,
        unselectedLabelStyle: AppTextStyles.labelSmallGold,
      ),
    );
  }
}
