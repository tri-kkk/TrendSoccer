import 'package:flutter/material.dart';

import '../../../../core/models/baseball_match_report.dart';
import '../../../../core/theme/tokens/color_tokens.dart';
import '../../../../core/theme/tokens/spacing_tokens.dart';
import '../../../../core/theme/tokens/typography_tokens.dart';
import '../../../../shared/widgets/baseball/line_row.dart';

/// Moneyline + over/under odds for a baseball matchup.
class BaseballOddsSection extends StatelessWidget {
  const BaseballOddsSection({
    super.key,
    required this.awayWinOdds,
    required this.homeWinOdds,
    required this.oddsLines,
  });

  final String awayWinOdds;
  final String homeWinOdds;
  final List<OddsLineData> oddsLines;

  static final TextStyle _winLabelStyle = AppTypography.labelSmall.copyWith(
    color: AppColors.textTertiary,
  );

  static final TextStyle _winValueBase = AppTypography.headlineSmall.copyWith(
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Odds',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _WinOddsBox(
                      label: 'Away',
                      value: awayWinOdds,
                      valueColor: AppColors.errorRed500,
                      labelStyle: _winLabelStyle,
                      valueBaseStyle: _winValueBase,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _WinOddsBox(
                      label: 'Home',
                      value: homeWinOdds,
                      valueColor: AppColors.primary500,
                      labelStyle: _winLabelStyle,
                      valueBaseStyle: _winValueBase,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Over / Under',
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Line',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Over',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.errorRed500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Under',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < oddsLines.length; i++) ...[
                    LineRow(
                      line: oddsLines[i].line,
                      isBaseLine: oddsLines[i].isBaseLine,
                      overOdds: oddsLines[i].overOdds,
                      underOdds: oddsLines[i].underOdds,
                    ),
                    if (i < oddsLines.length - 1) ...[
                      const SizedBox(height: AppSpacing.md),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WinOddsBox extends StatelessWidget {
  const _WinOddsBox({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelStyle,
    required this.valueBaseStyle,
  });

  final String label;
  final String value;
  final Color valueColor;
  final TextStyle labelStyle;
  final TextStyle valueBaseStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, textAlign: TextAlign.center, style: labelStyle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            textAlign: TextAlign.center,
            style: valueBaseStyle.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
