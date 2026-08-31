import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/widgets/ts_team_emblem.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsMatchHero extends StatelessWidget {
  const TsMatchHero({
    required this.leagueId,
    required this.homeTeam,
    required this.awayTeam,
    this.homeEmblemUrl,
    this.awayEmblemUrl,
    this.centerLabel,
    this.subLabel,
    super.key,
  });

  final String leagueId;
  final String homeTeam;
  final String awayTeam;
  final String? homeEmblemUrl;
  final String? awayEmblemUrl;
  final String? centerLabel;
  final String? subLabel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    Widget teamColumn(String? emblemUrl, String name) {
      return Column(
        children: [
          TsTeamEmblem(emblemUrl, size: TsIconSize.lg),
          const SizedBox(height: TsSpacing.sm),
          Text(
            name,
            style: TsType.bodyLBold.copyWith(color: c.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: TsSpacing.xl,
        horizontal: TsSpacing.md,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: TsLeagueIcon(leagueId, size: TsIconSize.md)),
          const SizedBox(height: TsSpacing.lg),
          Row(
            children: [
              Expanded(child: teamColumn(homeEmblemUrl, homeTeam)),
              const SizedBox(width: TsSpacing.md),
              Column(
                children: [
                  if (centerLabel != null)
                    Text(
                      centerLabel!,
                      style: TsType.tabular(
                        TsType.h1.copyWith(color: c.textPrimary),
                      ),
                    ),
                  if (subLabel != null) ...[
                    const SizedBox(height: TsSpacing.xs),
                    Text(
                      subLabel!,
                      style: TsType.labelSMedium.copyWith(color: c.textTertiary),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: TsSpacing.md),
              Expanded(child: teamColumn(awayEmblemUrl, awayTeam)),
            ],
          ),
        ],
      ),
    );
  }
}
