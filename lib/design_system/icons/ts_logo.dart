import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';

enum TsLogoType { horizon, vertical, symbol, editor }

class TsLogo extends StatelessWidget {
  const TsLogo(this.type, {this.height = 32, super.key});

  final TsLogoType type;
  final double height;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final path = switch (type) {
      TsLogoType.horizon => TsAssets.logoHorizon(brightness),
      TsLogoType.vertical => TsAssets.logoVertical(brightness),
      TsLogoType.symbol => TsAssets.logoSymbol(brightness),
      TsLogoType.editor => TsAssets.logoEditor(brightness),
    };
    return SvgPicture.asset(path, height: height);
  }
}
