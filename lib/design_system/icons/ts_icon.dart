import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';

class TsIcon extends StatelessWidget {
  const TsIcon(this.spec, {this.size = 24, this.color, super.key});

  final TsIconSpec spec;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ??
        Theme.of(context).extension<TsThemeColors>()!.textPrimary;

    return switch (spec) {
      TsGlyph(:final icon) => Icon(icon, size: size, color: resolved),
      TsAssetIcon(:final path) => SvgPicture.asset(
          path,
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
        ),
    };
  }
}
