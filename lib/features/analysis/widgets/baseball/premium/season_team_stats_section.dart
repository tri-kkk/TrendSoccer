import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/premium/team_stat_gauge_card.dart';

class SeasonTeamStatsSection extends StatelessWidget {
  const SeasonTeamStatsSection({
    required this.items,
    super.key,
  });

  final List<GaugeData> items;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: TeamStatGaugeCard(data: items[0])),
                  const SizedBox(width: 8),
                  Expanded(child: TeamStatGaugeCard(data: items[1])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TeamStatGaugeCard(data: items[2])),
                  const SizedBox(width: 8),
                  Expanded(child: TeamStatGaugeCard(data: items[3])),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
