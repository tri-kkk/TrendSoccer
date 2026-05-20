import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';
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

final soccerMatchesProvider =
    FutureProvider.family<List<SoccerAnalysisCard>, String>((ref, date) async {
  final service = ref.read(soccerServiceProvider);
  final matches = await service.getMatches(date: date);

  if (matches.isNotEmpty) return matches;

  // Distinguish network/API failure from a legitimately empty list.
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

final filteredSoccerMatchesProvider =
    Provider<AsyncValue<List<SoccerAnalysisCard>>>((ref) {
  final date = ref.watch(todayDateProvider);
  final selectedLeague = ref.watch(selectedLeagueProvider);
  final matchesAsync = ref.watch(soccerMatchesProvider(date));

  return matchesAsync.whenData((matches) {
    if (selectedLeague == null) return matches;
    return matches
        .where((card) => leagueIdForCard(card.match.league) == selectedLeague)
        .toList();
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
  final stats = await service.getPremiumPickStats(days: 7);

  if (stats.isNotEmpty) return stats;

  try {
    await ref.read(webDioProvider).get<dynamic>(
      '/api/premium-picks/stats',
      queryParameters: <String, int>{'days': 7},
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
  'ucl': 'champions_league',
  'champions_league': 'champions_league',
  'uel': 'europa_league',
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
