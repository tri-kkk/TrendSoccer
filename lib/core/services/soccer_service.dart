import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';

final soccerServiceProvider = Provider<SoccerService>((ref) {
  return SoccerService(ref.watch(webDioProvider));
});

class SoccerService {
  SoccerService(this._dio);

  final Dio _dio;

  static const _analysisTimeout = Duration(seconds: 20);

  // TODO: Replace with /api/v1/mobile/soccer/matches when available
  Future<List<SoccerAnalysisCard>> getMatches({
    required String date,
    String? league,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/odds-from-db',
        queryParameters: <String, String>{'date': date},
      );
      final cards = _adaptToAnalysisCards(response.data);
      if (league == null || league.isEmpty) return cards;
      return cards.where((card) => _matchesLeague(card, league)).toList();
    } catch (e) {
      return [];
    }
  }

  // TODO: Replace with /api/v1/mobile/soccer/analysis when available
  Future<Map<String, dynamic>> getMatchAnalysis({required int matchId}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/analysis',
        queryParameters: <String, dynamic>{'matchId': matchId},
        options: Options(receiveTimeout: _analysisTimeout),
      );
      return _adaptToMap(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // TODO: Replace with /api/v1/mobile/soccer/premium when available
  Future<Map<String, dynamic>> getMatchPremium({required int matchId}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/h2h-enhanced',
        queryParameters: <String, dynamic>{'matchId': matchId},
      );
      return _adaptToMap(response.data);
    } catch (_) {
      try {
        final response = await _dio.get<dynamic>(
          '/api/h2h',
          queryParameters: <String, dynamic>{'matchId': matchId},
        );
        return _adaptToMap(response.data);
      } catch (e) {
        rethrow;
      }
    }
  }

  // TODO: Replace with /api/v1/mobile/soccer/premium-picks when available
  Future<List<SoccerAnalysisCard>> getPremiumPicks({
    required String date,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/premium-picks',
        queryParameters: <String, String>{'date': date},
      );
      return _adaptToAnalysisCards(response.data)
          .map(
            (card) => card.copyWith(
              grade: card.grade ?? 'PREMIUM_PICK',
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // TODO: Replace with /api/v1/mobile/soccer/premium-picks/stats when available
  Future<Map<String, dynamic>> getPremiumPickStats({int days = 7}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/premium-picks/stats',
        queryParameters: <String, int>{'days': days},
      );
      return _adaptToMap(response.data);
    } catch (e) {
      return {};
    }
  }

  List<SoccerAnalysisCard> _adaptToAnalysisCards(dynamic data) {
    final items = _extractList(data);
    return items
        .whereType<Map<String, dynamic>>()
        .map(SoccerAnalysisCard.fromJson)
        .toList();
  }

  Map<String, dynamic> _adaptToMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'data': data};
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in const [
        'matches',
        'data',
        'items',
        'results',
        'picks',
        'premiumPicks',
        'premium_picks',
      ]) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    if (data is Map) {
      return _extractList(Map<String, dynamic>.from(data));
    }
    return const [];
  }

  bool _matchesLeague(SoccerAnalysisCard card, String league) {
    final normalized = league.trim().toLowerCase();
    final info = card.match.league;
    return info.code?.toLowerCase() == normalized ||
        info.name.toLowerCase() == normalized ||
        info.id.toString() == normalized;
  }
}
