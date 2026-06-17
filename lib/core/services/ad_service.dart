import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

class AdService {
  static const _baseUrl = 'https://www.trendsoccer.com';

  /// Fetch ads for a specific slot.
  Future<List<Map<String, dynamic>>> getAds(String slot) async {
    try {
      final dio = Dio();
      final response = await dio.get<dynamic>(
        '$_baseUrl/api/ads',
        queryParameters: <String, dynamic>{
          'slot': slot,
          'active': true,
        },
      );
      final data = response.data;
      if (data is Map && data['ads'] is List) {
        return (data['ads'] as List)
            .map((item) {
              if (item is Map<String, dynamic>) return item;
              if (item is Map) return Map<String, dynamic>.from(item);
              return <String, dynamic>{};
            })
            .where((item) => item.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
            return [];
    }
  }

  /// Track ad impression or click.
  Future<void> trackAd(String adId, String type) async {
    if (adId.isEmpty) return;
    try {
      final dio = Dio();
      await dio.post<dynamic>(
        '$_baseUrl/api/ads/track',
        queryParameters: <String, dynamic>{
          'id': adId,
          'type': type,
        },
      );
          } catch (e) {
          }
  }
}
