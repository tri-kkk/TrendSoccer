import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_footer.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_match_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_lock_overlay.dart';

class TsComboMatchup {
  const TsComboMatchup({
    required this.homeTeamLabel,
    required this.awayTeamLabel,
    required this.homeScoreLabel,
    required this.awayScoreLabel,
    required this.timeLabel,
    required this.result,
  });

  final String homeTeamLabel;
  final String awayTeamLabel;
  final String homeScoreLabel;
  final String awayScoreLabel;
  final String timeLabel;
  final TsComboResult result;
}

class TsComboSummaryCard extends StatelessWidget {
  const TsComboSummaryCard({
    required this.leagueIcon,
    required this.leagueLabel,
    required this.typeBadgeLabel,
    required this.matchups,
    required this.totalIndexLabel,
    required this.confidenceLabel,
    this.locked = false,
    this.lockHeadlineLabel = 'Premium content',
    this.lockSublineLabel = 'Subscribe to view full analysis',
    super.key,
  });

  final Widget leagueIcon;
  final String leagueLabel;
  final String typeBadgeLabel;
  final List<TsComboMatchup> matchups;
  final String totalIndexLabel;
  final String confidenceLabel;
  final bool locked;
  final String lockHeadlineLabel;
  final String lockSublineLabel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final outcome = _deriveOutcome(matchups);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, minHeight: 110),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: TsRadius.md,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: TsSpacing.md,
            horizontal: TsSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(c),
              const SizedBox(height: TsSpacing.md),
              _matchupsSection(),
              const SizedBox(height: TsSpacing.md),
              TsComboFooter(
                totalIndexLabel: totalIndexLabel,
                confidenceLabel: confidenceLabel,
                outcome: outcome,
              ),
            ],
          ),
        ),
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

  Widget _matchupsSection() {
    final matchupsColumn = Column(
      children: [
        for (var i = 0; i < matchups.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: TsComboMatchRow(
              homeTeam: matchups[i].homeTeamLabel,
              awayTeam: matchups[i].awayTeamLabel,
              timeLabel: matchups[i].timeLabel,
              result: matchups[i].result,
              homeScore: matchups[i].homeScoreLabel,
              awayScore: matchups[i].awayScoreLabel,
            ),
          ),
        ],
      ],
    );

    if (!locked) return matchupsColumn;

    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: matchupsColumn,
        ),
        TsLockOverlay(
          size: TsLockSize.inline,
          headline: lockHeadlineLabel,
          subline: lockSublineLabel,
        ),
      ],
    );
  }

  static TsComboOutcome _deriveOutcome(List<TsComboMatchup> matchups) {
    if (matchups.isEmpty) return TsComboOutcome.pending;

    final hasHit = matchups.any((m) => m.result == TsComboResult.hit);
    final hasMiss = matchups.any((m) => m.result == TsComboResult.miss);
    final hasPending =
        matchups.any((m) => m.result == TsComboResult.inProgress);

    if (hasHit && hasMiss) return TsComboOutcome.partial;
    if (matchups.every((m) => m.result == TsComboResult.hit)) {
      return TsComboOutcome.hit;
    }
    if (matchups.every((m) => m.result == TsComboResult.miss)) {
      return TsComboOutcome.miss;
    }
    if (hasMiss && !hasHit && hasPending) return TsComboOutcome.miss;
    return TsComboOutcome.pending;
  }
}
