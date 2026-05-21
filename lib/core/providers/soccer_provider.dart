import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/features/analysis/analysis_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/cards/pick_direction_badge.dart';

/// Today's date in UTC (YYYY-MM-DD) for match list queries.
final todayDateProvider = Provider<String>((ref) {
  final now = DateTime.now().toUtc();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
});

/// Selected league filter chip id; `null` = 전체.
final selectedLeagueProvider = StateProvider<String?>((ref) => null);

/// Today's matches for Trend preview (single date).
final soccerMatchesProvider =
    FutureProvider.family<List<SoccerAnalysisCard>, String>((ref, date) async {
  final service = ref.read(soccerServiceProvider);
  final matches = await service.getMatches(date: date);

  if (matches.isNotEmpty) return matches;

  try {
    await ref.read(webDioProvider).get<dynamic>(
      '/api/odds-from-db',
      queryParameters: <String, String>{'date': date},
    );
    return matches;
  } on DioException {
    rethrow;
  } catch (e) {
    throw Exception('Failed to load soccer matches: $e');
  }
});

/// Upcoming analysis matches for Analysis page (no date, or 7-day fallback).
final analysisSoccerMatchesProvider =
    FutureProvider<List<SoccerAnalysisCard>>((ref) async {
  final service = ref.read(soccerServiceProvider);
  final matches = await _fetchAnalysisSoccerMatches(service);

  if (matches.isNotEmpty) return matches;

  try {
    await ref.read(webDioProvider).get<dynamic>('/api/odds-from-db');
    return matches;
  } on DioException {
    rethrow;
  } catch (e) {
    throw Exception('Failed to load soccer matches: $e');
  }
});

Future<List<SoccerAnalysisCard>> _fetchAnalysisSoccerMatches(
  SoccerService service,
) async {
  final merged = <int, SoccerAnalysisCard>{};
  final today = DateTime.now().toUtc();
  for (var dayOffset = 0; dayOffset < 7; dayOffset++) {
    final date = today.add(Duration(days: dayOffset));
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final dateStr = '${date.year}-$month-$day';
    final dayMatches = await service.getMatches(date: dateStr);
    for (final card in dayMatches) {
      merged[card.match.matchId] = card;
    }
  }

  final allCards = merged.values.toList();
  print(
    '[SOCCER] analysisSoccerMatches: merged ${allCards.length} cards from 7 days',
  );

  final filtered = allCards.where(_isUpcomingMatch).toList();
  print('[SOCCER] After finished filter: ${filtered.length} cards');

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

/// Normalized team name → logo URL from 7-day analysis match data.
final teamLogoMapProvider = Provider<Map<String, String>>((ref) {
  final matchesAsync = ref.watch(analysisSoccerMatchesProvider);
  return matchesAsync.maybeWhen(
    data: _buildTeamLogoMap,
    orElse: () => const {},
  );
});

Map<String, String> _buildTeamLogoMap(List<SoccerAnalysisCard> cards) {
  final map = <String, String>{};
  for (final card in cards) {
    _addTeamLogoEntry(map, card.match.homeTeam);
    _addTeamLogoEntry(map, card.match.awayTeam);
  }
  print('[SOCCER] teamLogoMap built with ${map.length} teams');
  return map;
}

const _diacriticMap = {
  'ä': 'a',
  'ö': 'o',
  'ü': 'u',
  'ß': 'ss',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ï': 'i',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'ñ': 'n',
  'ç': 'c',
  'Ä': 'A',
  'Ö': 'O',
  'Ü': 'U',
  'É': 'E',
  'È': 'E',
  'Ê': 'E',
  'Á': 'A',
  'À': 'A',
  'Â': 'A',
  'Í': 'I',
  'Ó': 'O',
  'Ú': 'U',
  'Ñ': 'N',
};

String stripDiacritics(String input) {
  return input.split('').map((c) => _diacriticMap[c] ?? c).join();
}

String normalizeTeamNameForLogo(String input) {
  var normalized = input.toLowerCase().trim();
  normalized = stripDiacritics(normalized);
  normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalized;
}

void _addTeamLogoEntry(Map<String, String> map, TeamInfo team) {
  final name = team.name.trim();
  final logo = team.logo?.trim();
  if (name.isEmpty || logo == null || logo.isEmpty) return;

  final lowered = name.toLowerCase();
  map[lowered] = logo;

  final stripped = stripDiacritics(lowered);
  if (stripped != lowered) {
    map[stripped] = logo;
  }

  final normalized = normalizeTeamNameForLogo(name);
  map[normalized] = logo;
}

/// Looks up a team logo URL with exact then contains-based matching.
String? findTeamLogo(Map<String, String> logoMap, String teamName) {
  final lookupKeys = <String>{
    teamName.toLowerCase().trim(),
    stripDiacritics(teamName.toLowerCase().trim()),
    normalizeTeamNameForLogo(teamName),
  }..removeWhere((key) => key.isEmpty);

  for (final key in lookupKeys) {
    if (logoMap.containsKey(key)) return logoMap[key];
  }

  final normalizedLookup = normalizeTeamNameForLogo(teamName);
  for (final entry in logoMap.entries) {
    final normalizedEntry = normalizeTeamNameForLogo(entry.key);
    if (entry.key.contains(normalizedLookup) ||
        normalizedLookup.contains(entry.key) ||
        normalizedEntry.contains(normalizedLookup) ||
        normalizedLookup.contains(normalizedEntry)) {
      return entry.value;
    }
  }
  return null;
}

bool _isUpcomingMatch(SoccerAnalysisCard card) {
  if (card.match.status == 'finished') return false;

  final timestamp = card.match.matchTimestamp;
  if (timestamp != null) {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 2));
    if (timestamp.toUtc().isBefore(cutoff) && card.match.status != 'live') {
      return false;
    }
  }

  return true;
}

final filteredSoccerMatchesProvider =
    Provider<AsyncValue<List<SoccerAnalysisCard>>>((ref) {
  final selectedLeague = ref.watch(selectedLeagueProvider);
  final matchesAsync = ref.watch(analysisSoccerMatchesProvider);

  return matchesAsync.whenData((matches) {
    if (selectedLeague == null) return matches;

    final chip = soccerAnalysisLeagueChips.firstWhere(
      (filter) => filter.id == selectedLeague,
      orElse: () => soccerAnalysisLeagueChips.first,
    );
    final codes = chip.codes;
    if (codes == null || codes.isEmpty) return matches;

    final codeSet = codes.map((code) => code.toUpperCase()).toSet();
    return matches.where((card) {
      final leagueCode = card.match.league.code?.toUpperCase();
      return leagueCode != null && codeSet.contains(leagueCode);
    }).toList();
  });
});

final premiumPicksProvider =
    FutureProvider.family<List<SoccerAnalysisCard>, String>((ref, date) async {
  final service = ref.read(soccerServiceProvider);
  final picks = await service.getPremiumPicks(date: date);

  if (picks.isNotEmpty) return picks;

  try {
    await ref.read(webDioProvider).get<dynamic>(
      '/api/premium-picks',
      queryParameters: <String, String>{'date': date},
    );
    return picks;
  } on DioException {
    rethrow;
  } catch (e) {
    throw Exception('Failed to load premium picks: $e');
  }
});

final premiumPickStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final service = ref.read(soccerServiceProvider);

  final history = await service.getPremiumPickHistory();
  if (history.isNotEmpty) {
    final calculated = service.calculateRecentStats(history, windowSize: 30);
    if (calculated.isNotEmpty) return calculated;
  }

  final stats = await service.getPremiumPickStats();

  if (stats.isNotEmpty) return stats;

  try {
    await ref.read(webDioProvider).get<dynamic>(
      '/api/premium-picks/stats',
      queryParameters: <String, int>{'days': 30},
    );
    return stats;
  } on DioException {
    rethrow;
  } catch (e) {
    throw Exception('Failed to load premium pick stats: $e');
  }
});

PickDirection? pickDirectionFromCard(SoccerAnalysisCard card) {
  final raw = card.prediction?.direction?.toLowerCase();
  if (raw == null || raw.isEmpty) return null;
  if (raw.contains('home') || raw == 'h' || raw.contains('홈')) {
    return PickDirection.home;
  }
  if (raw.contains('draw') || raw == 'd' || raw.contains('무')) {
    return PickDirection.draw;
  }
  if (raw.contains('away') || raw == 'a' || raw.contains('원정')) {
    return PickDirection.away;
  }
  return null;
}

String? winRateLabelFromCard(SoccerAnalysisCard card) {
  final confidence = card.prediction?.confidence;
  if (confidence == null) return null;
  if (confidence <= 1) return '${(confidence * 100).round()}%';
  return '${confidence.round()}%';
}

/// Maps API [LeagueInfo] to local [TsLeagueIcon] / filter chip ids.
String leagueIdForCard(LeagueInfo league) {
  final fromApiCode = TsAssets.leagueIconIdFromApiCode(league.code);
  if (fromApiCode != null) return fromApiCode;

  final codeKey = league.code
      ?.toLowerCase()
      .replaceAll(RegExp(r'[\s-]+'), '_')
      .replaceAll(RegExp(r'[^a-z0-9_]'), '');

  if (codeKey != null && codeKey.isNotEmpty) {
    final alias = _leagueCodeAliases[codeKey];
    if (alias != null) return alias;
    if (_knownLeagueFilterIds.contains(codeKey)) return codeKey;
  }

  final nameKey = league.name.trim().toLowerCase();
  final nameAlias = _leagueNameAliases[nameKey];
  if (nameAlias != null) return nameAlias;

  if (codeKey != null && codeKey.isNotEmpty) return codeKey;
  return 'league_${league.id}';
}

/// Display date for [AnalysisCard] (MM.DD).
String formatSoccerCardDate(String matchDate) {
  final parsed = DateTime.tryParse(matchDate);
  if (parsed != null) {
    final local = parsed.toUtc();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$month.$day';
  }
  if (RegExp(r'^\d{2}\.\d{2}$').hasMatch(matchDate)) return matchDate;
  if (matchDate.length >= 10) {
    final parts = matchDate.substring(0, 10).split('-');
    if (parts.length == 3) {
      return '${parts[1]}.${parts[2]}';
    }
  }
  return matchDate;
}

const _knownLeagueFilterIds = {
  'champions_league',
  'europa_league',
  'premier_league',
  'laliga',
  'bundesliga',
  'serie_a',
  'ligue_1',
  'eredivisie',
  'k_league',
  'j1_league',
  'mls',
};

const _leagueCodeAliases = <String, String>{
  'epl': 'premier_league',
  'pl': 'premier_league',
  'premier_league': 'premier_league',
  'pd': 'laliga',
  'bl1': 'bundesliga',
  'sa': 'serie_a',
  'fl1': 'ligue_1',
  'ded': 'eredivisie',
  'kl': 'k_league',
  'kl1': 'k_league',
  'kl2': 'k_league',
  'j1': 'j1_league',
  'ucl': 'champions_league',
  'cl': 'champions_league',
  'champions_league': 'champions_league',
  'uel': 'europa_league',
  'el': 'europa_league',
  'europa_league': 'europa_league',
  'la_liga': 'laliga',
  'laliga': 'laliga',
  'bundesliga': 'bundesliga',
  'serie_a': 'serie_a',
  'seriea': 'serie_a',
  'ligue_1': 'ligue_1',
  'ligue1': 'ligue_1',
  'eredivisie': 'eredivisie',
  'k_league': 'k_league',
  'kleague': 'k_league',
  'j1_league': 'j1_league',
  'j_league': 'j1_league',
  'mls': 'mls',
};

const _leagueNameAliases = <String, String>{
  'premier league': 'premier_league',
  'uefa champions league': 'champions_league',
  'champions league': 'champions_league',
  'uefa europa league': 'europa_league',
  'europa league': 'europa_league',
  'la liga': 'laliga',
  'laliga': 'laliga',
  'bundesliga': 'bundesliga',
  'serie a': 'serie_a',
  'ligue 1': 'ligue_1',
  'eredivisie': 'eredivisie',
  'k league 1': 'k_league',
  'k league': 'k_league',
  'j1 league': 'j1_league',
  'major league soccer': 'mls',
};
