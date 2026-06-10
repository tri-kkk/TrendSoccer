import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';

final fixtureServiceProvider = Provider<FixtureService>((ref) {
  return FixtureService(ref.watch(webDioProvider));
});

class FixtureService {
  FixtureService(this._dio);

  final Dio _dio;

  Future<List<FixtureMatch>> getSoccerFixtures() async {
    try {
      const path = '/api/odds-from-db';
      const queryParameters = <String, String>{
        'league': 'ALL',
        'daysBack': '3',
        'daysAhead': '4',
      };
      final requestUri = Uri(
        path: path,
        queryParameters: queryParameters,
      );
      debugPrint(
        '[FIXTURE] Soccer fixture API URL: '
        '${_dio.options.baseUrl}$requestUri',
      );

      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final matches = _parseFixtures(
        response.data,
        sport: 'soccer',
        label: 'Soccer fixtures (daysBack=3, daysAhead=4)',
        logSoccerFixtureStatusDebug: true,
      )..sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));

      final todayStr = _fixtureDateString(DateTime.now());
      final todaySoccer =
          matches.where((m) => _matchIsOnDate(m, todayStr)).toList();
      if (todaySoccer.isNotEmpty) {
        final first = todaySoccer.first;
        debugPrint(
          '[FIXTURE] Initial load today soccer: ${first.homeTeam} '
          'logo=${first.homeTeamLogo}',
        );
      }
      debugPrint(
        '[FIXTURE] Initial load: total=${matches.length}, '
        'today=${todaySoccer.length}',
      );

      var nonStandardStatusLogs = 0;
      for (final m in matches) {
        if (m.status != 'scheduled' && m.status != 'finished') {
          if (nonStandardStatusLogs >= 5) break;
          debugPrint(
            '[FIXTURE] Non-standard status: matchId=${m.matchId} ${m.homeTeam} vs ${m.awayTeam} rawStatus="${m.rawStatus}" normalizedStatus="${m.status}"',
          );
          nonStandardStatusLogs++;
        }
      }

      final hasKoTeamNames = matches.any(
        (match) =>
            (match.homeTeamKo?.isNotEmpty ?? false) ||
            (match.awayTeamKo?.isNotEmpty ?? false),
      );
      if (matches.isNotEmpty && !hasKoTeamNames) {
        debugPrint(
          '[FIXTURE] Soccer has no KO team names — API field needed',
        );
      }

      debugPrint('[FIXTURE] Soccer fixtures loaded: ${matches.length} matches');
      final dates = matches
          .map((match) {
            final local = match.matchTimestamp.toLocal();
            final month = local.month.toString().padLeft(2, '0');
            final day = local.day.toString().padLeft(2, '0');
            return '${local.year}-$month-$day';
          })
          .toSet()
          .toList()
        ..sort();
      debugPrint('[FIXTURE] Date range: $dates');
      debugPrint(
        '[FIXTURE] Leagues found: ${matches.map((m) => m.leagueCode.isNotEmpty ? m.leagueCode : m.leagueName).toSet().toList()}',
      );
      return matches;
    } catch (e) {
      debugPrint('[FIXTURE] Soccer fixtures failed: $e');
      return const [];
    }
  }

  Future<List<FixtureMatch>> getBaseballFixturesRange() async {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final dates = List.generate(
      7,
      (index) => todayDay.add(Duration(days: index - 2)),
    );

    final results = await Future.wait(
      dates.map((date) => getBaseballFixtures(date: _formatApiDate(date))),
    );

    final merged = results.expand((matches) => matches).toList()
      ..sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));

    debugPrint(
      '[FIXTURE] Baseball fixtures range: ${merged.length} matches from 7 dates',
    );
    return merged;
  }

  String _fixtureDateString(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  bool _matchIsOnDate(FixtureMatch match, String dateStr) {
    final local = match.matchTimestamp.toLocal();
    return _fixtureDateString(local) == dateStr;
  }

  String _formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _baseballStatusForDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);
    final diffDays = targetDay.difference(today).inDays;

    if (diffDays < -1) return 'finished';
    if (diffDays > 1) return 'scheduled';
    return 'all';
  }

  Map<String, String> _baseballQueryParametersForDate(String dateStr) {
    final status = _baseballStatusForDate(dateStr);
    final params = <String, String>{
      'date': dateStr,
      'status': status,
      'limit': '50',
    };
    if (status == 'finished') {
      params['skipML'] = 'true';
    }
    return params;
  }

  Future<List<FixtureMatch>> getBaseballFixtures({required String date}) async {
    try {
      final status = _baseballStatusForDate(date);
      debugPrint('[FIXTURE] Baseball call: date=$date, status=$status');

      final response = await _dio.get<dynamic>(
        '/api/baseball/matches',
        queryParameters: _baseballQueryParametersForDate(date),
      );
      final matches = _parseFixtures(
        response.data,
        sport: 'baseball',
        label: 'Baseball fixtures for $date (status=$status)',
      );
      debugPrint('[FIXTURE] Baseball fixtures for $date: ${matches.length} matches');
      return matches;
    } catch (e) {
      debugPrint('[FIXTURE] Baseball fixtures for $date failed: $e');
      return const [];
    }
  }

  Future<Map<String, LiveMatchData>> getLiveMatches() async {
    try {
      final response = await _dio.get<dynamic>('/api/live-matches');
      final data = response.data;
      final matches = data is Map ? (data['matches'] as List?) ?? [] : [];
      final result = <String, LiveMatchData>{};
      for (final item in matches) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString() ?? map['fixtureId']?.toString();
        if (id != null && id.isNotEmpty) {
          result[id] = LiveMatchData.fromJson(map);
        }
      }
      debugPrint('[FIXTURE] Live matches: ${result.length} active');
      return result;
    } catch (e) {
      debugPrint('[FIXTURE] Live matches error: $e');
      return {};
    }
  }

  List<FixtureMatch> _parseFixtures(
    dynamic raw, {
    required String sport,
    required String label,
    bool logSoccerFixtureStatusDebug = false,
  }) {
    final items = _extractItems(raw);
    _logFirstItemKeys(items, label);

    return [
      for (var i = 0; i < items.length; i++)
        FixtureMatch.fromJson(
          items[i],
          sport: sport,
          statusDebugIndex: logSoccerFixtureStatusDebug ? i : null,
        ),
    ]
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
      for (final key in const [
        'data',
        'matches',
        'results',
        'items',
        'fixtures',
      ]) {
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

  void _logFirstItemKeys(List<Map<String, dynamic>> items, String label) {
    if (items.isEmpty) {
      debugPrint('[FIXTURE] $label: no items in response');
      return;
    }
    debugPrint('[FIXTURE] $label first item keys: ${items.first.keys.toList()}');
  }
}
