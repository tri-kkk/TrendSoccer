import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/web_api_client.dart';

final blogServiceProvider = Provider<BlogService>((ref) {
  return BlogService(ref.watch(webDioProvider));
});

class BlogService {
  BlogService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getBlogPosts({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/blog/posts',
        queryParameters: <String, dynamic>{
          'published': true,
          'category': 'preview',
          'limit': limit,
          'offset': offset,
        },
      );
      debugPrint(
        '[BLOG] posts: success=${response.data?['success']}, '
        'count=${(response.data?['data'] as List?)?.length}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BLOG] posts error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getBlogPost(String slug) async {
    try {
      final response = await _dio.get<dynamic>('/api/blog/post/$slug');
      debugPrint(
        '[BLOG] post detail: slug=$slug, success=${response.data?['success']}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[BLOG] post detail error: $e');
      return {};
    }
  }

  Future<String> fetchLegalContent(String type) async {
    try {
      final response = await _dio.get<dynamic>(
        '/ko/$type',
        options: Options(responseType: ResponseType.plain),
      );
      final html = response.data?.toString() ?? '';
      debugPrint('[LEGAL] Fetched $type: ${html.length} chars');
      return html;
    } catch (e) {
      debugPrint('[LEGAL] Error fetching $type: $e');
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
      debugPrint('[CONTACT] Sending: name=$name, email=$email, subject=$subject');
      final response = await _dio.post<dynamic>(
        '/api/contact',
        data: <String, String>{
          'name': name,
          'email': email,
          'subject': subject,
          'message': message,
        },
      );
      debugPrint('[CONTACT] Response: ${response.data}');
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {'success': false};
    } catch (e) {
      debugPrint('[CONTACT] Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
