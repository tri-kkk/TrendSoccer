import 'package:flutter/material.dart';

import 'tokens/ts_colors.dart';

/// v2 semantic colors as a [ThemeExtension].
@immutable
class TsSemanticColors extends ThemeExtension<TsSemanticColors> {
  const TsSemanticColors({
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceOverlay,
    required this.surfaceContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.interactivePrimary,
    required this.interactiveOnPrimary,
    required this.interactiveSecondary,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderFocus,
    required this.interactiveSurface,
    required this.interactiveSurfaceStrong,
    required this.interactiveDivider,
  });

  static const TsSemanticColors dark = TsSemanticColors(
    surfaceBase: TsColors.canvas100,
    surfaceRaised: TsColors.canvas0,
    surfaceOverlay: TsColors.canvas200,
    surfaceContainer: TsColors.canvas300,
    textPrimary: TsColors.onCanvas0,
    textSecondary: TsColors.onCanvas100,
    textTertiary: TsColors.onCanvas200,
    textDisabled: TsColors.onCanvas300,
    interactivePrimary: TsColors.brandPrimary500,
    interactiveOnPrimary: TsColors.canvas0,
    interactiveSecondary: TsColors.brandPrimary400,
    borderDefault: TsColors.onCanvas300,
    borderSubtle: TsColors.canvas300,
    borderFocus: TsColors.brandPrimary500,
    interactiveSurface: Color(0x0DFFFFFF),
    interactiveSurfaceStrong: Color(0x1AFFFFFF),
    interactiveDivider: TsColors.canvas300,
  );

  static const TsSemanticColors light = TsSemanticColors(
    surfaceBase: TsColors.neutral100,
    surfaceRaised: TsColors.neutral0,
    surfaceOverlay: TsColors.neutral0,
    surfaceContainer: TsColors.neutral50,
    textPrimary: TsColors.neutral900,
    textSecondary: TsColors.neutral600,
    textTertiary: TsColors.neutral500,
    textDisabled: TsColors.neutral400,
    interactivePrimary: TsColors.brandPrimary700,
    interactiveOnPrimary: TsColors.neutral0,
    interactiveSecondary: TsColors.brandPrimary600,
    borderDefault: TsColors.neutral300,
    borderSubtle: TsColors.neutral200,
    borderFocus: TsColors.brandPrimary700,
    interactiveSurface: Color(0x0D000000),
    interactiveSurfaceStrong: Color(0x1A000000),
    interactiveDivider: TsColors.neutral200,
  );

  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceOverlay;
  final Color surfaceContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color interactivePrimary;
  final Color interactiveOnPrimary;
  final Color interactiveSecondary;
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderFocus;
  final Color interactiveSurface;
  final Color interactiveSurfaceStrong;
  final Color interactiveDivider;

  @override
  TsSemanticColors copyWith({
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceOverlay,
    Color? surfaceContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? interactivePrimary,
    Color? interactiveOnPrimary,
    Color? interactiveSecondary,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderFocus,
    Color? interactiveSurface,
    Color? interactiveSurfaceStrong,
    Color? interactiveDivider,
  }) {
    return TsSemanticColors(
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      interactivePrimary: interactivePrimary ?? this.interactivePrimary,
      interactiveOnPrimary: interactiveOnPrimary ?? this.interactiveOnPrimary,
      interactiveSecondary: interactiveSecondary ?? this.interactiveSecondary,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderFocus: borderFocus ?? this.borderFocus,
      interactiveSurface: interactiveSurface ?? this.interactiveSurface,
      interactiveSurfaceStrong:
          interactiveSurfaceStrong ?? this.interactiveSurfaceStrong,
      interactiveDivider: interactiveDivider ?? this.interactiveDivider,
    );
  }

  @override
  TsSemanticColors lerp(ThemeExtension<TsSemanticColors>? other, double t) {
    if (other is! TsSemanticColors) return this;
    return TsSemanticColors(
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      interactivePrimary: Color.lerp(interactivePrimary, other.interactivePrimary, t)!,
      interactiveOnPrimary: Color.lerp(interactiveOnPrimary, other.interactiveOnPrimary, t)!,
      interactiveSecondary: Color.lerp(interactiveSecondary, other.interactiveSecondary, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      interactiveSurface: Color.lerp(interactiveSurface, other.interactiveSurface, t)!,
      interactiveSurfaceStrong:
          Color.lerp(interactiveSurfaceStrong, other.interactiveSurfaceStrong, t)!,
      interactiveDivider: Color.lerp(interactiveDivider, other.interactiveDivider, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TsSemanticColors &&
        other.surfaceBase == surfaceBase &&
        other.surfaceRaised == surfaceRaised &&
        other.surfaceOverlay == surfaceOverlay &&
        other.surfaceContainer == surfaceContainer &&
        other.textPrimary == textPrimary &&
        other.textSecondary == textSecondary &&
        other.textTertiary == textTertiary &&
        other.textDisabled == textDisabled &&
        other.interactivePrimary == interactivePrimary &&
        other.interactiveOnPrimary == interactiveOnPrimary &&
        other.interactiveSecondary == interactiveSecondary &&
        other.borderDefault == borderDefault &&
        other.borderSubtle == borderSubtle &&
        other.borderFocus == borderFocus &&
        other.interactiveSurface == interactiveSurface &&
        other.interactiveSurfaceStrong == interactiveSurfaceStrong &&
        other.interactiveDivider == interactiveDivider;
  }

  @override
  int get hashCode => Object.hash(
        surfaceBase,
        surfaceRaised,
        surfaceOverlay,
        surfaceContainer,
        textPrimary,
        textSecondary,
        textTertiary,
        textDisabled,
        interactivePrimary,
        interactiveOnPrimary,
        interactiveSecondary,
        borderDefault,
        borderSubtle,
        borderFocus,
        interactiveSurface,
        interactiveSurfaceStrong,
        interactiveDivider,
      );
}
