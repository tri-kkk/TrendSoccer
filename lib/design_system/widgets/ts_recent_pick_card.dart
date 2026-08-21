import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';

class TsRecentPickCard extends StatelessWidget {
  const TsRecentPickCard({
    required this.leagueId,
    required this.leagueLabel,
    required this.dateLabel,
    required this.homeTeam,
    required this.awayTeam,
    required this.pickedTeam,
    required this.resultLabel,
    required this.resultTone,
    this.leagueIcon,
    this.homeScore,
    this.awayScore,
    this.homeEmblemId,
    this.awayEmblemId,
    this.onTap,
    super.key,
  });

  final String leagueId;
  final String leagueLabel;
  final String dateLabel;
  final String homeTeam;
  final String awayTeam;
  final String pickedTeam;
  final String resultLabel;
  final TsBadgeTone resultTone;
  final Widget? leagueIcon;
  final String? homeScore;
  final String? awayScore;
  final String? homeEmblemId;
  final String? awayEmblemId;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    Widget emblem(String? id) => id != null
        ? TsLeagueIcon(id, size: TsIconSize.xs)
        : TsIcon(
            TsIcons.imageNotSupported,
            size: TsIconSize.xs,
            color: c.textTertiary,
          );

    Widget teamRow(String? emblemId, String name, String? score) {
      return SizedBox(
        height: 18,
        child: Row(
          children: [
            emblem(emblemId),
            const SizedBox(width: TsSpacing.xs),
            Expanded(
              child: Text(
                name,
                style: TsType.bodyMMedium.copyWith(color: c.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (score != null)
              Text(
                score,
                style: TsType.tabular(
                  TsType.bodyMBold.copyWith(color: c.textPrimary),
                ),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(TsSpacing.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: TsRadius.md,
          border: Border.all(color: c.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                leagueIcon ?? TsLeagueIcon(leagueId, size: TsIconSize.xs),
                const SizedBox(width: TsSpacing.xs),
                Expanded(
                  child: Text(
                    leagueLabel,
                    style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateLabel,
                  style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: TsSpacing.sm),
            Column(
              children: [
                teamRow(homeEmblemId, homeTeam, homeScore),
                const SizedBox(height: TsSpacing.xs),
                teamRow(awayEmblemId, awayTeam, awayScore),
              ],
            ),
            const SizedBox(height: TsSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    pickedTeam,
                    style: TsType.labelXsBold.copyWith(color: c.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: TsSpacing.xs),
                TsBadge(label: resultLabel, tone: resultTone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
