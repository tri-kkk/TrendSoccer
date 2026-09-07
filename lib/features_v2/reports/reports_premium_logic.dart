import 'package:trendsoccer/core/models/league_filter_chips.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';

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
