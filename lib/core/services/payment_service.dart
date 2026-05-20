import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/models/payment_models.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref.watch(webDioProvider));
});

class PaymentService {
  PaymentService(this._dio);

  final Dio _dio;

  static const _initPaymentPath = '/api/payment/seedpay/init';
  static const _subscriptionPath = '/api/subscription';

  /// Starts SeedPay checkout; [plan] must be `monthly` or `quarterly`.
  Future<PaymentInitResponse> initPayment({
    required String plan,
    required String userId,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        _initPaymentPath,
        data: <String, String>{
          'plan': plan,
          'userId': userId,
        },
      );
      final map = _parseMap(response.data);
      if (map == null) {
        throw const ApiException(
          code: 'INVALID_RESPONSE',
          message: 'Invalid payment init response',
        );
      }
      return PaymentInitResponse.fromJson(map);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ApiException(
        code: 'PAYMENT_INIT_FAILED',
        message: 'Payment initialization failed',
        messageEn: e.toString(),
      );
    }
  }

  /// Polls subscription until active or [maxAttempts] exhausted.
  Future<SubscriptionStatus?> pollSubscription({
    required String email,
    int maxAttempts = 10,
    int intervalSeconds = 3,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(Duration(seconds: intervalSeconds));
      }

      try {
        final status = await checkSubscription(email: email);
        if (status != null && status.isActive) {
          return status;
        }
      } catch (_) {
        // Network errors during polling are ignored; try again.
      }
    }
    return null;
  }

  /// Single subscription lookup (no polling).
  Future<SubscriptionStatus?> checkSubscription({required String email}) async {
    try {
      final response = await _dio.get<dynamic>(
        _subscriptionPath,
        queryParameters: <String, String>{'email': email},
      );
      final map = _parseMap(response.data);
      if (map == null) return null;

      final status = SubscriptionStatus.fromJson(map);
      return status.isActive ? status : null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _parseMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
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
        return ApiException(
          code: 'REQUEST_FAILED',
          message: message,
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
