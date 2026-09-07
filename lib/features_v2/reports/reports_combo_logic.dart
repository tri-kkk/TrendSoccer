import 'package:flutter/material.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/baseball_combo_parsed.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_match_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_summary_card.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

const reportsComboNullDisplay = '\u2014';

/// League filter for reports Multi-Match — matches [BaseballComboParsed.league].
List<BaseballComboParsed> filterReportsComboList(
  List<BaseballComboParsed> combos,
  String selectedDateKey,
  String? selectedLeagueId,
) {
  var filtered = combos
      .where((combo) => combo.pickDate == selectedDateKey)
      .toList(growable: false);

  if (selectedLeagueId == null || selectedLeagueId.isEmpty) {
    return filtered;
  }

  final chip = baseballAnalysisLeagueChips.firstWhere(
    (filter) => filter.id == selectedLeagueId,
    orElse: () => baseballAnalysisLeagueChips.first,
  );
  final code = chip.code;
  if (code == null || code.isEmpty) return filtered;

  final leagueCode = code.toUpperCase();
  return filtered
      .where(
        (combo) => combo.league?.trim().toUpperCase() == leagueCode,
      )
      .toList(growable: false);
}

String reportsComboDateKey(DateTime date) => baseballDateString(date);

bool reportsComboIsSafeType(BaseballComboParsed combo) {
  final foldCount = combo.foldCount ?? combo.legs.length;
  return foldCount <= 2;
}

String reportsComboTypeBadgeLabel(
  AppLocalizations l10n,
  BaseballComboParsed combo,
) {
  return reportsComboIsSafeType(combo)
      ? l10n.reportsComboTypeStable
      : l10n.reportsComboTypeHighIndex;
}

String reportsComboLeagueLabel(BuildContext context, String? leagueCode) {
  if (leagueCode == null || leagueCode.trim().isEmpty) {
    return reportsComboNullDisplay;
  }

  final code = leagueCode.trim().toUpperCase();
  for (final chip in baseballAnalysisLeagueChips) {
    if (chip.isAll) continue;
    if (chip.code?.toUpperCase() == code) {
      return chip.displayLabel(Localizations.localeOf(context).languageCode);
    }
  }

  return TsAssets.leagueDisplayName(leagueCode);
}

String reportsComboTotalIndexLabel(double? totalOdds) {
  if (totalOdds == null) return reportsComboNullDisplay;
  return totalOdds.toStringAsFixed(2);
}

String reportsComboConfidenceLabel(double? avgConfidence) {
  if (avgConfidence == null) return reportsComboNullDisplay;
  return '${avgConfidence.round()}%';
}

TsComboResult reportsComboLegResult(bool? isCorrect) {
  if (isCorrect == true) return TsComboResult.hit;
  if (isCorrect == false) return TsComboResult.miss;
  return TsComboResult.inProgress;
}

TsComboMatchup reportsComboMatchup(
  BuildContext context,
  BaseballComboLegParsed leg,
) {
  final homeTeam = leg.homeTeam;
  final awayTeam = leg.awayTeam;
  return TsComboMatchup(
    homeTeamLabel: homeTeam == null
        ? reportsComboNullDisplay
        : localizedTeamName(context, homeTeam, leg.homeTeamKo),
    awayTeamLabel: awayTeam == null
        ? reportsComboNullDisplay
        : localizedTeamName(context, awayTeam, leg.awayTeamKo),
    homeScoreLabel: leg.homeScore?.toString() ?? '',
    awayScoreLabel: leg.awayScore?.toString() ?? '',
    timeLabel: leg.matchStatus ?? reportsComboNullDisplay,
    result: reportsComboLegResult(leg.isCorrect),
    homeEmblemUrl: leg.homeLogo,
    awayEmblemUrl: leg.awayLogo,
  );
}
