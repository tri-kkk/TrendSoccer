import 'package:flutter/material.dart';

import 'tokens/color_tokens.dart';
import 'tokens/spacing_tokens.dart';
import 'tokens/typography_tokens.dart';

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // ── Color Scheme ──────────────────────────
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary500,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.primary700,
      onPrimaryContainer: AppColors.primary100,
      secondary: AppColors.accent,
      onSecondary: AppColors.surfaceBase,
      surface: AppColors.surfaceBase,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceContainer,
      error: AppColors.errorRed500,
      onError: AppColors.textPrimary,
      outline: AppColors.textTertiary,
      outlineVariant: AppColors.surfaceOverlay,
    ),

    scaffoldBackgroundColor: AppColors.surfaceBase,

    // ── Text Theme ────────────────────────────
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
    ),

    // ── AppBar ────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceBase,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimary,
      ),
    ),

    // ── Bottom Navigation ─────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceRaised,
      selectedItemColor: AppColors.primary400,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
    ),

    // ── Elevated Button ───────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary500,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.primary500.withAlpha(97),
        disabledForegroundColor: AppColors.textDisabled,
        minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),

    // ── Outlined Button ───────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary400,
        side: const BorderSide(color: AppColors.primary400),
        minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),

    // ── Card ──────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surfaceRaised,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
    ),

    // ── Bottom Sheet ──────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),

    // ── Checkbox ──────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary500;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.textPrimary),
      side: const BorderSide(color: AppColors.textTertiary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    ),

    // ── Radio ─────────────────────────────────
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary500;
        }
        return AppColors.textTertiary;
      }),
    ),

    // ── Switch ────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary400;
        }
        return AppColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary700;
        }
        return AppColors.surfaceOverlay;
      }),
    ),

    // ── Divider ───────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceOverlay,
      thickness: 1,
      space: 1,
    ),
  );
}
