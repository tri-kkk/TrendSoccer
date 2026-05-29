import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class AppConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;

  static String get apiBaseUrl => dotenv.env['API_BASE_URL']!;

  static String get webApiBaseUrl => dotenv.env['WEB_API_BASE_URL']!;

  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID']!;

  static String get naverClientId => dotenv.env['NAVER_CLIENT_ID'] ?? '';

  static String get naverClientSecret => dotenv.env['NAVER_CLIENT_SECRET'] ?? '';

  static String get naverClientName =>
      dotenv.env['NAVER_CLIENT_NAME'] ?? 'TrendSoccer';

  static SupabaseClient get supabaseClient => Supabase.instance.client;

  static Dio? _dio;
  static Dio? _webDio;

  static Dio get dio {
    return _dio ??= Dio(
      BaseOptions(baseUrl: apiBaseUrl),
    );
  }

  static Dio get webDio {
    return _webDio ??= Dio(
      BaseOptions(
        baseUrl: webApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
      ),
    );
  }
}
