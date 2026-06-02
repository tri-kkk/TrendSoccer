import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trendsoccer/core/services/token_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize FCM: request permission, get token, setup handlers
  Future<void> init() async {
    debugPrint('[FCM] ===== init() START =====');
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    _fcmToken = await _messaging.getToken();
    debugPrint('[FCM] Token: $_fcmToken');

    if (_fcmToken != null) {
      await registerDevice(_fcmToken);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      _fcmToken = newToken;
      registerDevice(newToken);
    });

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'trendsoccer_matches',
      '경기 알림',
      description: '경기 이벤트 알림',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    debugPrint('[FCM] init complete');
  }

  /// Register device token with backend
  Future<void> registerDevice([String? token]) async {
    final fcmToken = token ?? _fcmToken;
    if (fcmToken == null) {
      debugPrint('[FCM] registerDevice: no token');
      return;
    }

    final jwt = await _getJwt();
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
      debugPrint('[FCM] registerDevice: with JWT (authenticated)');
    } else {
      debugPrint('[FCM] registerDevice: anonymous (no JWT)');
    }

    try {
      final dio = Dio();
      final response = await dio.post<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/devices',
        data: <String, String>{
          'token': fcmToken,
          'platform': 'android',
          'appVersion': '0.1.2',
          'locale': 'ko',
        },
        options: Options(headers: headers),
      );
      var anonymous = false;
      final data = response.data;
      if (data is Map) {
        final inner = data['data'];
        if (inner is Map) {
          anonymous = inner['anonymous'] == true;
        }
      }
      debugPrint(
        '[FCM] registerDevice: ${response.statusCode}, anonymous=$anonymous',
      );
    } catch (e) {
      debugPrint('[FCM] registerDevice error: $e');
    }
  }

  /// Call after login to migrate anonymous settings to user account
  Future<void> migrateToUser() async {
    final jwt = await _getJwt();
    final fcmToken = _fcmToken;
    if (jwt == null || fcmToken == null) {
      debugPrint('[FCM] migrate: missing jwt or token');
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.post<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/notifications/migrate',
        data: <String, String>{'token': fcmToken},
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
      );
      debugPrint('[FCM] migrate: ${response.data}');
    } catch (e) {
      debugPrint('[FCM] migrate error: $e');
    }
  }

  /// Unregister device token (on logout)
  Future<void> unregisterDevice() async {
    final jwt = await _getJwt();
    if (jwt == null) {
      debugPrint('[FCM] unregisterDevice: no JWT, skipping');
      return;
    }

    try {
      final dio = Dio();
      await dio.delete<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/devices',
        data: _fcmToken != null ? <String, String>{'token': _fcmToken!} : null,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
      );
      debugPrint('[FCM] unregisterDevice: success');
    } catch (e) {
      debugPrint('[FCM] unregisterDevice error: $e');
    }
  }

  /// Handle foreground message — show local notification
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] foreground: ${message.notification?.title}');
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trendsoccer_matches',
          '경기 알림',
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Handle notification tap (background/terminated)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] opened: ${message.data}');
    // TODO: navigate to match detail based on message.data
  }

  /// Get JWT from multiple sources
  Future<String?> _getJwt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('auth_jwt');
      if (jwt != null && jwt.isNotEmpty) {
        debugPrint('[FCM] JWT found in SharedPreferences');
        return jwt;
      }
    } catch (_) {}

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.accessToken.isNotEmpty) {
        debugPrint('[FCM] JWT found in Supabase session');
        return session.accessToken;
      }
    } catch (_) {}

    try {
      final tokenService = TokenService();
      final token = await tokenService.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('[FCM] JWT found in TokenService');
        return token;
      }
    } catch (_) {}

    debugPrint('[FCM] _getJwt: no JWT from any source');
    return null;
  }
}
