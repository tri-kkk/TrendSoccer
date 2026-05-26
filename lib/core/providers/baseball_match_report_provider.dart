import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/baseball_service.dart';

final baseballMatchDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  return ref.read(baseballServiceProvider).getMatchDetail(matchId: matchId);
});

final baseballPitcherAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  final detail = await ref.watch(baseballMatchDetailProvider(matchId).future);
  if (detail.isEmpty) return {};

  final match = detail['match'] is Map
      ? Map<String, dynamic>.from(detail['match'] as Map)
      : detail;
  final league = _normalizeLeagueCode(
    (match['league'] as String?) ??
        (match['leagueName'] as String?) ??
        (match['league_name'] as String?) ??
        '',
  );
  final homeSide = match['home'] is Map
      ? Map<String, dynamic>.from(match['home'] as Map)
      : <String, dynamic>{};
  final awaySide = match['away'] is Map
      ? Map<String, dynamic>.from(match['away'] as Map)
      : <String, dynamic>{};
  final homeTeamKo = (homeSide['teamKo'] as String?) ??
      (homeSide['team'] as String?) ??
      '';
  final awayTeamKo = (awaySide['teamKo'] as String?) ??
      (awaySide['team'] as String?) ??
      '';
  final homePitcherName =
      (match['homePitcherKo'] as String?) ?? (match['homePitcher'] as String?);
  final awayPitcherName =
      (match['awayPitcherKo'] as String?) ?? (match['awayPitcher'] as String?);
  final apiMatchId = (match['id'] as num?)?.toInt() ??
      (match['matchId'] as num?)?.toInt() ??
      matchId;

  if (homePitcherName == null && awayPitcherName == null) return {};

  Map<String, dynamic>? homeStats;
  Map<String, dynamic>? awayStats;

  if (league == 'KBO' || league == 'NPB') {
    try {
      final service = ref.read(baseballServiceProvider);
      final statsResponse = await service.getKboPitcherStats(
        league: league.toLowerCase(),
        homePitcher: homePitcherName ?? '',
        awayPitcher: awayPitcherName ?? '',
        homeTeam: homeTeamKo,
        awayTeam: awayTeamKo,
      );
      if (statsResponse['success'] == true) {
        final homeRaw = statsResponse['homePitcher'];
        final awayRaw = statsResponse['awayPitcher'];
        if (homeRaw is Map) {
          homeStats = Map<String, dynamic>.from(homeRaw);
        }
        if (awayRaw is Map) {
          awayStats = Map<String, dynamic>.from(awayRaw);
        }
      }
    } catch (e) {
      print('[BASEBALL] Failed to get KBO/NPB pitcher stats for analysis: $e');
    }
  }

  if (league == 'MLB') {
    homeStats = {
      'era': match['homePitcherEra'],
      'whip': match['homePitcherWhip'],
      'strikeouts': match['homePitcherK'],
    };
    awayStats = {
      'era': match['awayPitcherEra'],
      'whip': match['awayPitcherWhip'],
      'strikeouts': match['awayPitcherK'],
    };
  }

  homeStats ??= {
    'era': match['homePitcherEra'],
    'whip': match['homePitcherWhip'],
    'strikeouts': match['homePitcherK'],
  };
  awayStats ??= {
    'era': match['awayPitcherEra'],
    'whip': match['awayPitcherWhip'],
    'strikeouts': match['awayPitcherK'],
  };

  final service = ref.read(baseballServiceProvider);
  return service.getPitcherAnalysis(
    matchId: apiMatchId,
    homeTeam: homeTeamKo,
    awayTeam: awayTeamKo,
    homePitcher: homePitcherName,
    awayPitcher: awayPitcherName,
    homeStats: homeStats,
    awayStats: awayStats,
    league: league,
  );
});

final baseballAiAnalysisProvider = baseballPitcherAnalysisProvider;

typedef BaseballH2HParams = ({int homeTeamId, int awayTeamId});

final baseballH2HProvider =
    FutureProvider.family<Map<String, dynamic>, BaseballH2HParams>(
  (ref, params) async {
    final service = ref.read(baseballServiceProvider);
    return service.getH2H(
      homeTeamId: params.homeTeamId,
      awayTeamId: params.awayTeamId,
    );
  },
);

typedef BaseballPitcherStatsParams = ({
  String league,
  String homePitcher,
  String awayPitcher,
  String homeTeam,
  String awayTeam,
});

final baseballPitcherStatsProvider =
    FutureProvider.family<Map<String, dynamic>, BaseballPitcherStatsParams>(
  (ref, params) async {
    final service = ref.read(baseballServiceProvider);
    return service.getKboPitcherStats(
      league: params.league,
      homePitcher: params.homePitcher,
      awayPitcher: params.awayPitcher,
      homeTeam: params.homeTeam,
      awayTeam: params.awayTeam,
    );
  },
);

String _normalizeLeagueCode(String league) {
  final upper = league.trim().toUpperCase();
  if (upper.contains('KBO')) return 'KBO';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('MLB')) return 'MLB';
  return upper;
}
