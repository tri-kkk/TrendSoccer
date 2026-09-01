import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';

final newsServiceProvider = Provider<NewsService>((ref) {
  return NewsService(
    ref.watch(webDioProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

class NewsService {
  NewsService(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  String _apiLanguage() {
    final lang = getApiLanguage(_prefs);
    return lang;
  }

  Future<Map<String, dynamic>> getNews() async {
    try {
      final lang = _apiLanguage();
      final response = await _dio.get<dynamic>(
        '/api/news',
        queryParameters: <String, String>{
          'lang': lang,
          'ui': lang,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      return {};
    }
  }
}
