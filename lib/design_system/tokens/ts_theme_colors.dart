import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_colors.dart';

@immutable
class TsThemeColors extends ThemeExtension<TsThemeColors> {
  const TsThemeColors({
    required this.canvas,
    required this.surface,
    required this.surfaceRaised,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.primary,
    required this.primaryStrong,
    required this.primaryMuted,
    required this.primarySubtle,
    required this.onPrimary,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderFocus,
    required this.dataPositive,
    required this.dataPositiveSubtle,
    required this.dataNegative,
    required this.dataNegativeSubtle,
    required this.dataNeutral,
    required this.dataNeutralSubtle,
    required this.scrim,
    required this.scrimLight,
    required this.onScrim,
    required this.onScrimSubtle,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceRaised;
  final Color overlay;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color primary;
  final Color primaryStrong;
  final Color primaryMuted;
  final Color primarySubtle;
  final Color onPrimary;
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderFocus;
  final Color dataPositive;
  final Color dataPositiveSubtle;
  final Color dataNegative;
  final Color dataNegativeSubtle;
  final Color dataNeutral;
  final Color dataNeutralSubtle;
  final Color scrim;
  final Color scrimLight;
  final Color onScrim;
  final Color onScrimSubtle;
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  static const TsThemeColors dark = TsThemeColors(
    canvas: TsColors.neutral950,
    surface: TsColors.neutral900,
    surfaceRaised: TsColors.neutral800,
    overlay: TsColors.neutral850,
    textPrimary: TsColors.neutral35,
    textSecondary: TsColors.neutral250,
    textTertiary: TsColors.neutral400,
    textDisabled: TsColors.neutral700,
    primary: TsColors.primary500,
    primaryStrong: TsColors.primary450,
    primaryMuted: Color(0x331ECE8E),
    primarySubtle: Color(0x1A1ECE8E),
    onPrimary: TsColors.neutral950,
    borderDefault: TsColors.neutral750,
    borderSubtle: TsColors.neutral800,
    borderFocus: TsColors.primary500,
    dataPositive: TsColors.cyan400,
    dataPositiveSubtle: Color(0x2E22D3EE),
    dataNegative: TsColors.coral400,
    dataNegativeSubtle: Color(0x2EFB6B7C),
    dataNeutral: TsColors.gray400,
    dataNeutralSubtle: Color(0x2E9AA1AC),
    scrim: Color(0x80000000),
    scrimLight: Color(0x4D000000),
    onScrim: TsColors.neutral0,
    onScrimSubtle: TsColors.neutral250,
    success: TsColors.cyan400,
    error: TsColors.coral400,
    warning: TsColors.warnDark,
    info: TsColors.infoDark,
  );

  static const TsThemeColors light = TsThemeColors(
    canvas: TsColors.neutral25,
    surface: TsColors.neutral0,
    surfaceRaised: TsColors.neutral50,
    overlay: TsColors.neutral0,
    textPrimary: TsColors.neutral925,
    textSecondary: TsColors.neutral600,
    textTertiary: TsColors.neutral500,
    textDisabled: TsColors.neutral300,
    primary: TsColors.primary650,
    primaryStrong: TsColors.primary750,
    primaryMuted: Color(0x330A7A55),
    primarySubtle: Color(0x1A0A7A55),
    onPrimary: TsColors.neutral0,
    borderDefault: TsColors.neutral200,
    borderSubtle: TsColors.neutral100,
    borderFocus: TsColors.primary650,
    dataPositive: TsColors.cyan700,
    dataPositiveSubtle: Color(0x1F0E7490),
    dataNegative: TsColors.coral700,
    dataNegativeSubtle: Color(0x1FC9314A),
    dataNeutral: TsColors.gray500,
    dataNeutralSubtle: Color(0x1F6B7280),
    scrim: Color(0x80000000),
    scrimLight: Color(0x4D000000),
    onScrim: TsColors.neutral0,
    onScrimSubtle: TsColors.neutral250,
    success: TsColors.cyan700,
    error: TsColors.coral700,
    warning: TsColors.warnLight,
    info: TsColors.infoLight,
  );

  @override
  TsThemeColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceRaised,
    Color? overlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? primary,
    Color? primaryStrong,
    Color? primaryMuted,
    Color? primarySubtle,
    Color? onPrimary,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderFocus,
    Color? dataPositive,
    Color? dataPositiveSubtle,
    Color? dataNegative,
    Color? dataNegativeSubtle,
    Color? dataNeutral,
    Color? dataNeutralSubtle,
    Color? scrim,
    Color? scrimLight,
    Color? onScrim,
    Color? onScrimSubtle,
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
  }) {
    return TsThemeColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      overlay: overlay ?? this.overlay,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      primary: primary ?? this.primary,
      primaryStrong: primaryStrong ?? this.primaryStrong,
      primaryMuted: primaryMuted ?? this.primaryMuted,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      onPrimary: onPrimary ?? this.onPrimary,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderFocus: borderFocus ?? this.borderFocus,
      dataPositive: dataPositive ?? this.dataPositive,
      dataPositiveSubtle: dataPositiveSubtle ?? this.dataPositiveSubtle,
      dataNegative: dataNegative ?? this.dataNegative,
      dataNegativeSubtle: dataNegativeSubtle ?? this.dataNegativeSubtle,
      dataNeutral: dataNeutral ?? this.dataNeutral,
      dataNeutralSubtle: dataNeutralSubtle ?? this.dataNeutralSubtle,
      scrim: scrim ?? this.scrim,
      scrimLight: scrimLight ?? this.scrimLight,
      onScrim: onScrim ?? this.onScrim,
      onScrimSubtle: onScrimSubtle ?? this.onScrimSubtle,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  TsThemeColors lerp(TsThemeColors? other, double t) {
    if (other is! TsThemeColors) return this;
    return TsThemeColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryStrong: Color.lerp(primaryStrong, other.primaryStrong, t)!,
      primaryMuted: Color.lerp(primaryMuted, other.primaryMuted, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      dataPositive: Color.lerp(dataPositive, other.dataPositive, t)!,
      dataPositiveSubtle:
          Color.lerp(dataPositiveSubtle, other.dataPositiveSubtle, t)!,
      dataNegative: Color.lerp(dataNegative, other.dataNegative, t)!,
      dataNegativeSubtle:
          Color.lerp(dataNegativeSubtle, other.dataNegativeSubtle, t)!,
      dataNeutral: Color.lerp(dataNeutral, other.dataNeutral, t)!,
      dataNeutralSubtle:
          Color.lerp(dataNeutralSubtle, other.dataNeutralSubtle, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      scrimLight: Color.lerp(scrimLight, other.scrimLight, t)!,
      onScrim: Color.lerp(onScrim, other.onScrim, t)!,
      onScrimSubtle: Color.lerp(onScrimSubtle, other.onScrimSubtle, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
