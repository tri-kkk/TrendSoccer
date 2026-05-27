import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/baseball_service.dart';

final baseballMatchDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  // matchId = api_match_id from route / list card
  return ref.read(baseballServiceProvider).getMatchDetail(matchId: matchId);
});

final baseballPitcherAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  // matchId = api_match_id from route
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
  final apiMatchId = (match['id'] as num?)?.toInt() ?? matchId;

  if (homePitcherName == null && awayPitcherName == null) return {};

  final service = ref.read(baseballServiceProvider);
  Map<String, dynamic>? homeStats;
  Map<String, dynamic>? awayStats;

  if (league == 'KBO' || league == 'NPB') {
    try {
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
    try {
      final homePitcherId = (match['homePitcherId'] as num?)?.toInt();
      final awayPitcherId = (match['awayPitcherId'] as num?)?.toInt();
      if (homePitcherId != null || awayPitcherId != null) {
        final mlbStats = await service.getMlbPitcherStats(
          matchId: apiMatchId,
          homePitcherId: homePitcherId,
          awayPitcherId: awayPitcherId,
        );
        final homeRaw = mlbStats['homePitcher'];
        final awayRaw = mlbStats['awayPitcher'];
        if (homeRaw is Map) {
          homeStats = Map<String, dynamic>.from(homeRaw);
        }
        if (awayRaw is Map) {
          awayStats = Map<String, dynamic>.from(awayRaw);
        }
      }
    } catch (e) {
      print('[BASEBALL] Failed to get MLB pitcher stats for analysis: $e');
    }
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

  // MLB pitcher names are often English in match detail; Korean text may mix
  // languages when language=ko (same as web — e.g. "콜로라도의 Kyle Freeland는").
  print(
    '[BASEBALL] Pitcher analysis language: ko, '
    'homePitcher=$homePitcherName, awayPitcher=$awayPitcherName',
  );

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

Map<String, dynamic> _unwrapBaseballMatch(Map<String, dynamic> detail) {
  final match = detail['match'];
  if (match is Map<String, dynamic>) return match;
  if (match is Map) return Map<String, dynamic>.from(match);
  return detail;
}

({String homeTeamKo, String awayTeamKo, int apiMatchId, String league, int? homeTeamId, int? awayTeamId})
    _baseballMatchContext(Map<String, dynamic> detail, int matchId) {
  final match = _unwrapBaseballMatch(detail);
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
  final apiMatchId = (match['id'] as num?)?.toInt() ?? matchId;
  final league = (match['league'] as String?) ??
      (match['leagueName'] as String?) ??
      (match['league_name'] as String?) ??
      '';
  final homeTeamId = (homeSide['id'] as num?)?.toInt();
  final awayTeamId = (awaySide['id'] as num?)?.toInt();
  return (
    homeTeamKo: homeTeamKo,
    awayTeamKo: awayTeamKo,
    apiMatchId: apiMatchId,
    league: league,
    homeTeamId: homeTeamId,
    awayTeamId: awayTeamId,
  );
}

final baseballPredictProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  final detail = await ref.watch(baseballMatchDetailProvider(matchId).future);
  if (detail.isEmpty) return {};
  final ctx = _baseballMatchContext(detail, matchId);
  final service = ref.read(baseballServiceProvider);
  return service.getBaseballPredict(
    matchId: ctx.apiMatchId,
    homeTeam: ctx.homeTeamKo,
    awayTeam: ctx.awayTeamKo,
  );
});

final baseballHomeTeamStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  final detail = await ref.watch(baseballMatchDetailProvider(matchId).future);
  if (detail.isEmpty) return {};
  final ctx = _baseballMatchContext(detail, matchId);
  if (ctx.homeTeamId == null || ctx.league.isEmpty) return {};
  final service = ref.read(baseballServiceProvider);
  return service.getBaseballTeamStats(
    teamId: ctx.homeTeamId!,
    league: ctx.league,
  );
});

final baseballAwayTeamStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  final detail = await ref.watch(baseballMatchDetailProvider(matchId).future);
  if (detail.isEmpty) return {};
  final ctx = _baseballMatchContext(detail, matchId);
  if (ctx.awayTeamId == null || ctx.league.isEmpty) return {};
  final service = ref.read(baseballServiceProvider);
  return service.getBaseballTeamStats(
    teamId: ctx.awayTeamId!,
    league: ctx.league,
  );
});

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

final mlbPitcherStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  final detailAsync = ref.watch(baseballMatchDetailProvider(matchId));
  final detail = detailAsync.hasValue ? detailAsync.value! : null;
  if (detail == null || detail.isEmpty) return {};

  final match = _unwrapBaseballMatch(detail);
  final league = _normalizeLeagueCode(
    (match['league'] as String?) ??
        (match['leagueName'] as String?) ??
        (match['league_name'] as String?) ??
        '',
  );
  if (league != 'MLB') return {};

  final homePitcherId = (match['homePitcherId'] as num?)?.toInt();
  final awayPitcherId = (match['awayPitcherId'] as num?)?.toInt();
  if (homePitcherId == null && awayPitcherId == null) return {};

  final apiMatchId = (match['id'] as num?)?.toInt() ?? matchId;
  final service = ref.read(baseballServiceProvider);
  return service.getMlbPitcherStats(
    matchId: apiMatchId,
    homePitcherId: homePitcherId,
    awayPitcherId: awayPitcherId,
  );
});

final mlbPitcherStatsPrevProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  final detailAsync = ref.watch(baseballMatchDetailProvider(matchId));
  final detail = detailAsync.hasValue ? detailAsync.value! : null;
  if (detail == null || detail.isEmpty) return {};

  final match = _unwrapBaseballMatch(detail);
  final league = _normalizeLeagueCode(
    (match['league'] as String?) ??
        (match['leagueName'] as String?) ??
        (match['league_name'] as String?) ??
        '',
  );
  if (league != 'MLB') return {};

  final homePitcherId = (match['homePitcherId'] as num?)?.toInt();
  final awayPitcherId = (match['awayPitcherId'] as num?)?.toInt();
  if (homePitcherId == null && awayPitcherId == null) return {};

  final service = ref.read(baseballServiceProvider);
  final prevYear = DateTime.now().year - 1;

  final homeFuture = homePitcherId != null
      ? service.fetchMlbSeasonStats(homePitcherId, prevYear)
      : Future<Map<String, dynamic>?>.value(null);
  final awayFuture = awayPitcherId != null
      ? service.fetchMlbSeasonStats(awayPitcherId, prevYear)
      : Future<Map<String, dynamic>?>.value(null);

  final results = await Future.wait<Map<String, dynamic>?>([
    homeFuture,
    awayFuture,
  ]);

  return {
    'season': prevYear,
    'homePitcher': results[0],
    'awayPitcher': results[1],
  };
});

String _normalizeLeagueCode(String league) {
  final upper = league.trim().toUpperCase();
  if (upper.contains('KBO')) return 'KBO';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('MLB')) return 'MLB';
  return upper;
}

