import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/widgets/ts_h2h_summary.dart';
import 'package:trendsoccer/design_system/widgets/ts_insight_text.dart';
import 'package:trendsoccer/design_system/widgets/ts_method_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_prediction_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_stack_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_stat_compare_row.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

/// Static placeholder content matching locked block shapes (Figma-measured).
abstract final class SoccerReportBlockPlaceholders {
  static const _placeholderLine =
      'Historical trends and matchup context for this fixture.';

  static Widget prediction() {
    return const TsPredictionCard(
      pickTeam: 'Home Team',
      probabilityLabel: '—%',
      resultLabel: 'REPORT',
      homeFraction: 0.34,
      drawFraction: 0.32,
      awayFraction: 0.34,
      homeLabel: '—%',
      drawLabel: '—%',
      awayLabel: '—%',
    );
  }

  static Widget reasoning() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          const TsInsightText(
            text: _placeholderLine,
            tone: TsInsightTone.confirmed,
          ),
        ],
      ],
    );
  }

  static Widget threeMethod(AppLocalizations l10n) {
    final labels = [
      l10n.soccerMethodPaCompare,
      l10n.soccerMethodMinMax,
      l10n.soccerMethodFirstGoal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          TsMethodRow(
            methodLabel: labels[i],
            pickLabel: '—%',
            homeFraction: 0.34,
            drawFraction: 0.32,
            awayFraction: 0.34,
            homeLabel: '—%',
            drawLabel: '—%',
            awayLabel: '—%',
          ),
        ],
      ],
    );
  }

  static Widget teamStats(AppLocalizations l10n) {
    final labels = [
      l10n.soccerStatFirstGoalRate,
      l10n.soccerStatComebackRate,
      l10n.soccerRecentForm,
      l10n.soccerStatGoalDifference,
    ];

    return statCompareRows(labels);
  }

  static Widget scoringTrends(AppLocalizations l10n) {
    final labels = [
      l10n.soccerStatOver25,
      l10n.soccerMarketBtts,
      l10n.soccerMarketCs,
      l10n.soccerMarketFts,
    ];

    return statCompareRows(labels);
  }

  static Widget teamInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          TsInsightText(
            text: _placeholderLine,
            tone: i == 0 ? TsInsightTone.strength : TsInsightTone.weakness,
          ),
        ],
      ],
    );
  }

  static Widget recentForm(AppLocalizations l10n) {
    return statCompareRows([
      l10n.soccerRecent10,
      l10n.soccerStatWinRate,
    ]);
  }

  static Widget headToHead(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TsH2HSummary(
      line: TsStackLine.threeWay,
      homeValueLabel: '0',
      drawValueLabel: '0',
      awayValueLabel: '0',
      homeFraction: 0.34,
      drawFraction: 0.32,
      awayFraction: 0.34,
      homeLabel: l10n.labelHomeShort,
      drawLabel: l10n.soccerDraw,
      awayLabel: l10n.labelAwayShort,
      detailTitleLabel: l10n.soccerH2hRecent,
      meetings: List.generate(
        5,
        (_) => const TsH2HMeeting(
          dateLabel: '—',
          homeTeamLabel: '—',
          awayTeamLabel: '—',
          scoreLabel: '—',
        ),
      ),
    );
  }

  static Widget statCompareRows(List<String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          TsStatCompareRow(
            statLabel: labels[i],
            homeLabel: '—',
            awayLabel: '—',
            homeFraction: 0.5,
            awayFraction: 0.5,
          ),
        ],
      ],
    );
  }
}
