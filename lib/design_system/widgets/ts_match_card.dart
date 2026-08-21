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
import 'package:trendsoccer/design_system/widgets/ts_lock_overlay.dart';

enum TsMatchCardDensity { card, list }

class TsMatchCard extends StatelessWidget {
  const TsMatchCard({
    required this.leagueId,
    required this.leagueLabel,
    required this.kickoffLabel,
    required this.homeTeam,
    required this.awayTeam,
    this.density = TsMatchCardDensity.card,
    this.homeEmblemId,
    this.awayEmblemId,
    this.hasAnalysis = false,
    this.analysisLabel = 'AI ANALYSIS',
    this.pickLabel,
    this.pickTone = TsBadgeTone.positive,
    this.probabilityLabel,
    this.locked = false,
    this.lockHeadline = 'Premium content',
    this.onTap,
    super.key,
  });

  final String leagueId;
  final String leagueLabel;
  final String kickoffLabel;
  final String homeTeam;
  final String awayTeam;
  final TsMatchCardDensity density;
  final String? homeEmblemId;
  final String? awayEmblemId;
  final bool hasAnalysis;
  final String analysisLabel;
  final String? pickLabel;
  final TsBadgeTone pickTone;
  final String? probabilityLabel;
  final bool locked;
  final String lockHeadline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    Widget emblem(String? id) => id != null
        ? TsLeagueIcon(id, size: TsIconSize.md)
        : TsIcon(
            TsIcons.imageNotSupported,
            size: TsIconSize.md,
            color: c.textTertiary,
          );

    Widget teamRow(String? emblemId, String name) {
      return SizedBox(
        height: TsSpacing.xl,
        child: Row(
          children: [
            emblem(emblemId),
            const SizedBox(width: TsSpacing.sm),
            Expanded(
              child: Text(
                name,
                style: TsType.bodyMMedium.copyWith(color: c.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget? prediction;
    if (density == TsMatchCardDensity.list && pickLabel != null) {
      final block = Container(
        height: 34,
        padding: const EdgeInsets.symmetric(
          vertical: TsSpacing.sm,
          horizontal: TsSpacing.md,
        ),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: TsRadius.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TsBadge(label: pickLabel!, tone: pickTone),
            const SizedBox(width: TsSpacing.sm),
            if (probabilityLabel != null)
              Text(
                probabilityLabel!,
                style: TsType.tabular(
                  TsType.bodyMBold.copyWith(color: c.primary),
                ),
              ),
          ],
        ),
      );

      prediction = locked
          ? Stack(
              children: [
                block,
                Positioned.fill(
                  child: TsLockOverlay(
                    size: TsLockSize.inline,
                    headline: lockHeadline,
                  ),
                ),
              ],
            )
          : block;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(TsSpacing.lg),
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
                TsLeagueIcon(leagueId, size: TsIconSize.sm),
                const SizedBox(width: TsSpacing.sm),
                Expanded(
                  child: Text(
                    leagueLabel,
                    style: TsType.labelSMedium.copyWith(color: c.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasAnalysis) ...[
                  TsBadge(label: analysisLabel, tone: TsBadgeTone.primary),
                  const SizedBox(width: TsSpacing.sm),
                ],
                Text(
                  kickoffLabel,
                  style: TsType.labelSBold.copyWith(color: c.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: TsSpacing.md),
            Column(
              children: [
                teamRow(homeEmblemId, homeTeam),
                const SizedBox(height: TsSpacing.xs),
                teamRow(awayEmblemId, awayTeam),
              ],
            ),
            if (prediction != null) ...[
              const SizedBox(height: TsSpacing.md),
              prediction,
            ],
          ],
        ),
      ),
    );
  }
}
