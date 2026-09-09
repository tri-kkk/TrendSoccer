import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/web_api_client.dart';

final highlightsServiceProvider = Provider<HighlightsService>((ref) {
  return HighlightsService(ref.watch(webDioProvider));
});

class HighlightsService {
  HighlightsService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getHighlights() async {
    final response = await _dio.get<dynamic>(
      '/api/highlights/scorebat',
      queryParameters: <String, dynamic>{
        'league': 'ALL',
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
