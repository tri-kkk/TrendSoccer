import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/services/api_client.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(apiClientProvider));
});

class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    return _parseResponse<T>(response.data, fromJson);
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return _parseResponse<T>(response.data, fromJson);
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.put<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return _parseResponse<T>(response.data, fromJson);
  }

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? fromJson,
  }) async {
    final response = await _dio.delete<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return _parseResponse<T>(response.data, fromJson);
  }

  T _parseResponse<T>(dynamic responseData, T Function(Object? json)? fromJson) {
    if (responseData is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid response format',
      );
    }

    final apiResponse = ApiResponse<T>.fromJson(responseData, fromJson);

    if (!apiResponse.success) {
      if (apiResponse.error != null) {
        throw ApiException.fromApiError(apiResponse.error!);
      }
      throw const ApiException(
        code: 'REQUEST_FAILED',
        message: 'Request failed',
      );
    }

    if (apiResponse.data == null) {
      throw const ApiException(
        code: 'NO_DATA',
        message: 'Response data is null',
      );
    }

    return apiResponse.data as T;
  }
}
