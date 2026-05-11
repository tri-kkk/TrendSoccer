import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/premium/team_production_section.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/gauge_card.dart';

class SeasonTeamStatsSection extends StatelessWidget {
  const SeasonTeamStatsSection({
    required this.avg,
    required this.ops,
    required this.era,
    required this.whip,
    super.key,
  });

  final GaugeData avg;
  final GaugeData ops;
  final GaugeData era;
  final GaugeData whip;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시즌 팀 통계',
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GaugeCard(
                      label: 'AVG',
                      homeRatio: avg.homeRatio,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: GaugeCard(
                      label: 'OPS',
                      homeRatio: ops.homeRatio,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: GaugeCard(
                      label: 'ERA',
                      homeRatio: era.homeRatio,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: GaugeCard(
                      label: 'WHIP',
                      homeRatio: whip.homeRatio,
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
