import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trendsoccer/core/config/app_config.dart';
import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/token_service.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref);
});

class PaymentService {
  PaymentService(this._ref);

  final Ref _ref;

  static const _authJwtKey = 'auth_jwt';
  static const _initPaymentPath = '/api/payment/seedpay/init';
  static const _subscriptionPath = '/api/subscription';

  Future<Map<String, String>> _buildAuthHeaders({String? jwt}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
    } else {
      final prefs = _ref.read(sharedPreferencesProvider);
      final storedJwt = prefs.getString(_authJwtKey);
      if (storedJwt != null && storedJwt.isNotEmpty) {
        headers['Authorization'] = 'Bearer $storedJwt';
      } else {
        final token = await _ref.read(tokenServiceProvider).getToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        } else {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
        }
      }
    }

    return headers;
  }

  /// POST /api/payment/seedpay/init — returns full API body (success, formData, terms).
  Future<Map<String, dynamic>> initPayment({
    required String plan,
    String? jwt,
  }) async {
    final headers = await _buildAuthHeaders(jwt: jwt);
    final baseUrl = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final dio = Dio();

    try {
      final response = await dio.post<dynamic>(
        '$baseUrl$_initPaymentPath',
        data: <String, dynamic>{'plan': plan},
        options: Options(headers: headers),
      );

      final map = _coerceMap(response.data);
      if (map == null) {
        throw const ApiException(
          code: 'INVALID_RESPONSE',
          message: 'Invalid payment init response',
        );
      }

      print('[PAYMENT] init: plan=$plan, success=${map['success']}');
      return map;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// GET /api/subscription?email= — returns subscription data map.
  Future<Map<String, dynamic>?> checkSubscription({
    required String email,
    String? jwt,
  }) async {
    final headers = await _buildAuthHeaders(jwt: jwt);
    final baseUrl = AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final dio = Dio();

    try {
      final response = await dio.get<dynamic>(
        '$baseUrl$_subscriptionPath',
        queryParameters: <String, String>{'email': email},
        options: Options(headers: headers),
      );

      final map = _coerceMap(response.data);
      if (map == null) return null;

      final data = _unwrapData(map);
      print(
        '[PAYMENT] subscription check: tier=${data['tier']}, status=${data['status']}',
      );
      return data;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Polls every 3s, up to 10 times. True when tier is premium and status is active.
  Future<bool> pollSubscription({
    required String email,
    String? jwt,
  }) async {
    for (var i = 1; i <= 10; i++) {
      print('[PAYMENT] poll attempt $i/10');
      final data = await checkSubscription(email: email, jwt: jwt);
      if (data != null &&
          data['tier'] == 'premium' &&
          data['status'] == 'active') {
        return true;
      }
      if (i < 10) {
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
    return false;
  }

  Map<String, dynamic>? _coerceMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Map<String, dynamic> _unwrapData(Map<String, dynamic> map) {
    final nested = map['data'];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return map;
  }

  ApiException _mapDioException(DioException e) {
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        return ApiException.fromApiError(ApiError.fromJson(error));
      }
      final message = responseData['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return ApiException(code: 'REQUEST_FAILED', message: message);
      }
    } else if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      final error = map['error'];
      if (error is Map) {
        return ApiException.fromApiError(
          ApiError.fromJson(Map<String, dynamic>.from(error)),
        );
      }
    }

    final statusCode = e.response?.statusCode;
    return ApiException(
      code: statusCode != null ? 'HTTP_$statusCode' : 'NETWORK_ERROR',
      message: e.message ?? 'Network request failed',
    );
  }
}
