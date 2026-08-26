import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/widgets/ts_team_emblem.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_status_badge.dart';

enum TsMatchRowStatus { scheduled, live, finished }

class TsMatchRow extends StatelessWidget {
  const TsMatchRow({
    required this.homeTeam,
    required this.awayTeam,
    required this.timeLabel,
    this.status = TsMatchRowStatus.scheduled,
    this.homeScore,
    this.awayScore,
    this.homeEmblemUrl,
    this.awayEmblemUrl,
    this.hasAnalysis = false,
    this.analysisLabel = 'AI',
    this.alarmOn,
    this.onAlarmTap,
    this.onTap,
    super.key,
  });

  final String homeTeam;
  final String awayTeam;
  final String timeLabel;
  final TsMatchRowStatus status;
  final String? homeScore;
  final String? awayScore;
  final String? homeEmblemUrl;
  final String? awayEmblemUrl;
  final bool hasAnalysis;
  final String analysisLabel;
  final bool? alarmOn;
  final VoidCallback? onAlarmTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final showScores =
        status == TsMatchRowStatus.live || status == TsMatchRowStatus.finished;

    Widget teamRow({
      required String letter,
      required String? emblemUrl,
      required String name,
      required String? score,
    }) {
      return SizedBox(
        height: 20,
        child: Row(
          children: [
            SizedBox(
              width: 12,
              child: Text(
                letter,
                style: TsType.labelXsBold.copyWith(color: c.textTertiary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: TsSpacing.sm),
            TsTeamEmblem(emblemUrl, size: TsIconSize.sm),
            const SizedBox(width: TsSpacing.sm),
            Expanded(
              child: Text(
                name,
                style: TsType.bodyMMedium.copyWith(color: c.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showScores)
              SizedBox(
                width: 24,
                child: Text(
                  score ?? '',
                  style: TsType.tabular(
                    TsType.bodyMBold.copyWith(color: c.textPrimary),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
      );
    }

    Widget alarmSlot() {
      const slot = SizedBox(width: 20, height: 20);
      if (status == TsMatchRowStatus.finished || alarmOn == null) {
        return slot;
      }
      return GestureDetector(
        onTap: onAlarmTap,
        child: TsIcon(
          alarmOn! ? TsIcons.notifications : TsIcons.notificationsNone,
          size: TsIconSize.sm,
          color: alarmOn! ? c.primary : c.textTertiary,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: TsSpacing.sm,
            children: [
              Expanded(
                child: Text(
                  timeLabel,
                  style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
                ),
              ),
              if (hasAnalysis)
                TsBadge(label: analysisLabel, tone: TsBadgeTone.primary),
              if (status == TsMatchRowStatus.live)
                const TsStatusBadge(TsMatchStatus.live),
            ],
          ),
          const SizedBox(height: TsSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    teamRow(
                      letter: 'H',
                      emblemUrl: homeEmblemUrl,
                      name: homeTeam,
                      score: homeScore,
                    ),
                    const SizedBox(height: TsSpacing.xs),
                    teamRow(
                      letter: 'A',
                      emblemUrl: awayEmblemUrl,
                      name: awayTeam,
                      score: awayScore,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              alarmSlot(),
            ],
          ),
        ],
      ),
    );
  }
}
