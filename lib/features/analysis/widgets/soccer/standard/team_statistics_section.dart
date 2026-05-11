import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/report/ratio_bar.dart';

class TeamStatItem {
  const TeamStatItem({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    required this.homeDisplay,
    required this.awayDisplay,
  });

  final String label;
  final double homeValue;
  final double awayValue;
  final String homeDisplay;
  final String awayDisplay;
}

class TeamStatisticsSection extends StatelessWidget {
  const TeamStatisticsSection({required this.stats, super.key});

  final List<TeamStatItem> stats;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '팀 상세 통계',
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
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.md),
                _TeamStatRow(stat: stats[i], semantic: semantic),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamStatRow extends StatelessWidget {
  const _TeamStatRow({
    required this.stat,
    required this.semantic,
  });

  final TeamStatItem stat;
  final TsSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stat.homeDisplay,
              style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
            ),
            Text(
              stat.label,
              style: TsType.labelSRegular.copyWith(
                color: semantic.textTertiary,
              ),
            ),
            Text(
              stat.awayDisplay,
              style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.xs),
        RatioBar(
          segments: [
            RatioSegment(
              flex: stat.homeValue,
              color: semantic.interactivePrimary,
            ),
            RatioSegment(
              flex: stat.awayValue,
              color: TsColors.systemError500,
            ),
          ],
          height: 8,
          showLabels: false,
        ),
      ],
    );
  }
}
