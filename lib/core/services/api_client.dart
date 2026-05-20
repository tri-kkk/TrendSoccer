import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/config/app_config.dart';

const _retriedKey = '_auth_retried';

bool _apiClientConfigured = false;

final apiClientProvider = Provider<Dio>((ref) {
  final dio = AppConfig.dio;
  _configureApiClient(dio);
  return dio;
});

void _configureApiClient(Dio dio) {
  if (_apiClientConfigured) return;
  _apiClientConfigured = true;

  dio.interceptors.addAll([
    _AuthInterceptor(dio),
    if (kDebugMode)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    _ErrorLoggingInterceptor(),
  ]);
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._dio);

  final Dio _dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = AppConfig.supabaseClient.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    try {
      final refreshResponse =
          await AppConfig.supabaseClient.auth.refreshSession();
      final newSession = refreshResponse.session;

      if (newSession == null) {
        await AppConfig.supabaseClient.auth.signOut();
        handler.next(err);
        return;
      }

      final requestOptions = err.requestOptions;
      requestOptions.extra[_retriedKey] = true;
      requestOptions.headers['Authorization'] =
          'Bearer ${newSession.accessToken}';

      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (_) {
      await AppConfig.supabaseClient.auth.signOut();
      handler.next(err);
    }
  }
}

class _ErrorLoggingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[ApiClient] ${err.requestOptions.method} ${err.requestOptions.uri} '
        'failed: ${err.message}',
      );
    }
    handler.next(err);
  }
}
