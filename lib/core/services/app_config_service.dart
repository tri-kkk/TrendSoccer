import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/app_config_model.dart';

final appConfigServiceProvider = Provider<AppConfigService>((ref) {
  return AppConfigService();
});

class AppConfigService {
  Future<AppConfigData?> fetchConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      return AppConfigData(
        minSupportedVersion: remoteConfig.getString('min_supported_version'),
        latestVersion: remoteConfig.getString('latest_version'),
        forceUpdate: remoteConfig.getBool('force_update'),
        updateMessage: _nonEmpty(remoteConfig.getString('update_message')),
        maintenanceMode: remoteConfig.getBool('maintenance_mode'),
        maintenanceMessage:
            _nonEmpty(remoteConfig.getString('maintenance_message')),
      );
    } on Object {
      return null;
    }
  }
}

String? _nonEmpty(String s) => s.isEmpty ? null : s;
