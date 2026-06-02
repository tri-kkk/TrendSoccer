import 'package:flutter/foundation.dart';
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

  final match = _unwrapBaseballMatch(detail);
  final homeSide = match['home'] is Map
      ? Map<String, dynamic>.from(match['home'] as Map)
      : <String, dynamic>{};
  final awaySide = match['away'] is Map
      ? Map<String, dynamic>.from(match['away'] as Map)
      : <String, dynamic>{};
  final homeTeamKo = _baseballTeamKoreanFromMatch(
    match,
    homeSide,
    isHome: true,
  );
  final awayTeamKo = _baseballTeamKoreanFromMatch(
    match,
    awaySide,
    isHome: false,
  );
  final league = _normalizeLeagueCode(
    (match['league'] as String?) ??
        (match['leagueName'] as String?) ??
        (match['league_name'] as String?) ??
        '',
  );
  final homePitcherName =
      (match['homePitcherKo'] as String?) ?? (match['homePitcher'] as String?);
  final awayPitcherName =
      (match['awayPitcherKo'] as String?) ?? (match['awayPitcher'] as String?);
  final apiMatchId = (match['id'] as num?)?.toInt() ?? matchId;

  final homeTeamForAnalysis = homeTeamKo.isNotEmpty
      ? homeTeamKo
      : _baseballTeamKoreanFromMatch(match, homeSide, isHome: true);
  final awayTeamForAnalysis = awayTeamKo.isNotEmpty
      ? awayTeamKo
      : _baseballTeamKoreanFromMatch(match, awaySide, isHome: false);

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
        homeTeam: homeTeamForAnalysis,
        awayTeam: awayTeamForAnalysis,
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
      debugPrint('[BASEBALL] Failed to get KBO/NPB pitcher stats for analysis: $e');
    }
  }

  if (league == 'MLB') {
    try {
      final mlbStats = await ref.watch(mlbPitcherStatsProvider(matchId).future);
      final mlbPrev = await ref.watch(mlbPitcherStatsPrevProvider(matchId).future);

      final homePitcherCurrent = _readStatsMap(mlbStats['homePitcher']);
      final awayPitcherCurrent = _readStatsMap(mlbStats['awayPitcher']);
      final homePitcherPrev = _readStatsMap(mlbPrev['homePitcher']);
      final awayPitcherPrev = _readStatsMap(mlbPrev['awayPitcher']);

      if (homePitcherCurrent != null || homePitcherPrev != null) {
        homeStats = _buildMlbPitcherStatsPayload(
          current: homePitcherCurrent,
          prev: homePitcherPrev,
          pitcherName: homePitcherName,
        );
      }
      if (awayPitcherCurrent != null || awayPitcherPrev != null) {
        awayStats = _buildMlbPitcherStatsPayload(
          current: awayPitcherCurrent,
          prev: awayPitcherPrev,
          pitcherName: awayPitcherName,
        );
      }
    } catch (e) {
      debugPrint('[BASEBALL] Failed to get MLB pitcher stats for analysis: $e');
    }
  }

  if (league == 'MLB') {
    homeStats ??= _buildMlbPitcherStatsPayload(
      current: {
        'era': match['homePitcherEra'],
        'whip': match['homePitcherWhip'],
        'strikeOuts': match['homePitcherK'],
      },
      prev: null,
      pitcherName: homePitcherName,
    );
    awayStats ??= _buildMlbPitcherStatsPayload(
      current: {
        'era': match['awayPitcherEra'],
        'whip': match['awayPitcherWhip'],
        'strikeOuts': match['awayPitcherK'],
      },
      prev: null,
      pitcherName: awayPitcherName,
    );
  } else {
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
  }

  debugPrint('[BASEBALL] pitcher-analysis homeStats keys: ${homeStats.keys}');
  if (league == 'MLB') {
    debugPrint(
      '[BASEBALL] pitcher-analysis MLB shape: current=${(homeStats['current'] as Map?)?.keys}, prev=${homeStats['prev'] != null}',
    );
  }
  debugPrint(
    '[BASEBALL] pitcher-analysis POST: league=$league, homeTeam=$homeTeamForAnalysis, homePitcher=$homePitcherName, statsShape=${league == 'MLB' ? 'current/prev' : 'flat'}',
  );

  return service.getPitcherAnalysis(
    matchId: apiMatchId,
    homeTeam: homeTeamForAnalysis,
    awayTeam: awayTeamForAnalysis,
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

  if (detail['matches'] is List && (detail['matches'] as List).isNotEmpty) {
    final first = (detail['matches'] as List).first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return Map<String, dynamic>.from(first);
  }

  return detail;
}

String _baseballTeamEnglishFromMatch(
  Map<String, dynamic> match,
  Map<String, dynamic> side, {
  required bool isHome,
}) {
  final fromSide = _baseballTeamEnglish(side);
  if (fromSide.isNotEmpty) return fromSide;
  final flatKey = isHome ? 'homeTeam' : 'awayTeam';
  return (match[flatKey] as String?) ?? '';
}

String _baseballTeamKoreanFromMatch(
  Map<String, dynamic> match,
  Map<String, dynamic> side, {
  required bool isHome,
}) {
  final fromSide = _baseballTeamKorean(side);
  if (fromSide.isNotEmpty) return fromSide;
  final flatKoKey = isHome ? 'homeTeamKo' : 'awayTeamKo';
  final flatKey = isHome ? 'homeTeam' : 'awayTeam';
  return (match[flatKoKey] as String?) ?? (match[flatKey] as String?) ?? '';
}

({String homeTeam, String awayTeam, String homeTeamKo, String awayTeamKo, int apiMatchId, String league, int? homeTeamId, int? awayTeamId})
    _baseballMatchContext(Map<String, dynamic> detail, int matchId) {
  final match = _unwrapBaseballMatch(detail);
  final homeSide = match['home'] is Map
      ? Map<String, dynamic>.from(match['home'] as Map)
      : <String, dynamic>{};
  final awaySide = match['away'] is Map
      ? Map<String, dynamic>.from(match['away'] as Map)
      : <String, dynamic>{};
  final homeTeam = _baseballTeamEnglishFromMatch(match, homeSide, isHome: true);
  final awayTeam = _baseballTeamEnglishFromMatch(match, awaySide, isHome: false);
  final homeTeamKo = _baseballTeamKoreanFromMatch(match, homeSide, isHome: true);
  final awayTeamKo = _baseballTeamKoreanFromMatch(match, awaySide, isHome: false);
  final apiMatchId = (match['id'] as num?)?.toInt() ?? matchId;
  final league = (match['league'] as String?) ??
      (match['leagueName'] as String?) ??
      (match['league_name'] as String?) ??
      '';
  final homeTeamId = (match['homeTeamId'] as num?)?.toInt() ??
      (homeSide['id'] as num?)?.toInt();
  final awayTeamId = (match['awayTeamId'] as num?)?.toInt() ??
      (awaySide['id'] as num?)?.toInt();
  return (
    homeTeam: homeTeam,
    awayTeam: awayTeam,
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
  debugPrint(
    '[BASEBALL] predict POST: homeTeam=${ctx.homeTeam}, awayTeam=${ctx.awayTeam}',
  );
  return service.getBaseballPredict(
    matchId: ctx.apiMatchId,
    homeTeam: ctx.homeTeam,
    awayTeam: ctx.awayTeam,
  );
});

final baseballHomeTeamStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  final detail = await ref.watch(baseballMatchDetailProvider(matchId).future);
  if (detail.isEmpty) return {};
  final ctx = _baseballMatchContext(detail, matchId);
  if (ctx.homeTeamId == null) return {};
  final service = ref.read(baseballServiceProvider);
  return service.getBaseballTeamStats(teamId: ctx.homeTeamId!);
});

final baseballAwayTeamStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  final detail = await ref.watch(baseballMatchDetailProvider(matchId).future);
  if (detail.isEmpty) return {};
  final ctx = _baseballMatchContext(detail, matchId);
  if (ctx.awayTeamId == null) return {};
  final service = ref.read(baseballServiceProvider);
  return service.getBaseballTeamStats(teamId: ctx.awayTeamId!);
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

String _baseballTeamEnglish(Map<String, dynamic> side) {
  return (side['team'] as String?) ?? (side['teamKo'] as String?) ?? '';
}

String _baseballTeamKorean(Map<String, dynamic> side) {
  return (side['teamKo'] as String?) ?? (side['team'] as String?) ?? '';
}

Map<String, dynamic>? _readStatsMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _statToString(Object? value) => value?.toString() ?? '';

Map<String, dynamic> _buildMlbPitcherStatsPayload({
  required Map<String, dynamic>? current,
  required Map<String, dynamic>? prev,
  required String? pitcherName,
}) {
  final currentSeason = DateTime.now().year;
  final payload = <String, dynamic>{
    'fullName': current?['fullName'] ?? pitcherName ?? '',
    'pitchHand': current?['throwingHand'] ?? '',
    'current': {
      'season': currentSeason,
      'era': _statToString(current?['era']),
      'whip': _statToString(current?['whip']),
      'strikeoutsPer9Inn': _statToString(current?['strikeoutsPer9Inn']),
      'walksPer9Inn': _statToString(current?['walksPer9Inn']),
      'strikeoutWalkRatio': _statToString(current?['strikeoutWalkRatio']),
      'wins': current?['wins'],
      'losses': current?['losses'],
      'gamesStarted': current?['gamesStarted'],
      'inningsPitched': _statToString(current?['inningsPitched']),
      'strikeOuts': current?['strikeOuts'],
      'baseOnBalls': current?['baseOnBalls'],
      'homeRuns': current?['homeRuns'],
    },
  };

  if (prev != null) {
    payload['prev'] = {
      'season': currentSeason - 1,
      ...prev,
    };
  }

  return payload;
}

