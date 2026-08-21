import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
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
    this.pickEmblemId,
    this.resultLabel,
    this.resultTone = TsBadgeTone.positive,
    this.homeFraction,
    this.drawFraction,
    this.awayFraction,
    this.homeLabel,
    this.drawLabel,
    this.awayLabel,
    super.key,
  });

  final String pickTeam;
  final String probabilityLabel;
  final String? pickEmblemId;
  final String? resultLabel;
  final TsBadgeTone resultTone;
  final double? homeFraction;
  final double? drawFraction;
  final double? awayFraction;
  final String? homeLabel;
  final String? drawLabel;
  final String? awayLabel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final emblem = pickEmblemId != null
        ? TsLeagueIcon(pickEmblemId!, size: TsSpacing.xl)
        : TsIcon(
            TsIcons.imageNotSupported,
            size: TsSpacing.xl,
            color: c.textTertiary,
          );

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
            homeLabel: homeLabel,
            drawLabel: drawLabel,
            awayLabel: awayLabel,
          ),
        ],
      ],
    );
  }
}
