import 'package:flutter/material.dart';

import '../../../core/models/premium_models.dart';
import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';

/// A column showing a team emblem placeholder and a color-coded score box.
///
/// ```dart
/// ScoreBox(result: MatchResult.win, homeScore: 1, awayScore: 0)
/// ScoreBox(result: MatchResult.draw, homeScore: 2, awayScore: 2)
/// ScoreBox(result: MatchResult.lose, homeScore: 0, awayScore: 3)
/// ```
class ScoreBox extends StatelessWidget {
  const ScoreBox({
    super.key,
    required this.result,
    required this.homeScore,
    required this.awayScore,
  });

  final MatchResult result;
  final int homeScore;
  final int awayScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.surfaceContainer,
          child: Icon(
            Icons.sports_soccer,
            size: 16,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        // Score container
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _backgroundColor(result),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '$homeScore-$awayScore',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  static Color _backgroundColor(MatchResult result) => switch (result) {
        MatchResult.win => AppColors.primary500,
        MatchResult.draw => AppColors.surfaceContainer,
        MatchResult.lose => AppColors.errorRed500,
      };
}
