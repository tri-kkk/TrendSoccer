import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum TsLogoType { horizon, vertical, circle }

enum TsLogoColor { white, black, gradient, editor }

String? _logoAssetPath(BuildContext context, TsLogoType type, TsLogoColor color) {
  if (color == TsLogoColor.editor && type != TsLogoType.circle) {
    return null;
  }

  final brightness = Theme.of(context).brightness;
  return switch (type) {
    TsLogoType.circle => TsAssets.logoEditor(brightness),
    TsLogoType.horizon => TsAssets.logoHorizon(brightness),
    TsLogoType.vertical => TsAssets.logoVertical(brightness),
  };
}

Color _logoFallbackTextColor(
  TsLogoColor color,
  TsSemanticColors semantic,
) {
  return switch (color) {
    TsLogoColor.white => TsColors.neutral0,
    TsLogoColor.black => TsColors.neutral900,
    TsLogoColor.gradient => TsColors.brandPrimary500,
    TsLogoColor.editor => semantic.textPrimary,
  };
}

class TsLogo extends StatelessWidget {
  const TsLogo({
    this.type = TsLogoType.horizon,
    this.color = TsLogoColor.white,
    this.height,
    super.key,
  });

  final TsLogoType type;
  final TsLogoColor color;
  final double? height;

  Widget _fallback(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final c = _logoFallbackTextColor(color, semantic);
    return Text(
      'TrendSoccer',
      style: TsType.headingH3.copyWith(color: c),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = _logoAssetPath(context, type, color);
    if (path == null) {
      return _fallback(context);
    }

    return switch (type) {
      TsLogoType.horizon => SvgPicture.asset(
          path,
          height: height ?? 32,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          placeholderBuilder: (context) => _fallback(context),
        ),
      TsLogoType.vertical => SvgPicture.asset(
          path,
          height: height,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          placeholderBuilder: (context) => _fallback(context),
        ),
      TsLogoType.circle => SvgPicture.asset(
          path,
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => _fallback(context),
        ),
    };
  }
}
