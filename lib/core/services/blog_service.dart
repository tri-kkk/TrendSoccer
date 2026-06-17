import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';

final blogServiceProvider = Provider<BlogService>((ref) {
  return BlogService(
    ref.watch(webDioProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

class BlogService {
  BlogService(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  String _apiLanguage() {
    final lang = getApiLanguage(_prefs);
        return lang;
  }

  Future<Map<String, dynamic>> getBlogPosts({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final lang = _apiLanguage();
      final response = await _dio.get<dynamic>(
        '/api/blog/posts',
        queryParameters: <String, dynamic>{
          'published': true,
          'lang': lang,
          'category': 'preview',
          'limit': limit,
          'offset': offset,
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

  Future<Map<String, dynamic>> getBlogPost(String slug) async {
    try {
      final lang = _apiLanguage();
      final response = await _dio.get<dynamic>(
        '/api/blog/post/$slug',
        queryParameters: <String, String>{'lang': lang},
      );
            final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
            return {};
    }
  }

  Future<String> fetchLegalContent(String type) async {
    try {
      final locale = _apiLanguage();
      final response = await _dio.get<dynamic>(
        '/$locale/$type',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
            return html;
    } catch (e) {
            return '';
    }
  }

  Future<Map<String, dynamic>> sendContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
            final response = await _dio.post<dynamic>(
        '/api/contact',
        data: <String, String>{
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        },
      );
            final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {'success': false};
    } catch (e) {
            return {'success': false, 'error': e.toString()};
    }
  }
}
