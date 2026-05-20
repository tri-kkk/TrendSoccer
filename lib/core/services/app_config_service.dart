import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/app_config_model.dart';
import 'package:trendsoccer/core/services/api_service.dart';

final appConfigServiceProvider = Provider<AppConfigService>((ref) {
  return AppConfigService(ref.watch(apiServiceProvider));
});

class AppConfigService {
  AppConfigService(this._api);

  final ApiService _api;

  static const _appConfigPath = '/api/v1/mobile/app-config';

  Future<AppConfigData?> fetchConfig() async {
    try {
      return await _api.get<AppConfigData>(
        _appConfigPath,
        fromJson: (json) =>
            AppConfigData.fromJson(json! as Map<String, dynamic>),
      );
    } catch (_) {
      return null;
    }
  }
}
