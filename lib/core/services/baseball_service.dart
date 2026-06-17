import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';

final baseballServiceProvider = Provider<BaseballService>((ref) {
  return BaseballService(
    ref.watch(webDioProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

class BaseballService {
  BaseballService(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  String _apiLanguage() {
    final lang = getApiLanguage(_prefs);
        return lang;
  }


  Future<Map<String, dynamic>> getPitcherAnalysis({
    required int matchId,
    required String homeTeam,
    required String awayTeam,
    String? homePitcher,
    String? awayPitcher,
    Map<String, dynamic>? homeStats,
    Map<String, dynamic>? awayStats,
    required String league,
  }) async {
    try {
      final language = _apiLanguage();
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
            final response = await _dio.post<dynamic>(
        '/api/baseball/pitcher-analysis',
        data: body,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      final data = response.data;
            if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
            return {};
    }
  }

  Future<List<BaseballAnalysisCard>> getMatches({
    required String date,
    String? league,
  }) async {
    try {
      final language = _apiLanguage();
      final response = await _dio.get<dynamic>(
        '/api/baseball/matches',
        queryParameters: <String, String>{
          'date': date,
          'status': 'scheduled',
          'limit': '50',
          'language': language,
        },
      );
      var matches = _parseAnalysisCards(response.data);
      if (league != null && league.isNotEmpty) {
        final normalizedLeague = league.trim().toUpperCase();
        matches = matches
            .where((match) => match.league.toUpperCase() == normalizedLeague)
            .toList();
      }
            return matches;
    } catch (e) {
            return const [];
    }
  }

  Future<Map<String, dynamic>> getMatchDetail({required int matchId}) async {
        try {
      final language = _apiLanguage();
      final response = await _dio.get<dynamic>(
        '/api/baseball/matches',
        queryParameters: <String, dynamic>{
          'id': matchId,
          'skipML': true,
          'language': language,
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

                  
      if (match != null) {
        return {'match': match};
      }
            return responseData;
    } catch (e) {
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
            final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
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
      final language = _apiLanguage();
      final body = <String, dynamic>{
        'matchId': matchId,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'quick': quick,
        'language': language,
      };
      final response = await _dio.post<dynamic>(
        '/api/baseball/predict',
        data: body,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
            final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
            return {};
    }
  }

  Future<Map<String, dynamic>> getBaseballTeamStats({
    required int teamId,
  }) async {
    try {
            final response = await _dio.get<dynamic>(
        '/api/baseball/team-stats',
        queryParameters: <String, dynamic>{
          'teamId': teamId,
        },
      );
      final data = response.data;
            if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
            return {};
    }
  }

  Future<Map<String, dynamic>> getMlbPitcherStats({
    required int matchId,
    int? homePitcherId,
    int? awayPitcherId,
  }) async {
    try {
      final language = _apiLanguage();
      final queryParameters = <String, String>{
        'language': language,
        'matchId': matchId.toString(),
      };
      if (homePitcherId != null) {
        queryParameters['homePitcherId'] = homePitcherId.toString();
      }
      if (awayPitcherId != null) {
        queryParameters['awayPitcherId'] = awayPitcherId.toString();
      }
      const path = '/api/baseball/pitcher-stats';
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      final map = data is Map<String, dynamic>
          ? data
          : data is Map
              ? Map<String, dynamic>.from(data)
              : <String, dynamic>{};
      return map;
    } catch (e) {
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
                return Map<String, dynamic>.from(stat);
      }
            return null;
    } catch (e) {
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
      final language = _apiLanguage();
      const path = '/api/baseball/kbo-pitcher-stats';
      final queryParameters = <String, String>{
        'league': league.toLowerCase(),
        'season': '2026',
        'homePitcher': homePitcher,
        'awayPitcher': awayPitcher,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'language': language,
      };
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
            final data = response.data;
      final map = data is Map<String, dynamic>
          ? data
          : data is Map
              ? Map<String, dynamic>.from(data)
              : <String, dynamic>{};
      return map;
    } catch (e) {
            return {};
    }
  }

  Future<Map<String, dynamic>> getBaseballComboPicks({
    String? date,
    int days = 7,
  }) async {
    try {
      final language = _apiLanguage();
      final params = <String, dynamic>{
        'days': days,
        'language': language,
      };
      if (date != null) params['date'] = date;
      final response = await _dio.get<dynamic>(
        '/api/baseball/combo-picks',
        queryParameters: params,
      );
            final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
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
