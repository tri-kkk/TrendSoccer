import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/widgets/ts_team_emblem.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsH2HMatchRow extends StatelessWidget {
  const TsH2HMatchRow({
    required this.dateLabel,
    required this.homeTeam,
    required this.awayTeam,
    required this.scoreLabel,
    this.homeEmblemUrl,
    this.awayEmblemUrl,
    super.key,
  });

  final String dateLabel;
  final String homeTeam;
  final String awayTeam;
  final String scoreLabel;
  final String? homeEmblemUrl;
  final String? awayEmblemUrl;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dateLabel,
            style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        homeTeam,
                        style: TsType.bodyMMedium.copyWith(
                          color: c.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: TsSpacing.xs),
                    TsTeamEmblem(homeEmblemUrl, size: TsIconSize.xs),
                  ],
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Text(
                scoreLabel,
                style: TsType.tabular(
                  TsType.bodyMBold.copyWith(color: c.textPrimary),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Row(
                  children: [
                    TsTeamEmblem(awayEmblemUrl, size: TsIconSize.xs),
                    const SizedBox(width: TsSpacing.xs),
                    Expanded(
                      child: Text(
                        awayTeam,
                        style: TsType.bodyMMedium.copyWith(
                          color: c.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
