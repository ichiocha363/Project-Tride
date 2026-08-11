import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // =========================
    // COLOR
    // =========================
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    scaffoldBackgroundColor: AppColors.background,

    // =========================
    // TYPOGRAPHY
    // =========================
    textTheme: const TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,

      headlineLarge: AppTypography.heading1,
      headlineMedium: AppTypography.heading2,
      headlineSmall: AppTypography.heading3,

      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,

      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),

    // =========================
    // APP BAR
    // =========================
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.heading2,
    ),

    // =========================
    // CARD
    // =========================
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    // =========================
    // INPUT
    // =========================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),

      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),

    // =========================
    // ELEVATED BUTTON
    // =========================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,

        minimumSize: const Size(double.infinity, 52),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        textStyle: AppTypography.buttonMedium,
      ),
    ),

    // =========================
    // OUTLINED BUTTON
    // =========================
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,

        minimumSize: const Size(double.infinity, 52),

        side: const BorderSide(color: AppColors.primary),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        textStyle: AppTypography.buttonMedium,
      ),
    ),

    // =========================
    // TEXT BUTTON
    // =========================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.buttonMedium,
      ),
    ),

    // =========================
    // BOTTOM NAVIGATION
    // =========================
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,

      indicatorColor: AppColors.primary.withValues(alpha: 0.12),

      labelTextStyle: WidgetStatePropertyAll(AppTypography.labelSmall),

      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }

        return const IconThemeData(color: AppColors.textSecondary);
      }),
    ),

    // =========================
    // DIVIDER
    // =========================
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // =========================
    // CHIP
    // =========================
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      disabledColor: AppColors.surfaceLight,

      labelStyle: AppTypography.labelMedium,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      side: BorderSide.none,
    ),

    // =========================
    // FLOATING ACTION BUTTON
    // =========================
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textWhite,
      elevation: 3,
    ),

    // =========================
    // SNACKBAR
    // =========================
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textWhite,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    // =========================
    // DIALOG
    // =========================
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      titleTextStyle: AppTypography.heading2.copyWith(
        color: AppColors.textPrimary,
      ),

      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  );
}
