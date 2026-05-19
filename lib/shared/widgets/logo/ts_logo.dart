import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum TsLogoType { horizon, vertical, circle }

enum TsLogoColor { white, black, gradient, editor }

final Map<String, Future<String?>> _logoSvgFutures = {};

Future<String?> _loadLogoSvg(String path) =>
    _logoSvgFutures.putIfAbsent(path, () async {
      try {
        return await rootBundle.loadString(path);
      } catch (_) {
        return null;
      }
    });

String? _logoAssetPath(TsLogoType type, TsLogoColor color) {
  switch (type) {
    case TsLogoType.circle:
      return TsAssets.logoEditor(Brightness.dark);
    case TsLogoType.horizon:
      switch (color) {
        case TsLogoColor.white:
          return TsAssets.logoHorizon(Brightness.light);
        case TsLogoColor.black:
          return TsAssets.logoHorizon(Brightness.dark);
        case TsLogoColor.gradient:
          return TsAssets.logoHorizon(Brightness.dark);
        case TsLogoColor.editor:
          return null;
      }
    case TsLogoType.vertical:
      switch (color) {
        case TsLogoColor.white:
          return TsAssets.logoVertical(Brightness.light);
        case TsLogoColor.black:
          return TsAssets.logoVertical(Brightness.dark);
        case TsLogoColor.gradient:
          return TsAssets.logoVertical(Brightness.dark);
        case TsLogoColor.editor:
          return null;
      }
  }
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
    super.key,
  });

  final TsLogoType type;
  final TsLogoColor color;

  Widget _fallback(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final c = _logoFallbackTextColor(color, semantic);
    return Text(
      'TrendSoccer',
      style: TsType.headingH3.copyWith(color: c),
    );
  }

  Widget _svgWidget({
    required BuildContext context,
    required String svg,
  }) {
    return switch (type) {
      TsLogoType.horizon => SvgPicture.string(
          svg,
          height: 32,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          placeholderBuilder: (BuildContext context) => _fallback(context),
        ),
      TsLogoType.vertical => SvgPicture.string(
          svg,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          placeholderBuilder: (BuildContext context) => _fallback(context),
        ),
      TsLogoType.circle => SvgPicture.string(
          svg,
          width: 40,
          height: 40,
          fit: BoxFit.contain,
          placeholderBuilder: (BuildContext context) => _fallback(context),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final path = _logoAssetPath(type, color);
    if (path == null) {
      return _fallback(context);
    }

    return FutureBuilder<String?>(
      future: _loadLogoSvg(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return switch (type) {
            TsLogoType.horizon => const SizedBox(height: 32),
            TsLogoType.vertical => const SizedBox(height: 32),
            TsLogoType.circle => const SizedBox(width: 40, height: 40),
          };
        }
        final svg = snapshot.data;
        if (svg == null || svg.isEmpty) {
          return _fallback(context);
        }
        return _svgWidget(context: context, svg: svg);
      },
    );
  }
}
