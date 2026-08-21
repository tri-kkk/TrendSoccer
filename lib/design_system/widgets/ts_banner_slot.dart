import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';

enum TsBannerRatio { h50, h160, h214 }

class TsBannerSlot extends StatelessWidget {
  const TsBannerSlot({
    this.ratio = TsBannerRatio.h50,
    this.child,
    super.key,
  });

  final TsBannerRatio ratio;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final double? width;
    final double height;
    final double iconSize;
    switch (ratio) {
      case TsBannerRatio.h50:
        width = 320;
        height = 50;
        iconSize = TsIconSize.md;
      case TsBannerRatio.h160:
        width = null;
        height = 160;
        iconSize = TsIconSize.lg;
      case TsBannerRatio.h214:
        width = null;
        height = 214;
        iconSize = TsIconSize.lg;
    }

    final banner = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: TsRadius.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: child ??
          TsIcon(
            TsIcons.imageNotSupported,
            size: iconSize,
            color: c.textTertiary,
          ),
    );

    if (ratio == TsBannerRatio.h50) {
      return Center(child: banner);
    }
    return banner;
  }
}
