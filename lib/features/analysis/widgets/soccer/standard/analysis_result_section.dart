import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/badge/ts_badge.dart';
import 'package:trendsoccer/shared/widgets/report/info_cell.dart';

class AnalysisResultSection extends StatelessWidget {
  const AnalysisResultSection({
    required this.prediction,
    required this.winProbability,
    required this.powerDiff,
    required this.analyzedMatches,
    required this.patternStats,
    required this.gradeBadgeType,
    super.key,
  });

  final String prediction;
  final String winProbability;
  final String powerDiff;
  final String analyzedMatches;
  final String patternStats;
  final String gradeBadgeType;

  static TsBadgeType _badgeType(String raw) {
    return switch (raw) {
      'pick' => TsBadgeType.pick,
      'good' => TsBadgeType.good,
      'pass' => TsBadgeType.pass,
      _ => TsBadgeType.pick,
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '분석 결과',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InfoCell(value: prediction, label: '예측'),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: InfoCell(
                      value: winProbability,
                      label: '승리 확률',
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: InfoCell(value: powerDiff, label: '파워차'),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: InfoCell(
                      value: analyzedMatches,
                      label: '분석 경기',
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: InfoCell(
                      value: patternStats,
                      label: '패턴 통계',
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: InfoCell(
                      value: '',
                      label: '추천',
                      valueWidget: TsBadge(type: _badgeType(gradeBadgeType)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
