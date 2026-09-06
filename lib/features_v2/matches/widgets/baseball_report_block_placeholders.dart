import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_gauge_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_prediction_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_stat_compare_row.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

/// Static placeholder content matching locked baseball block shapes.
abstract final class BaseballReportBlockPlaceholders {
  static Widget prediction() {
    return const TsPredictionCard(
      pickTeam: 'Home Team',
      probabilityLabel: '—%',
      resultLabel: 'REPORT',
      line: TsGaugeLine.twoWay,
      homeFraction: 0.5,
      awayFraction: 0.5,
      homeLabel: '—%',
      awayLabel: '—%',
    );
  }

  static Widget teamProduction(AppLocalizations l10n) {
    return statCompareRows([
      l10n.baseballStatRunsScored,
      l10n.baseballStatRunsAllowed,
      l10n.baseballStatHits,
    ]);
  }

  static Widget seasonTeamStats() {
    return statCompareRows(const ['AVG', 'OPS', 'ERA', 'WHIP']);
  }

  static Widget recentForm(AppLocalizations l10n) {
    return statCompareRows([
      'Win rate',
      l10n.baseballHomeAwayRecord,
    ]);
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
