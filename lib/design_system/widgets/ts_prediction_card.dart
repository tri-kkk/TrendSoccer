import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/widgets/ts_team_emblem.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_gauge_bar.dart';

class TsPredictionCard extends StatelessWidget {
  const TsPredictionCard({
    required this.pickTeam,
    required this.probabilityLabel,
    this.pickEmblemUrl,
    this.resultLabel,
    this.resultTone = TsBadgeTone.positive,
    this.homeFraction,
    this.drawFraction,
    this.awayFraction,
    this.homeLabel,
    this.drawLabel,
    this.awayLabel,
    this.line = TsGaugeLine.threeWay,
    super.key,
  });

  final String pickTeam;
  final String probabilityLabel;
  final String? pickEmblemUrl;
  final String? resultLabel;
  final TsBadgeTone resultTone;
  final double? homeFraction;
  final double? drawFraction;
  final double? awayFraction;
  final String? homeLabel;
  final String? drawLabel;
  final String? awayLabel;
  final TsGaugeLine line;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final emblem = TsTeamEmblem(pickEmblemUrl, size: TsIconSize.md);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(
            vertical: TsSpacing.sm,
            horizontal: TsSpacing.md,
          ),
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: TsRadius.sm,
          ),
          child: Row(
            children: [
              emblem,
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: Text(
                  pickTeam,
                  style: TsType.bodyLBold.copyWith(color: c.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (resultLabel != null) ...[
                TsBadge(label: resultLabel!, tone: resultTone),
                const SizedBox(width: TsSpacing.sm),
              ],
              Text(
                probabilityLabel,
                style: TsType.tabular(
                  TsType.h3.copyWith(color: c.primary),
                ),
              ),
            ],
          ),
        ),
        if (homeFraction != null) ...[
          const SizedBox(height: TsSpacing.md),
          TsGaugeBar(
            home: homeFraction!,
            draw: drawFraction ?? 0,
            away: awayFraction ?? 0,
            line: line,
            homeLabel: homeLabel,
            drawLabel: drawLabel,
            awayLabel: awayLabel,
          ),
        ],
      ],
    );
  }
}
