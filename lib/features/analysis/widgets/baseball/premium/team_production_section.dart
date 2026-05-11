import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/gauge_card.dart';

class GaugeData {
  const GaugeData({
    required this.label,
    required this.homeRatio,
  });

  final String label;
  final double homeRatio;
}

class TeamProductionSection extends StatelessWidget {
  const TeamProductionSection({
    required this.runs,
    required this.runsAllowed,
    required this.hits,
    this.footerText = '최근 10경기 팀 공격 생산성 지표입니다.',
    super.key,
  });

  final GaugeData runs;
  final GaugeData runsAllowed;
  final GaugeData hits;
  final String footerText;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '팀 생산성',
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              '최근 10경기',
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ],
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GaugeCard(label: runs.label, homeRatio: runs.homeRatio),
                  const SizedBox(height: TsSpacing.sm),
                  GaugeCard(label: runsAllowed.label, homeRatio: runsAllowed.homeRatio),
                  const SizedBox(height: TsSpacing.sm),
                  GaugeCard(label: hits.label, homeRatio: hits.homeRatio),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: TsSpacing.lg,
                  vertical: TsSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: semantic.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  footerText,
                  style: TsType.bodyMRegular.copyWith(
                    color: semantic.interactivePrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
