import 'package:flutter/material.dart';

import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/spacing_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import 'h2h_badge.dart';

/// One head-to-head result line: date, teams, scores, optional win badge.
class H2hMatchupRow extends StatelessWidget {
  const H2hMatchupRow({
    super.key,
    required this.date,
    required this.awayTeam,
    required this.homeTeam,
    required this.awayScore,
    required this.homeScore,
    this.winner,
  });

  /// Short date label (e.g. `'4.22'`).
  final String date;

  final String awayTeam;
  final String homeTeam;
  final int awayScore;
  final int homeScore;

  /// `'away'`, `'home'`, or `null` when undecided / no badge.
  final String? winner;

  bool get _awayWon => winner?.toLowerCase() == 'away';
  bool get _homeWon => winner?.toLowerCase() == 'home';

  @override
  Widget build(BuildContext context) {
    final labelSmall = AppTypography.labelSmall;
    final dateStyle = labelSmall.copyWith(color: AppColors.textTertiary);
    final primaryStyle = labelSmall.copyWith(color: AppColors.textPrimary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: dateStyle,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  awayTeam,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: primaryStyle,
                ),
              ),
              if (_awayWon) ...[
                const SizedBox(width: AppSpacing.xs),
                const H2hBadge(isHome: false),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text('$awayScore - $homeScore', style: primaryStyle),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              if (_homeWon) ...[
                const H2hBadge(isHome: true),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  homeTeam,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: primaryStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
