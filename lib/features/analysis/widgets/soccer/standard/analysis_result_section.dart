import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/badge/ts_badge.dart';

class AnalysisResultSection extends StatelessWidget {
  const AnalysisResultSection({
    required this.prediction,
    required this.winProbability,
    required this.powerDiff,
    required this.gradeBadgeType,
    required this.analysisMatchCount,
    required this.patternMatchCount,
    super.key,
  });

  final String prediction;
  final String winProbability;
  final String powerDiff;
  final String gradeBadgeType;
  final String analysisMatchCount;
  final String patternMatchCount;

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
                  _ResultGridCell(
                    label: '예측',
                    value: prediction,
                    semantic: semantic,
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  _ResultGridCell(
                    label: '승리 확률',
                    value: winProbability,
                    semantic: semantic,
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  _ResultGridCell(
                    label: '파워차',
                    value: powerDiff,
                    semantic: semantic,
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.sm),
              Row(
                children: [
                  _ResultGridCell(
                    label: '분석 경기',
                    value: analysisMatchCount,
                    semantic: semantic,
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  _ResultGridCell(
                    label: '패턴 통계',
                    value: patternMatchCount,
                    semantic: semantic,
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  _ResultGridCell(
                    label: '추천',
                    value: '',
                    semantic: semantic,
                    valueWidget: TsBadge(type: _badgeType(gradeBadgeType)),
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

class _ResultGridCell extends StatelessWidget {
  const _ResultGridCell({
    required this.label,
    required this.value,
    required this.semantic,
    this.valueWidget,
  });

  final String label;
  final String value;
  final TsSemanticColors semantic;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(TsSpacing.sm),
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TsSpacing.sm),
            valueWidget ??
                Text(
                  value,
                  style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                  textAlign: TextAlign.center,
                ),
          ],
        ),
      ),
    );
  }
}
