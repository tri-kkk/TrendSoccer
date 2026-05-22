import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/web_api_client.dart';

final baseballComboServiceProvider = Provider<BaseballComboService>((ref) {
  return BaseballComboService(ref.watch(webDioProvider));
});

class BaseballComboService {
  BaseballComboService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getTodayComboStats() async {
    final today = _formatApiDate(DateTime.now());
    return getComboPicks(date: today);
  }

  Future<Map<String, dynamic>> getComboPicks({required String date}) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/baseball/combo-picks',
        queryParameters: <String, String>{'date': date},
      );
      final data = _adaptToMap(response.data);
      print('[BASEBALL] Combo picks response keys: ${data.keys.toList()}');

      final firstItem = _firstComboItem(data);
      if (firstItem != null) {
        print(
          '[BASEBALL] Combo picks for today: first item keys: '
          '${firstItem.keys.toList()}',
        );
      } else {
        print('[BASEBALL] Combo picks for today: no combo items found');
      }

      return data;
    } catch (e) {
      print('[BASEBALL] Combo picks for $date failed: $e');
      return const {};
    }
  }

  Map<String, dynamic>? _firstComboItem(Map<String, dynamic> data) {
    for (final key in const [
      'combos',
      'comboPicks',
      'combo_picks',
      'picks',
      'items',
      'data',
    ]) {
      final value = data[key];
      if (value is List && value.isNotEmpty && value.first is Map) {
        return Map<String, dynamic>.from(value.first as Map);
      }
      if (value is Map<String, dynamic>) {
        for (final nestedKey in const ['combos', 'items', 'picks']) {
          final nested = value[nestedKey];
          if (nested is List && nested.isNotEmpty && nested.first is Map) {
            return Map<String, dynamic>.from(nested.first as Map);
          }
        }
      }
    }
    return null;
  }

  Map<String, dynamic> _adaptToMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'data': data};
  }

  String _formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
