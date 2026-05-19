import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

/// 번들 에셋: `ic_soccer.svg` / `ic_baseball.svg` (`assets/images/icon/`).
enum SportsIconFill { primary, onPrimary }

class TsSportsIcon extends StatelessWidget {
  const TsSportsIcon({
    required this.sport,
    this.fill = SportsIconFill.primary,
    this.size = 24,
    super.key,
  });

  final SportType sport;
  final SportsIconFill fill;
  final double size;

  static String _assetPath(SportType sport) {
    return switch (sport) {
      SportType.soccer => 'assets/images/icon/ic_soccer.svg',
      SportType.baseball => 'assets/images/icon/ic_baseball.svg',
    };
  }

  Color _foreground(TsSemanticColors semantic) {
    return switch (fill) {
      SportsIconFill.primary => semantic.interactivePrimary,
      SportsIconFill.onPrimary => semantic.surfaceBase,
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final color = _foreground(semantic);

    return SvgPicture.asset(
      _assetPath(sport),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
