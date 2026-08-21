import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_gauge_bar.dart';

enum TsComboPick { home, away }

class TsComboLegRow extends StatelessWidget {
  const TsComboLegRow({
    required this.homeTeam,
    required this.awayTeam,
    required this.pick,
    required this.pickText,
    required this.probabilityLabel,
    required this.indexLabel,
    required this.probability,
    this.baseline,
    this.timeLabel,
    this.scoreLabel,
    this.reason,
    this.homeEmblemId,
    this.awayEmblemId,
    this.analysisCaption = 'Analysis',
    this.indexCaption = 'Index',
    super.key,
  });

  final String homeTeam;
  final String awayTeam;
  final TsComboPick pick;
  final String pickText;
  final String probabilityLabel;
  final String indexLabel;
  final double probability;
  final double? baseline;
  final String? timeLabel;
  final String? scoreLabel;
  final String? reason;
  final String? homeEmblemId;
  final String? awayEmblemId;
  final String analysisCaption;
  final String indexCaption;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    Widget emblem(String? id) => id != null
        ? TsLeagueIcon(id, size: 40)
        : TsIcon(TsIcons.imageNotSupported, size: 40, color: c.textTertiary);

    Widget teamColumn(String? emblemId, String name, bool picked) {
      return Column(
        children: [
          emblem(emblemId),
          const SizedBox(height: TsSpacing.xs),
          Text(
            name,
            style: (picked ? TsType.bodyMBold : TsType.bodyMMedium).copyWith(
              color: picked ? c.textPrimary : c.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: teamColumn(
                homeEmblemId,
                homeTeam,
                pick == TsComboPick.home,
              ),
            ),
            const SizedBox(width: TsSpacing.md),
            Column(
              children: [
                if (timeLabel != null)
                  Text(
                    timeLabel!,
                    style: TsType.labelXsMedium.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                if (scoreLabel != null) ...[
                  if (timeLabel != null) const SizedBox(height: TsSpacing.xxs),
                  Text(
                    scoreLabel!,
                    style: TsType.tabular(
                      TsType.h2.copyWith(color: c.textPrimary),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: TsSpacing.md),
            Expanded(
              child: teamColumn(
                awayEmblemId,
                awayTeam,
                pick == TsComboPick.away,
              ),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  analysisCaption,
                  style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
                ),
                const SizedBox(width: TsSpacing.xs),
                Text(
                  pickText,
                  style: TsType.bodyMBold.copyWith(color: c.textPrimary),
                ),
                const SizedBox(width: TsSpacing.xs),
                TsBadge(label: probabilityLabel, tone: TsBadgeTone.primary),
              ],
            ),
            Row(
              children: [
                Text(
                  indexCaption,
                  style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
                ),
                const SizedBox(width: TsSpacing.xs),
                Text(
                  indexLabel,
                  style: TsType.tabular(
                    TsType.bodyMBold.copyWith(color: c.dataPositive),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.sm),
        TsGaugeBar(
          home: probability,
          line: TsGaugeLine.oneWay,
          baseline: baseline,
          showValues: false,
        ),
        if (reason != null) ...[
          const SizedBox(height: TsSpacing.sm),
          Text(
            reason!,
            style: TsType.labelSRegular.copyWith(color: c.textTertiary),
          ),
        ],
      ],
    );
  }
}
