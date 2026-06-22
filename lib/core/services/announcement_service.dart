import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementConfig {
  const AnnouncementConfig({
    required this.id,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.url,
    required this.enabled,
  });

  final String id;
  final String title;
  final String message;
  final String buttonText;
  final String url;
  final bool enabled;

  factory AnnouncementConfig.fromJson(Map<String, dynamic> json) {
    return AnnouncementConfig(
      enabled: (json['enabled'] as bool?) ?? false,
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      buttonText: (json['buttonText'] as String?) ?? '',
      url: (json['url'] as String?) ?? (json['actionUrl'] as String?) ?? '',
    );
  }
}

class AnnouncementService {
  static const String _dismissedIdKey = 'announcement_dismissed_id';

  final SharedPreferences _prefs;

  AnnouncementService(this._prefs);

  Future<AnnouncementConfig?> fetchAnnouncement(String locale) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await remoteConfig.fetchAndActivate();

      final key = 'announcement_$locale';
      final jsonString = remoteConfig.getString(key);

      final trimmed = jsonString.trim();
      if (trimmed.isEmpty) return null;

      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) return null;

      return AnnouncementConfig.fromJson(Map<String, dynamic>.from(decoded));
    } on Object {
      return null;
    }
  }

  bool shouldShow(AnnouncementConfig config) {
    if (!config.enabled) return false;
    if (config.id.isEmpty || config.title.isEmpty) return false;

    final dismissed = _prefs.getString(_dismissedIdKey);
    return dismissed != config.id;
  }

  Future<void> markDismissed(String id) async {
    await _prefs.setString(_dismissedIdKey, id);
  }
}
