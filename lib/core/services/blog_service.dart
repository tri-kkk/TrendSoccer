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
      print(
        '[BLOG] posts: success=${response.data?['success']}, '
        'count=${(response.data?['data'] as List?)?.length}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BLOG] posts error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getBlogPost(String slug) async {
    try {
      final response = await _dio.get<dynamic>('/api/blog/post/$slug');
      print(
        '[BLOG] post detail: slug=$slug, success=${response.data?['success']}',
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      print('[BLOG] post detail error: $e');
      return {};
    }
  }
}
