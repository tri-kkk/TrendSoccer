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
      print(
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
      print('[BASEBALL] Pitcher analysis success: cached=${data?['cached']}');
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BASEBALL] Pitcher analysis error: $e');
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
      print('[BASEBALL] Analysis matches for $date: ${matches.length}');
      return matches;
    } catch (e) {
      print('[BASEBALL] Analysis matches for $date failed: $e');
      return const [];
    }
  }

  Future<Map<String, dynamic>> getMatchDetail({required int matchId}) async {
    print('[BASEBALL] Match detail request: api_match_id=$matchId');
    try {
      final response = await _dio.get<dynamic>('/api/baseball/matches/$matchId');
      final data = _adaptToMap(response.data);
      print('[BASEBALL] Match detail for $matchId loaded');
      return data;
    } catch (e) {
      print('[BASEBALL] Match detail for $matchId failed: $e');
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
      print(
        '[BASEBALL] H2H for $homeTeamId vs $awayTeamId: ${response.data?['count']} matches',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BASEBALL] H2H error: $e');
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
      print('[BASEBALL] predict response: success=${response.data?['success']}');
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BASEBALL] predict error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getBaseballTeamStats({
    required int teamId,
    required String league,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/baseball/team-stats',
        queryParameters: <String, dynamic>{
          'teamId': teamId,
          'league': league,
        },
      );
      print(
        '[BASEBALL] team-stats for teamId=$teamId: ${response.data?['success']}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BASEBALL] team-stats error: $e');
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
      print(
        '[BASEBALL] MLB pitcher-stats request: homePitcherId=$homePitcherId, awayPitcherId=$awayPitcherId',
      );
      final response = await _dio.get<dynamic>(
        '/api/baseball/pitcher-stats',
        queryParameters: params,
      );
      print('[BASEBALL] MLB pitcher-stats: success=${response.data?['success']}');
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BASEBALL] MLB pitcher-stats error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getMlbPitcherStatsPrevSeason({
    int? homePitcherId,
    int? awayPitcherId,
  }) async {
    try {
      final params = <String, dynamic>{'season': '2025'};
      if (homePitcherId != null) params['homePitcherId'] = homePitcherId;
      if (awayPitcherId != null) params['awayPitcherId'] = awayPitcherId;
      final response = await _dio.get<dynamic>(
        '/api/baseball/pitcher-stats',
        queryParameters: params,
      );
      print(
        '[BASEBALL] MLB pitcher-stats prev season: success=${response.data?['success']}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BASEBALL] MLB pitcher-stats prev season error: $e');
      return {};
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
      print('[BASEBALL] KBO/NPB pitcher stats: ${response.data?.keys}');
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BASEBALL] KBO/NPB pitcher stats error: $e');
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

    print('[BASEBALL] Upcoming analysis matches: ${merged.length}');
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
