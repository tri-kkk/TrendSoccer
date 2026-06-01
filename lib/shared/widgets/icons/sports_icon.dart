import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';

enum SportsIconFill { primary, onPrimary }

class TsSportsIcon extends StatelessWidget {
  const TsSportsIcon({
    required this.sport,
    this.fill = SportsIconFill.primary,
    this.size = 24,
    this.color,
    super.key,
  });

  final SportType sport;
  final SportsIconFill fill;
  final double size;
  final Color? color;

  static String _assetPath(SportType sport, SportsIconFill fill) {
    return switch ((sport, fill)) {
      (SportType.soccer, SportsIconFill.primary) => TsAssets.sportSoccerPrimary,
      (SportType.soccer, SportsIconFill.onPrimary) =>
        TsAssets.sportSoccerOnPrimary,
      (SportType.baseball, SportsIconFill.primary) =>
        TsAssets.sportBaseballPrimary,
      (SportType.baseball, SportsIconFill.onPrimary) =>
        TsAssets.sportBaseballOnPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath(sport, fill),
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
