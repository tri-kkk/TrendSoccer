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

  static const _analysisTimeout = Duration(seconds: 20);

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
    print('[BASEBALL] Match detail request: dbId=$matchId');
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

  Future<Map<String, dynamic>> getAiAnalysis({required int matchId}) async {
    print('[BASEBALL] AI analysis request: matchId=$matchId');
    try {
      final response = await _dio.get<dynamic>(
        '/api/baseball/pitcher-analysis',
        queryParameters: <String, dynamic>{'matchId': matchId},
        options: Options(receiveTimeout: _analysisTimeout),
      );
      final data = _adaptToMap(response.data);
      print('[BASEBALL] AI analysis for $matchId loaded');
      return data;
    } catch (e) {
      print('[BASEBALL] AI analysis for $matchId failed: $e');
      rethrow;
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
