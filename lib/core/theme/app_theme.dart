import 'package:flutter/material.dart';

import 'tokens/ts_colors.dart';
import 'ts_semantic_colors.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const semantic = TsSemanticColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: semantic.surfaceBase,
      extensions: const [semantic],
      colorScheme: ColorScheme.dark(
        primary: semantic.interactivePrimary,
        onPrimary: semantic.interactiveOnPrimary,
        secondary: semantic.interactiveSecondary,
        onSecondary: semantic.interactiveOnPrimary,
        surface: semantic.surfaceRaised,
        onSurface: semantic.textPrimary,
        error: TsColors.systemError500,
        onError: semantic.interactiveOnPrimary,
        outline: semantic.borderDefault,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: semantic.surfaceRaised,
        foregroundColor: semantic.textPrimary,
        iconTheme: IconThemeData(color: semantic.textPrimary),
        titleTextStyle: TextStyle(
          color: semantic.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: semantic.surfaceRaised,
        selectedItemColor: semantic.interactivePrimary,
        unselectedItemColor: semantic.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: semantic.surfaceRaised,
        indicatorColor: semantic.interactivePrimary.withValues(alpha: 0.24),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: semantic.interactivePrimary);
          }
          return IconThemeData(color: semantic.textTertiary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: semantic.interactivePrimary, fontSize: 12);
          }
          return TextStyle(color: semantic.textTertiary, fontSize: 12);
        }),
      ),
    );
  }

  static ThemeData light() {
    const semantic = TsSemanticColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: semantic.surfaceBase,
      extensions: const [semantic],
      colorScheme: ColorScheme.light(
        primary: semantic.interactivePrimary,
        onPrimary: semantic.interactiveOnPrimary,
        secondary: semantic.interactiveSecondary,
        onSecondary: semantic.interactiveOnPrimary,
        surface: semantic.surfaceRaised,
        onSurface: semantic.textPrimary,
        error: TsColors.systemError500,
        onError: semantic.interactiveOnPrimary,
        outline: semantic.borderDefault,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: semantic.surfaceRaised,
        foregroundColor: semantic.textPrimary,
        iconTheme: IconThemeData(color: semantic.textPrimary),
        titleTextStyle: TextStyle(
          color: semantic.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: semantic.surfaceRaised,
        selectedItemColor: semantic.interactivePrimary,
        unselectedItemColor: semantic.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: semantic.surfaceRaised,
        indicatorColor: semantic.interactivePrimary.withValues(alpha: 0.24),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: semantic.interactivePrimary);
          }
          return IconThemeData(color: semantic.textTertiary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: semantic.interactivePrimary, fontSize: 12);
          }
          return TextStyle(color: semantic.textTertiary, fontSize: 12);
        }),
      ),
    );
  }
}
