import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  /// Get alarm settings for a match
  Future<Map<String, dynamic>> getMatchAlarmSettings(
    int matchId,
    String sport,
  ) async {
    final jwt = await _getJwt();
    if (jwt == null) return _defaultSettings(sport);

    try {
      final dio = Dio();
      final response = await dio.get<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/notifications/match/$matchId',
        queryParameters: <String, String>{'sport': sport},
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $jwt'},
        ),
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

  /// Save alarm settings for a match
  Future<bool> saveMatchAlarmSettings(
    int matchId,
    String sport,
    bool enabled,
    Map<String, bool> events,
  ) async {
    final jwt = await _getJwt();
    if (jwt == null) return false;

    try {
      final dio = Dio();
      final response = await dio.put<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/notifications/match/$matchId',
        data: <String, dynamic>{
          'sport': sport,
          'enabled': enabled,
          'events': events,
        },
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
      );
      debugPrint(
        '[NOTIF] saveAlarm: matchId=$matchId, enabled=$enabled, '
        'status=${response.statusCode}',
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

  Future<String?> _getJwt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('auth_jwt');
      if (jwt != null && jwt.isNotEmpty) return jwt;
    } catch (_) {}

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) return session.accessToken;
    } catch (_) {}

    return null;
  }
}
