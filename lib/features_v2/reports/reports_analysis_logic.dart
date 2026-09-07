import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/utils/league_supports_analysis.dart';

/// Local YYYY-MM-DD of the earliest day that still has at least one unstarted
/// match, or null when none remain in [items].
String? reportsEarliestUnstartedLocalDate<T>({
  required Iterable<T> items,
  required DateTime? Function(T item) kickoffLocal,
  required bool Function(T item) hasNotStarted,
}) {
  final days = <String>{};
  for (final item in items) {
    if (!hasNotStarted(item)) continue;
    final local = kickoffLocal(item);
    if (local == null) continue;
    days.add(fixtureDateString(local));
  }
  if (days.isEmpty) return null;
  final sorted = days.toList()..sort();
  return sorted.first;
}

/// Per [leagueKey], the earliest local day that still has an unstarted match.
Map<String, String> reportsEarliestUnstartedLocalDatesByLeague<T>({
  required Iterable<T> items,
  required String Function(T item) leagueKey,
  required DateTime? Function(T item) kickoffLocal,
  required bool Function(T item) hasNotStarted,
}) {
  final daysByLeague = <String, Set<String>>{};
  for (final item in items) {
    if (!hasNotStarted(item)) continue;
    final local = kickoffLocal(item);
    if (local == null) continue;
    daysByLeague
        .putIfAbsent(leagueKey(item), () => {})
        .add(fixtureDateString(local));
  }

  return {
    for (final entry in daysByLeague.entries)
      entry.key: (entry.value.toList()..sort()).first,
  };
}

DateTime? soccerAnalysisKickoffLocal(SoccerAnalysisCard card) {
  final timestamp = card.match.matchTimestamp;
  if (timestamp != null) return timestamp.toLocal();
  return DateTime.tryParse(card.match.matchDate.trim())?.toLocal();
}

/// Earliest unstarted local day + league chip filter for reports soccer analysis.
List<SoccerAnalysisCard> filterReportsSoccerAnalysisList(
  List<SoccerAnalysisCard> matches,
  String? selectedLeagueId,
) {
  final earliestDate = reportsEarliestUnstartedLocalDate<SoccerAnalysisCard>(
    items: matches,
    kickoffLocal: soccerAnalysisKickoffLocal,
    hasNotStarted: soccerAnalysisMatchHasNotStarted,
  );
  if (earliestDate == null) return [];

  final filtered = filterSoccerAnalysisMatches(
    matches,
    earliestDate,
    selectedLeagueId,
  );
  filtered.sort((a, b) {
    final aTs = a.match.matchTimestamp;
    final bTs = b.match.matchTimestamp;
    if (aTs == null && bTs == null) return 0;
    if (aTs == null) return 1;
    if (bTs == null) return -1;
    return aTs.compareTo(bTs);
  });
  return filtered;
}

/// Per-league earliest unstarted local day + league chip filter for baseball.
List<BaseballAnalysisCard> filterReportsBaseballAnalysisList(
  List<BaseballAnalysisCard> matches,
  String? selectedLeagueId,
) {
  final analysisMatches = matches
      .where((card) => leagueSupportsAnalysis('baseball', card.league))
      .toList();

  final earliestByLeague =
      reportsEarliestUnstartedLocalDatesByLeague<BaseballAnalysisCard>(
    items: analysisMatches,
    leagueKey: (card) => card.league.trim().toUpperCase(),
    kickoffLocal: (card) => card.matchTimestamp.toLocal(),
    hasNotStarted: baseballMatchHasNotStarted,
  );
  if (earliestByLeague.isEmpty) return [];

  var filtered = analysisMatches.where((card) {
    if (!baseballMatchHasNotStarted(card)) return false;
    final league = card.league.trim().toUpperCase();
    final earliestDate = earliestByLeague[league];
    if (earliestDate == null) return false;
    return baseballMatchIsOnDate(card, earliestDate);
  }).toList();

  if (selectedLeagueId != null && selectedLeagueId.isNotEmpty) {
    final code = selectedLeagueId.toUpperCase();
    filtered =
        filtered.where((match) => match.league.toUpperCase() == code).toList();
  }

  filtered.sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));
  return filtered;
}
