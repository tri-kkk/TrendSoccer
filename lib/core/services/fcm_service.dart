import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trendsoccer/core/router/app_router.dart';
import 'package:trendsoccer/core/constants/alarm_preference_keys.dart';
import 'package:trendsoccer/core/services/token_service.dart';

class FCMService {
  static const String prefAppGeneral = 'notification_app_general';
  static const String prefMatchEvents = 'notification_match_events';
  static const String prefMarketing = 'notification_marketing';

  static const String topicAppGeneral = 'app_general';
  static const String topicMatchEvents = 'match_events';
  static const String topicMarketing = 'marketing';

  static const String _prefPermissionAsked = 'fcm_permission_asked';
  static const String _languageKey = 'language_code';

  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  static String topicWithLocale(String baseTopic, String locale) =>
      '${baseTopic}_$locale';

  static String localeFromPrefs(SharedPreferences prefs) {
    final code = prefs.getString(_languageKey);
    return code == 'en' ? 'en' : 'ko';
  }

  /// Initialize FCM: request permission, get token, setup handlers
  Future<void> init() async {
    
    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool(_prefPermissionAsked) ?? false;

    if (!alreadyAsked) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await prefs.setBool(_prefPermissionAsked, true);
      
      if (!prefs.containsKey(prefAppGeneral)) {
        await _handleFirstPermissionResult(
          prefs,
          _isFcmAuthorized(settings.authorizationStatus),
        );
      }
    } else {
      final currentSettings = await _messaging.getNotificationSettings();
      
      if (!prefs.containsKey(prefAppGeneral)) {
        await _handleFirstPermissionResult(
          prefs,
          _isFcmAuthorized(currentSettings.authorizationStatus),
        );
      }
    }

    if (prefs.containsKey(prefAppGeneral)) {
      await _syncEnabledTopicsFromPrefs(prefs);
    }

    _fcmToken = await _messaging.getToken();
    
    if (_fcmToken != null) {
      await registerDevice(_fcmToken);
    }

    _messaging.onTokenRefresh.listen((newToken) {
            _fcmToken = newToken;
      registerDevice(newToken);
    });

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    const channel = AndroidNotificationChannel(
      'trendsoccer_matches',
      'Match Notifications',
      description: 'Match event notifications',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      }

  /// Handle cold-start notification tap after the router is ready.
  Future<void> handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) return;

        navigateFromPushData(message.data);
  }

  /// Subscribe all topics and save prefs when permission is first granted (e.g. from menu).
  Future<void> subscribeAllTopicsOnFirstPermissionGrant() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefAppGeneral)) return;

    await subscribeAllTopics();
      }

  /// Unsubscribe all topics and save prefs as off.
  Future<void> unsubscribeAllTopics() async {
    final prefs = await SharedPreferences.getInstance();
    await _unsubscribeAllTopicVariants();
    await _setAllTopicsOff(prefs);
      }

  /// Subscribe all topics and save prefs as on.
  Future<void> subscribeAllTopics() async {
    final prefs = await SharedPreferences.getInstance();
    await _subscribeAllTopics(prefs);
      }

  /// Toggle a single topic for the current locale.
  Future<void> setTopicEnabled({
    required String baseTopic,
    required String prefKey,
    required bool enabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final locale = localeFromPrefs(prefs);
    final topic = topicWithLocale(baseTopic, locale);

    if (enabled) {
      await _messaging.subscribeToTopic(topic);
      await prefs.setBool(prefKey, true);
          } else {
      await _messaging.unsubscribeFromTopic(topic);
      await prefs.setBool(prefKey, false);
          }
  }

  /// Re-subscribe enabled topics when the app language changes.
  Future<void> onLocaleChanged({
    required String previousLocale,
    required String newLocale,
  }) async {
    if (previousLocale == newLocale) return;

    final prefs = await SharedPreferences.getInstance();
    final topicConfigs = <(String prefKey, String baseTopic)>[
      (prefAppGeneral, topicAppGeneral),
      (prefMatchEvents, topicMatchEvents),
      (prefMarketing, topicMarketing),
    ];

    for (final (prefKey, baseTopic) in topicConfigs) {
      if (prefs.getBool(prefKey) ?? false) {
        await _messaging.unsubscribeFromTopic(
          topicWithLocale(baseTopic, previousLocale),
        );
        await _messaging.subscribeToTopic(
          topicWithLocale(baseTopic, newLocale),
        );
      }
    }

        if (_fcmToken != null) {
      await registerDevice(_fcmToken);
    }
  }

  Future<void> _handleFirstPermissionResult(
    SharedPreferences prefs,
    bool granted,
  ) async {
    await prefs.setBool(prefAppGeneral, granted);
    await prefs.setBool(prefMatchEvents, granted);
    await prefs.setBool(prefMarketing, granted);

    for (final key in AlarmPreferenceKeys.allSoccerKeys) {
      await prefs.setBool(key, granted);
    }
    for (final key in AlarmPreferenceKeys.allBaseballKeys) {
      await prefs.setBool(key, granted);
    }

    if (granted) {
      final locale = localeFromPrefs(prefs);
      await _unsubscribeLegacyTopics();
      await _messaging.subscribeToTopic(topicWithLocale(topicAppGeneral, locale));
      await _messaging.subscribeToTopic(topicWithLocale(topicMatchEvents, locale));
      await _messaging.subscribeToTopic(topicWithLocale(topicMarketing, locale));
          } else {
      await _unsubscribeAllTopicVariants();
          }
  }

  static bool _isFcmAuthorized(AuthorizationStatus status) {
    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  Future<void> _subscribeAllTopics(SharedPreferences prefs) async {
    final locale = localeFromPrefs(prefs);
    await _unsubscribeLegacyTopics();
    await _messaging.subscribeToTopic(topicWithLocale(topicAppGeneral, locale));
    await _messaging.subscribeToTopic(topicWithLocale(topicMatchEvents, locale));
    await _messaging.subscribeToTopic(topicWithLocale(topicMarketing, locale));
    await prefs.setBool(prefAppGeneral, true);
    await prefs.setBool(prefMatchEvents, true);
    await prefs.setBool(prefMarketing, true);
      }

  Future<void> _syncEnabledTopicsFromPrefs(SharedPreferences prefs) async {
    final locale = localeFromPrefs(prefs);
    await _unsubscribeLegacyTopics();

    final topicConfigs = <(String prefKey, String baseTopic)>[
      (prefAppGeneral, topicAppGeneral),
      (prefMatchEvents, topicMatchEvents),
      (prefMarketing, topicMarketing),
    ];

    for (final (prefKey, baseTopic) in topicConfigs) {
      final enabled = prefs.getBool(prefKey) ?? false;
      final topic = topicWithLocale(baseTopic, locale);
      if (enabled) {
        await _messaging.subscribeToTopic(topic);
              } else {
        await _messaging.unsubscribeFromTopic(topic);
              }
    }
  }

  Future<void> _unsubscribeLegacyTopics() async {
    await _messaging.unsubscribeFromTopic(topicAppGeneral);
    await _messaging.unsubscribeFromTopic(topicMatchEvents);
    await _messaging.unsubscribeFromTopic(topicMarketing);
  }

  Future<void> _unsubscribeAllTopicVariants() async {
    await _unsubscribeLegacyTopics();
    for (final locale in const ['ko', 'en']) {
      for (final base in const [
        topicAppGeneral,
        topicMatchEvents,
        topicMarketing,
      ]) {
        await _messaging.unsubscribeFromTopic(topicWithLocale(base, locale));
      }
    }
  }

  Future<void> _setAllTopicsOff(SharedPreferences prefs) async {
    await prefs.setBool(prefAppGeneral, false);
    await prefs.setBool(prefMatchEvents, false);
    await prefs.setBool(prefMarketing, false);
  }

  /// Register device token with backend
  Future<void> registerDevice([String? token]) async {
    final fcmToken = token ?? _fcmToken;
    if (fcmToken == null) {
            return;
    }

    final jwt = await _getJwt();
    final headers = <String, String>{'Content-Type': 'application/json'};
    final prefs = await SharedPreferences.getInstance();
    final locale = localeFromPrefs(prefs);

    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
    }

    try {
      final dio = Dio();
      debugPrint('[FCM] registerDevice: locale=$locale');
      await dio.post<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/devices',
        data: <String, String>{
          'token': fcmToken,
          'platform': 'android',
          'appVersion': '0.1.2',
          'locale': locale,
        },
        options: Options(headers: headers),
      );
    } on Object {
      // Device registration is best-effort.
    }
  }

  /// Call after login to migrate anonymous settings to user account
  Future<void> migrateToUser() async {
    final jwt = await _getJwt();
    final fcmToken = _fcmToken;
    if (jwt == null || fcmToken == null) {
            return;
    }

    try {
      final dio = Dio();
      await dio.post<dynamic>(
        'https://www.trendsoccer.com/api/v1/mobile/notifications/migrate',
        data: <String, String>{'token': fcmToken},
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $jwt',
          },
        ),
      );
    } on Object {
      // Migration is best-effort.
    }
  }

  /// Unregister device token (on logout)
  Future<void> unregisterDevice() async {
    final jwt = await _getJwt();
    if (jwt == null) {
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
          } catch (e) {
          }
  }

  Future<Uint8List?> _downloadImage(String url) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 5),
          responseType: ResponseType.bytes,
        ),
      );
      final response = await dio
          .get<List<int>>(url)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      }
    } catch (e) {
          }
    return null;
  }

  Future<AndroidNotificationDetails> _buildAndroidNotificationDetails(
    Map<String, dynamic> data,
  ) async {
    final teamLogo = data['teamLogo']?.toString();
    ByteArrayAndroidBitmap? largeIcon;

    if (teamLogo != null && teamLogo.isNotEmpty) {
      final imageBytes = await _downloadImage(teamLogo);
      if (imageBytes != null) {
        largeIcon = ByteArrayAndroidBitmap(imageBytes);
              }
    }

    return AndroidNotificationDetails(
      'trendsoccer_matches',
      'Match Notifications',
      icon: '@drawable/ic_notification',
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: largeIcon,
    );
  }

  /// Handle foreground message — show local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
        final notification = message.notification;
    if (notification == null) return;

    final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;
    final androidDetails = await _buildAndroidNotificationDetails(message.data);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        navigateFromPushData(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
          }
  }

  /// Handle notification tap (background)
  void _handleMessageOpenedApp(RemoteMessage message) {
        navigateFromPushData(message.data);
  }

  void navigateFromPushData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    if (type == 'topic') {
            return;
    }
    if (type != 'match_event') {
            return;
    }

    final sport = data['sport']?.toString();
    if (sport != 'soccer' && sport != 'baseball') {
            return;
    }

        AppRouter.router.go('/fixture?sport=$sport&filter=live');
  }

  /// Get JWT from multiple sources
  Future<String?> _getJwt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('auth_jwt');
      if (jwt != null && jwt.isNotEmpty) {
                return jwt;
      }
    } catch (_) {}

    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.accessToken.isNotEmpty) {
                return session.accessToken;
      }
    } catch (_) {}

    try {
      final tokenService = TokenService();
      final token = await tokenService.getToken();
      if (token != null && token.isNotEmpty) {
                return token;
      }
    } catch (_) {}

        return null;
  }
}
