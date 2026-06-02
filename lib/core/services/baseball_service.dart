import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';

final baseballServiceProvider = Provider<BaseballService>((ref) {
  return BaseballService(ref.watch(webDioProvider));
});

class BaseballService {
  BaseballService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getPitcherAnalysis({
    required int matchId,
    required String homeTeam,
    required String awayTeam,
    String? homePitcher,
    String? awayPitcher,
    Map<String, dynamic>? homeStats,
    Map<String, dynamic>? awayStats,
    required String league,
    String language = 'ko',
  }) async {
    try {
      final body = <String, dynamic>{
        'matchId': matchId,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'homePitcher': homePitcher,
        'awayPitcher': awayPitcher,
        'homeStats': homeStats ?? <String, dynamic>{},
        'awayStats': awayStats ?? <String, dynamic>{},
        'league': league,
        'language': language,
      };
      debugPrint(
        '[BASEBALL] POST pitcher-analysis: api_match_id=$matchId, league=$league',
      );
      final response = await _dio.post<dynamic>(
        '/api/baseball/pitcher-analysis',
        data: body,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final data = response.data;
      debugPrint('[BASEBALL] Pitcher analysis success: cached=${data?['cached']}');
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BASEBALL] Pitcher analysis error: $e');
      return {};
    }
  }

  Future<List<BaseballAnalysisCard>> getMatches({
    required String date,
    String? league,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/baseball/matches',
        queryParameters: <String, String>{
          'date': date,
          'status': 'scheduled',
          'limit': '50',
        },
      );
      var matches = _parseAnalysisCards(response.data);
      if (league != null && league.isNotEmpty) {
        final normalizedLeague = league.trim().toUpperCase();
        matches = matches
            .where((match) => match.league.toUpperCase() == normalizedLeague)
            .toList();
      }
      debugPrint('[BASEBALL] Analysis matches for $date: ${matches.length}');
      return matches;
    } catch (e) {
      debugPrint('[BASEBALL] Analysis matches for $date failed: $e');
      return const [];
    }
  }

  Future<Map<String, dynamic>> getMatchDetail({required int matchId}) async {
    debugPrint('[BASEBALL] Match detail request: api_match_id=$matchId');
    try {
      final response = await _dio.get<dynamic>(
        '/api/baseball/matches',
        queryParameters: <String, dynamic>{
          'id': matchId,
          'skipML': true,
        },
      );
      final responseData = _adaptToMap(response.data);
      Map<String, dynamic>? match;
      if (responseData['match'] != null) {
        match = _adaptToMap(responseData['match']);
      } else if (responseData['matches'] is List &&
          (responseData['matches'] as List).isNotEmpty) {
        match = _adaptToMap((responseData['matches'] as List).first);
      }

      debugPrint(
        '[BASEBALL] Match detail via query: id=$matchId, keys=${match?.keys}',
      );
      debugPrint('[BASEBALL] aiPrediction: ${match?['aiPrediction']}');
      debugPrint(
        '[BASEBALL] aiPick: ${match?['aiPick']}, confidence: ${match?['aiPickConfidence']}',
      );

      if (match != null) {
        return {'match': match};
      }
      debugPrint('[BASEBALL] Match detail for $matchId: no match in response');
      return responseData;
    } catch (e) {
      debugPrint('[BASEBALL] Match detail for $matchId failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getH2H({
    required int homeTeamId,
    required int awayTeamId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/baseball/h2h',
        queryParameters: <String, dynamic>{
          'homeTeamId': homeTeamId,
          'awayTeamId': awayTeamId,
        },
      );
      debugPrint(
        '[BASEBALL] H2H for $homeTeamId vs $awayTeamId: ${response.data?['count']} matches',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BASEBALL] H2H error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getBaseballPredict({
    required int matchId,
    required String homeTeam,
    required String awayTeam,
    bool quick = false,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/baseball/predict',
        data: <String, dynamic>{
          'matchId': matchId,
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'quick': quick,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      debugPrint('[BASEBALL] predict response: success=${response.data?['success']}');
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BASEBALL] predict error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getBaseballTeamStats({
    required int teamId,
  }) async {
    try {
      debugPrint('[BASEBALL] team-stats request: teamId=$teamId');
      final response = await _dio.get<dynamic>(
        '/api/baseball/team-stats',
        queryParameters: <String, dynamic>{
          'teamId': teamId,
        },
      );
      final data = response.data;
      debugPrint(
        '[BASEBALL] team-stats response: success=${data?['success']}, games=${data?['stats']?['games']}',
      );
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BASEBALL] team-stats error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getMlbPitcherStats({
    required int matchId,
    int? homePitcherId,
    int? awayPitcherId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (homePitcherId != null) params['homePitcherId'] = homePitcherId;
      if (awayPitcherId != null) params['awayPitcherId'] = awayPitcherId;
      debugPrint(
        '[BASEBALL] MLB pitcher-stats request: homePitcherId=$homePitcherId, awayPitcherId=$awayPitcherId',
      );
      final response = await _dio.get<dynamic>(
        '/api/baseball/pitcher-stats',
        queryParameters: params,
      );
      debugPrint('[BASEBALL] MLB pitcher-stats: success=${response.data?['success']}');
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BASEBALL] MLB pitcher-stats error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>?> fetchMlbSeasonStats(
    int pitcherId,
    int season,
  ) async {
    try {
      final url =
          'https://statsapi.mlb.com/api/v1/people/$pitcherId?hydrate=stats(group=[pitching],type=[season],season=$season)';
      debugPrint('[BASEBALL] MLB Stats API request: pitcherId=$pitcherId, season=$season');
      final response = await Dio().get<dynamic>(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      final data = response.data;
      final people = data is Map ? data['people'] : null;
      final firstPerson = people is List && people.isNotEmpty ? people[0] : null;
      final stats = firstPerson is Map ? firstPerson['stats'] : null;
      final firstStat = stats is List && stats.isNotEmpty ? stats[0] : null;
      final splits = firstStat is Map ? firstStat['splits'] : null;
      final firstSplit = splits is List && splits.isNotEmpty ? splits[0] : null;
      final stat = firstSplit is Map ? firstSplit['stat'] : null;
      if (stat is Map) {
        debugPrint(
          '[BASEBALL] MLB Stats API success: pitcherId=$pitcherId, season=$season, era=${stat['era']}',
        );
        return Map<String, dynamic>.from(stat);
      }
      debugPrint(
        '[BASEBALL] MLB Stats API: no stats for pitcherId=$pitcherId, season=$season',
      );
      return null;
    } catch (e) {
      debugPrint('[BASEBALL] MLB Stats API error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getKboPitcherStats({
    required String league,
    required String homePitcher,
    required String awayPitcher,
    required String homeTeam,
    required String awayTeam,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/baseball/kbo-pitcher-stats',
        queryParameters: <String, String>{
          'league': league.toLowerCase(),
          'season': '2026',
          'homePitcher': homePitcher,
          'awayPitcher': awayPitcher,
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
        },
      );
      debugPrint('[BASEBALL] KBO/NPB pitcher stats: ${response.data?.keys}');
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BASEBALL] KBO/NPB pitcher stats error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getBaseballComboPicks({
    String? date,
    int days = 7,
  }) async {
    try {
      final params = <String, dynamic>{
        'days': days,
      };
      if (date != null) params['date'] = date;
      final response = await _dio.get<dynamic>(
        '/api/baseball/combo-picks',
        queryParameters: params,
      );
      debugPrint(
        '[BASEBALL] combo-picks: success=${response.data?['success']}, '
        'picks=${(response.data?['picks'] as List?)?.length}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BASEBALL] combo-picks error: $e');
      return {};
    }
  }

  Future<List<BaseballAnalysisCard>> getUpcomingMatches() async {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final dates = List.generate(
      7,
      (index) => todayDay.add(Duration(days: index)),
    );

    final results = await Future.wait(
      dates.map((date) => getMatches(date: _formatApiDate(date))),
    );

    final byId = <int, BaseballAnalysisCard>{};
    for (final dayMatches in results) {
      for (final match in dayMatches) {
        if (match.matchId == 0) continue;
        byId[match.matchId] = match;
      }
    }

    final merged = byId.values.toList()
      ..sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));

    debugPrint('[BASEBALL] Upcoming analysis matches: ${merged.length}');
    return merged;
  }

  List<BaseballAnalysisCard> _parseAnalysisCards(dynamic raw) {
    final items = _extractItems(raw);
    return items
        .map(BaseballAnalysisCard.fromJson)
        .where((match) => match.matchId != 0 || match.homeTeam.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _extractItems(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      for (final key in const ['matches', 'data', 'results', 'items']) {
        final value = map[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }

    return const [];
  }

  Map<String, dynamic> _adaptToMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'data': data};
  }

  String _formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
