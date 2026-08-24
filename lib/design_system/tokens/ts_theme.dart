import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';

ThemeData buildTsTheme(Brightness brightness) {
  final colors =
      brightness == Brightness.dark ? TsThemeColors.dark : TsThemeColors.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: colors.canvas,
    extensions: [colors],
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.primaryStrong,
      onSecondary: colors.onPrimary,
      error: colors.error,
      onError: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
