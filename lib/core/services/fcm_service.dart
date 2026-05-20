import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/services/api_service.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref.watch(apiServiceProvider));
});

class FcmService {
  FcmService(this._api);

  final ApiService _api;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const _devicesPath = '/api/v1/mobile/devices';

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Configures foreground and tap handlers. Call once after [Firebase.initializeApp].
  static void configureForegroundListeners() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] onMessage: ${message.messageId}');
      _logMessage(message);
      // TODO: Implement notification tap navigation in later step
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] onMessageOpenedApp: ${message.messageId}');
      _logMessage(message);
      // TODO: Implement notification tap navigation in later step
    });
  }

  static void _logMessage(RemoteMessage message) {
    debugPrint(
      '[FCM] message received: id=${message.messageId}, '
      'title=${message.notification?.title}, '
      'body=${message.notification?.body}',
    );
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: false,
      badge: true,
      sound: true,
      provisional: true,
    );

    final token = await _messaging.getToken();
    if (token != null) {
      await registerToken(token);
    }

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(registerToken);
  }

  Future<void> registerToken(String token) async {
    try {
      await _api.post<Object?>(
        _devicesPath,
        data: <String, String>{
          'deviceToken': token,
          'platform': 'android',
          'appVersion': '1.0.0',
          'locale': 'ko',
        },
        fromJson: (json) => json,
      );
      debugPrint('[FCM] device token registered');
    } on ApiException catch (e) {
      debugPrint('[FCM] registerToken failed: $e');
    } on DioException catch (e) {
      debugPrint('[FCM] registerToken network error: $e');
    } catch (e) {
      debugPrint('[FCM] registerToken failed: $e');
    }
  }

  void onMessageReceived(RemoteMessage message) {
    debugPrint(
      '[FCM] message received: id=${message.messageId}, '
      'title=${message.notification?.title}, '
      'body=${message.notification?.body}',
    );
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _initialized = false;
  }
}
