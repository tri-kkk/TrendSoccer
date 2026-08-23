import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/widgets/ts_team_emblem.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_status_badge.dart';

enum TsAnalysisStatus { scheduled, live, finished }

class TsAnalysisCard extends StatelessWidget {
  const TsAnalysisCard({
    required this.leagueId,
    required this.leagueLabel,
    required this.homeTeam,
    required this.awayTeam,
    this.status = TsAnalysisStatus.scheduled,
    this.homeEmblemUrl,
    this.awayEmblemUrl,
    this.centerLabel,
    this.subLabel,
    this.onTap,
    super.key,
  });

  final String leagueId;
  final String leagueLabel;
  final String homeTeam;
  final String awayTeam;
  final TsAnalysisStatus status;
  final String? homeEmblemUrl;
  final String? awayEmblemUrl;
  final String? centerLabel;
  final String? subLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    Widget teamColumn(String? emblemUrl, String name) {
      return Column(
        children: [
          TsTeamEmblem(emblemUrl, size: 32),
          const SizedBox(height: TsSpacing.xs),
          Text(
            name,
            style: TsType.bodyMMedium.copyWith(color: c.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    final centerStyle = TsType.tabular(
      (status == TsAnalysisStatus.scheduled ? TsType.h3 : TsType.h2)
          .copyWith(color: c.textPrimary),
    );
    final subColor =
        status == TsAnalysisStatus.live ? c.error : c.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: TsSpacing.md,
          horizontal: TsSpacing.lg,
        ),
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
                TsLeagueIcon(leagueId, size: TsIconSize.xs),
                const SizedBox(width: TsSpacing.sm),
                Expanded(
                  child: Text(
                    leagueLabel,
                    style: TsType.labelSMedium.copyWith(color: c.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (status == TsAnalysisStatus.live)
                  const TsStatusBadge(TsMatchStatus.live)
                else if (status == TsAnalysisStatus.finished)
                  const TsStatusBadge(TsMatchStatus.finished),
              ],
            ),
            const SizedBox(height: TsSpacing.md),
            Row(
              children: [
                Expanded(child: teamColumn(homeEmblemUrl, homeTeam)),
                const SizedBox(width: TsSpacing.sm),
                Column(
                  children: [
                    if (centerLabel != null)
                      Text(centerLabel!, style: centerStyle),
                    if (subLabel != null) ...[
                      const SizedBox(height: TsSpacing.xxs),
                      Text(
                        subLabel!,
                        style: TsType.labelXsMedium.copyWith(color: subColor),
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: TsSpacing.sm),
                Expanded(child: teamColumn(awayEmblemUrl, awayTeam)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
