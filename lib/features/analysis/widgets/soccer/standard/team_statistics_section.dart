import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';

class TeamStatItem {
  const TeamStatItem({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    required this.homeDisplay,
    required this.awayDisplay,
    this.homeHighlighted = false,
    this.awayHighlighted = false,
  });

  final String label;
  final double homeValue;
  final double awayValue;
  final String homeDisplay;
  final String awayDisplay;
  final bool homeHighlighted;
  final bool awayHighlighted;
}

class TeamStatisticsSection extends StatelessWidget {
  const TeamStatisticsSection({
    required this.stats,
    this.showTitle = true,
    super.key,
  });

  final List<TeamStatItem> stats;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            l10n.soccerStatTeamStats,
            style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.sm),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
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
    final total = stat.homeValue + stat.awayValue;
    final homeRatio = total > 0 ? (stat.homeValue / total).clamp(0.0, 1.0) : 0.5;
    final awayRatio = total > 0 ? (stat.awayValue / total).clamp(0.0, 1.0) : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stat.homeDisplay,
              style: TsType.bodyMBold.copyWith(
                color: stat.homeHighlighted
                    ? semantic.interactivePrimary
                    : semantic.textPrimary,
              ),
            ),
            Text(
              stat.label,
              style: TsType.labelSRegular.copyWith(
                color: semantic.textTertiary,
              ),
            ),
            Text(
              stat.awayDisplay,
              style: TsType.bodyMBold.copyWith(
                color: stat.awayHighlighted
                    ? TsColors.systemError500
                    : semantic.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.xs),
        SizedBox(
          width: double.infinity,
          height: 8,
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(8),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: semantic.textDisabled),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: homeRatio,
                          heightFactor: 1,
                          alignment: Alignment.centerRight,
                          child: ColoredBox(color: semantic.interactivePrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(8),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: semantic.textDisabled),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: awayRatio,
                          heightFactor: 1,
                          alignment: Alignment.centerLeft,
                          child: ColoredBox(color: TsColors.systemError500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
