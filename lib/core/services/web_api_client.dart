import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/config/app_config.dart';
import 'package:trendsoccer/core/services/token_service.dart';

bool _webApiClientConfigured = false;

final webDioProvider = Provider<Dio>((ref) {
  final dio = AppConfig.webDio;
  final tokenService = ref.watch(tokenServiceProvider);
  _configureWebApiClient(dio, tokenService);
  return dio;
});

void _configureWebApiClient(Dio dio, TokenService tokenService) {
  if (_webApiClientConfigured) return;
  _webApiClientConfigured = true;

  dio.interceptors.addAll([
    _WebAuthInterceptor(tokenService),
_WebErrorLoggingInterceptor(),
  ]);
}

class _WebAuthInterceptor extends Interceptor {
  _WebAuthInterceptor(this._tokenService);

  final TokenService _tokenService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _tokenService.deleteToken();
    }
    handler.next(err);
  }
}

class _WebErrorLoggingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
