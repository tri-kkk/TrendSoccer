import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:trendsoccer/core/config/app_config.dart';
import 'package:trendsoccer/core/services/token_service.dart';

bool _apiClientConfigured = false;

final apiClientProvider = Provider<Dio>((ref) {
  final dio = AppConfig.dio;
  final tokenService = ref.watch(tokenServiceProvider);
  _configureApiClient(dio, tokenService);
  return dio;
});

void _configureApiClient(Dio dio, TokenService tokenService) {
  if (_apiClientConfigured) return;
  _apiClientConfigured = true;

  dio.interceptors.addAll([
    _AuthInterceptor(tokenService),
_ErrorLoggingInterceptor(),
  ]);
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenService);

  final TokenService _tokenService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final supabaseSession = Supabase.instance.client.auth.currentSession;
      if (supabaseSession != null) {
        options.headers['Authorization'] =
            'Bearer ${supabaseSession.accessToken}';
      } else {
        final token = await _tokenService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          final prefs = await SharedPreferences.getInstance();
          final storedJwt = prefs.getString('auth_jwt');
          if (storedJwt != null && storedJwt.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $storedJwt';
          }
        }
      }
    } finally {
      handler.next(options);
    }
  }
}

class _ErrorLoggingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
