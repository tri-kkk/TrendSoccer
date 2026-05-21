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
      final response = await _dio.get<dynamic>(
        '/api/odds-from-db',
        queryParameters: const <String, String>{
          'league': 'ALL',
          'daysAhead': '7',
        },
      );
      final matches = _parseFixtures(
        response.data,
        sport: 'soccer',
        label: 'Soccer fixtures (odds-from-db)',
      );

      print('[FIXTURE] Total soccer fixtures loaded: ${matches.length}');
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
      print('[FIXTURE] Date range: $dates');
      print(
        '[FIXTURE] Leagues found: ${matches.map((m) => m.leagueCode.isNotEmpty ? m.leagueCode : m.leagueName).toSet().toList()}',
      );
      return matches;
    } catch (e) {
      print('[FIXTURE] Soccer fixtures (odds-from-db) failed: $e');
      return const [];
    }
  }

  Future<List<FixtureMatch>> getBaseballFixtures({required String date}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/baseball/matches',
        queryParameters: <String, String>{'date': date},
      );
      final matches = _parseFixtures(
        response.data,
        sport: 'baseball',
        label: 'Baseball fixtures for $date',
      );
      print('[FIXTURE] Baseball fixtures for $date: ${matches.length} matches');
      return matches;
    } catch (e) {
      print('[FIXTURE] Baseball fixtures for $date failed: $e');
      return const [];
    }
  }

  Future<List<FixtureMatch>> getLiveMatches() async {
    try {
      final response = await _dio.get<dynamic>('/api/live-matches');
      return _parseFixtures(
        response.data,
        sport: 'soccer',
        label: 'Live matches',
      );
    } catch (e) {
      print('[FIXTURE] Live matches failed: $e');
      return const [];
    }
  }

  List<FixtureMatch> _parseFixtures(
    dynamic raw, {
    required String sport,
    required String label,
  }) {
    final items = _extractItems(raw);
    _logFirstItemKeys(items, label);

    return items
        .map((json) => FixtureMatch.fromJson(json, sport: sport))
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
      print('[FIXTURE] $label: no items in response');
      return;
    }
    print('[FIXTURE] $label first item keys: ${items.first.keys.toList()}');
  }
}
