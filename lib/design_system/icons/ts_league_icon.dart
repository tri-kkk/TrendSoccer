import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

class TsLeagueIcon extends StatelessWidget {
  const TsLeagueIcon(this.leagueId, {this.size = TsIconSize.xs, super.key});

  final String leagueId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path =
        TsAssets.leagueIcon(leagueId, Theme.of(context).brightness);
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
    );
  }
}

class TsLeagueLogo extends StatelessWidget {
  const TsLeagueLogo(this.leagueId, {this.height = 40, super.key});

  final String leagueId;
  final double height;

  @override
  Widget build(BuildContext context) {
    final path =
        TsAssets.leagueLogo(leagueId, Theme.of(context).brightness);
    return SvgPicture.asset(
      path,
      height: height,
      errorBuilder: (_, _, _) => SizedBox(height: height),
    );
  }
}
