import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trendsoccer/core/services/fcm_service.dart';
import 'package:trendsoccer/core/services/token_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  /// Get alarm settings for a match
  Future<Map<String, dynamic>> getMatchAlarmSettings(
    int matchId,
    String sport,
  ) async {
    final headers = await _buildHeaders();
    if (!_hasAuthHeaders(headers)) {
      return _defaultSettings(sport);
    }

    try {
      final dio = Dio();
      final response = await dio.get<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/notifications/match/$matchId',
        queryParameters: <String, String>{'sport': sport},
        options: Options(headers: headers),
      );
      debugPrint(
        '[NOTIF] getAlarm: matchId=$matchId, sport=$sport, '
        'status=${response.statusCode}',
      );
      final data = response.data;
      if (data is Map && data['success'] == true) {
        final inner = data['data'];
        if (inner is Map<String, dynamic>) return inner;
        if (inner is Map) return Map<String, dynamic>.from(inner);
      }
      return _defaultSettings(sport);
    } catch (e) {
      debugPrint('[NOTIF] getAlarm error: $e');
      return _defaultSettings(sport);
    }
  }

  Future<Map<String, dynamic>> getMatchAlarmsBatch({
    required List<String> matchIds,
    required String sport,
  }) async {
    if (matchIds.isEmpty) return {};

    final headers = await _buildHeaders();
    if (!_hasAuthHeaders(headers)) {
      return {};
    }

    try {
      final dio = Dio();
      final idsParam = matchIds.join(',');
      final response = await dio.get<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/notifications/matches',
        queryParameters: <String, String>{
          'sport': sport,
          'ids': idsParam,
        },
        options: Options(headers: headers),
      );
      debugPrint(
        '[NOTIF] getAlarmsBatch: sport=$sport, count=${matchIds.length}, '
        'status=${response.statusCode}',
      );

      final data = response.data;
      if (data is! Map) return {};

      final inner = data['data'];
      if (inner is! Map) return {};

      final results = inner['results'];
      if (results is! Map) return {};

      return results.map(
        (id, value) => MapEntry(
          id.toString(),
          value is Map<String, dynamic>
              ? value
              : value is Map
                  ? Map<String, dynamic>.from(value)
                  : <String, dynamic>{},
        ),
      );
    } catch (e) {
      debugPrint('[NOTIF] getAlarmsBatch error: $e');
      return {};
    }
  }

  /// Save alarm settings for a match
  Future<bool> saveMatchAlarmSettings(
    int matchId,
    String sport,
    bool enabled,
    Map<String, bool> events,
  ) async {
    final headers = await _buildHeaders();
    if (!_hasAuthHeaders(headers)) {
      debugPrint('[NOTIF] saveAlarm: no JWT or device token');
      return false;
    }

    try {
      final dio = Dio();
      final response = await dio.put<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/notifications/match/$matchId',
        data: <String, dynamic>{
          'sport': sport,
          'enabled': enabled,
          'events': events,
        },
        options: Options(headers: headers),
      );
      debugPrint(
        '[NOTIF] saveAlarm: matchId=$matchId, enabled=$enabled, '
        'status=${response.statusCode}',
      );
      debugPrint(
        '[ALARM] PUT response: status=${response.statusCode}, '
        'body=${response.data}',
      );
      final data = response.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      debugPrint('[NOTIF] saveAlarm error: $e');
      return false;
    }
  }

  /// Default settings per sport
  Map<String, dynamic> defaultSettings(String sport) => _defaultSettings(sport);

  Map<String, dynamic> _defaultSettings(String sport) {
    if (sport == 'soccer') {
      return <String, dynamic>{
        'enabled': false,
        'events': <String, bool>{
          'kickoff': true,
          'goal': true,
          'halftime': false,
          'secondHalf': true,
          'fulltime': true,
          'yellowCard': false,
          'redCard': true,
          'substitution': false,
        },
      };
    }

    return <String, dynamic>{
      'enabled': false,
      'events': <String, bool>{
        'firstPitch': true,
        'score': true,
        'inningChange': false,
        'homerun': true,
        'gameEnd': true,
      },
    };
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    final jwt = await _getJwt();
    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
    }

    final fcmToken = FCMService().fcmToken;
    if (fcmToken != null && fcmToken.isNotEmpty) {
      headers['X-Device-Token'] = fcmToken;
    }

    return headers;
  }

  bool _hasAuthHeaders(Map<String, String> headers) {
    return headers.containsKey('Authorization') ||
        headers.containsKey('X-Device-Token');
  }

  Future<String?> _getJwt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('auth_jwt');
      if (jwt != null && jwt.isNotEmpty) return jwt;
    } catch (_) {}

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.accessToken.isNotEmpty) {
        return session.accessToken;
      }
    } catch (_) {}

    try {
      final token = await TokenService().getToken();
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}

    return null;
  }
}
