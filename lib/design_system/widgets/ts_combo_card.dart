import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_ai_report_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_footer.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_leg_row.dart';

class TsComboLeg {
  const TsComboLeg({
    required this.pick,
    required this.homeTeamLabel,
    required this.awayTeamLabel,
    required this.timeLabel,
    required this.scoreLabel,
    required this.pickTextLabel,
    required this.probabilityLabel,
    required this.indexLabel,
    required this.probability,
    this.reasonLabel,
    this.baseline,
  });

  final TsComboPick pick;
  final String homeTeamLabel;
  final String awayTeamLabel;
  final String timeLabel;
  final String scoreLabel;
  final String pickTextLabel;
  final String indexLabel;
  final String? reasonLabel;
  final String probabilityLabel;
  final double probability;
  final double? baseline;
}

class TsAiReportData {
  const TsAiReportData({
    required this.titleLabel,
    required this.summaryLabel,
    required this.legs,
    required this.caution,
    required this.cautionLabel,
    required this.disclaimerLabel,
  });

  final String titleLabel;
  final String summaryLabel;
  final List<TsAiReportLeg> legs;
  final String caution;
  final String cautionLabel;
  final String disclaimerLabel;
}

class TsComboCard extends StatelessWidget {
  const TsComboCard({
    required this.leagueIcon,
    required this.leagueLabel,
    required this.typeBadgeLabel,
    required this.legs,
    required this.totalIndexLabel,
    required this.confidenceLabel,
    required this.result,
    this.aiReport,
    super.key,
  });

  final Widget leagueIcon;
  final String leagueLabel;
  final String typeBadgeLabel;
  final List<TsComboLeg> legs;
  final String totalIndexLabel;
  final String confidenceLabel;
  final TsComboOutcome result;
  final TsAiReportData? aiReport;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, minHeight: 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(c),
          const SizedBox(height: TsSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < legs.length; i++) ...[
                if (i > 0) ...[
                  const SizedBox(height: TsSpacing.md),
                  Container(height: 1, color: c.borderSubtle),
                  const SizedBox(height: TsSpacing.md),
                ],
                TsComboLegRow(
                  homeTeam: legs[i].homeTeamLabel,
                  awayTeam: legs[i].awayTeamLabel,
                  pick: legs[i].pick,
                  pickText: legs[i].pickTextLabel,
                  probabilityLabel: legs[i].probabilityLabel,
                  indexLabel: legs[i].indexLabel,
                  probability: legs[i].probability,
                  baseline: legs[i].baseline,
                  timeLabel: legs[i].timeLabel,
                  scoreLabel: legs[i].scoreLabel,
                  reason: legs[i].reasonLabel,
                ),
              ],
            ],
          ),
          const SizedBox(height: TsSpacing.md),
          TsComboFooter(
            totalIndexLabel: totalIndexLabel,
            confidenceLabel: confidenceLabel,
            outcome: result,
          ),
          if (aiReport != null) ...[
            const SizedBox(height: TsSpacing.md),
            TsAiReportBlock(
              titleLabel: aiReport!.titleLabel,
              summaryLabel: aiReport!.summaryLabel,
              legs: aiReport!.legs,
              caution: aiReport!.caution,
              cautionLabel: aiReport!.cautionLabel,
              disclaimerLabel: aiReport!.disclaimerLabel,
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(TsThemeColors c) {
    return Row(
      children: [
        Row(
          children: [
            leagueIcon,
            const SizedBox(width: TsSpacing.xs),
            Text(
              leagueLabel,
              style: TsType.bodyMBold.copyWith(color: c.textPrimary),
            ),
          ],
        ),
        const Spacer(),
        TsBadge(label: typeBadgeLabel, tone: TsBadgeTone.primary),
      ],
    );
  }
}
