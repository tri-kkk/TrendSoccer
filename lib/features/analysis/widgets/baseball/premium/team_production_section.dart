import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/premium/team_stat_gauge_card.dart';

class TeamProductionSection extends StatelessWidget {
  const TeamProductionSection({
    required this.items,
    this.comment = '최근 10경기 팀 공격 생산성 지표입니다.',
    super.key,
  });

  final List<GaugeData> items;
  final String comment;

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
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                TeamStatGaugeCard(data: items[i]),
              ],
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: semantic.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  comment,
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
