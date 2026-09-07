import 'package:flutter/material.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/league_filter_chips.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';

/// League chip filter for reports premium picks (no date window).
List<SoccerAnalysisCard> filterReportsPremiumPicksList(
  List<SoccerAnalysisCard> picks,
  String? selectedLeagueId,
) {
  if (selectedLeagueId == null) return picks;

  final chip = soccerAnalysisLeagueChips.firstWhere(
    (filter) => filter.id == selectedLeagueId,
    orElse: () => soccerAnalysisLeagueChips.first,
  );
  final codes = chip.codes;
  if (codes == null || codes.isEmpty) return picks;

  final codeSet = codes.map((code) => code.toUpperCase()).toSet();
  return picks.where((card) {
    final leagueCode = card.match.league.code?.toUpperCase();
    return leagueCode != null && codeSet.contains(leagueCode);
  }).toList();
}

/// Premium `/api/premium-picks` often ships [LeagueInfo.code] without name fields.
String reportsPremiumLeagueLabel(BuildContext context, LeagueInfo league) {
  final fromNames = localizedLeagueName(
    context,
    league.nameEn,
    league.name,
  );
  if (fromNames.isNotEmpty) return fromNames;

  final code = league.code?.trim().toUpperCase();
  if (code == null || code.isEmpty) return '';

  for (final chip in soccerAnalysisLeagueChips) {
    if (chip.isAll) continue;
    final codes = chip.codes;
    if (codes == null) continue;
    if (codes.map((c) => c.toUpperCase()).contains(code)) {
      return chip.displayLabel(Localizations.localeOf(context).languageCode);
    }
  }

  return TsAssets.leagueDisplayName(league.code);
}
