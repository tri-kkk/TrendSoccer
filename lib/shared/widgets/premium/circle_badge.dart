import 'package:flutter/material.dart';

import '../../../core/models/premium_models.dart';
import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// A 56×56 circular badge that summarises a match result with a [count].
///
/// ```dart
/// CircleBadge(result: MatchResult.win, count: 99)
/// CircleBadge(result: MatchResult.draw, count: 3)
/// CircleBadge(result: MatchResult.lose, count: 12)
/// ```
class CircleBadge extends StatelessWidget {
  const CircleBadge({
    super.key,
    required this.result,
    required this.count,
    this.size = 64.0,
  });

  final MatchResult result;
  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgroundColor(result),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label(result),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$count',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static Color _backgroundColor(MatchResult result) => switch (result) {
        MatchResult.win => AppColors.primary500,
        MatchResult.draw => AppColors.surfaceContainer,
        MatchResult.lose => AppColors.errorRed500,
      };

  static String _label(MatchResult result) => switch (result) {
        MatchResult.win => 'Win',
        MatchResult.draw => 'Draw',
        MatchResult.lose => 'Lose',
      };
}
