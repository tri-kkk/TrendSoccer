import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:trendsoccer/core/services/analytics_service.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

class TokenService {
  TokenService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _authTokenKey = 'auth_token';

  /// Prevents repeated deleteAll() when every interceptor read fails at startup.
  static bool _decryptHealAttemptedThisSession = false;

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String jwt) async {
    try {
      await _storage.write(key: _authTokenKey, value: jwt);
    } catch (e) {
      _logStorageError('write');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      await _handleReadError(e);
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
    } catch (e) {
      _logStorageError('delete');
    }
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _handleReadError(Object error) async {
    _logStorageError('read');

    if (_isDecryptCorruptionError(error) && !_decryptHealAttemptedThisSession) {
      _decryptHealAttemptedThisSession = true;
      try {
        await _storage.deleteAll();
      } catch (e) {
        _logStorageError('delete', where: 'TokenService.heal');
      }
    }
  }

  bool _isDecryptCorruptionError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('badpadding') ||
        message.contains('bad_decrypt') ||
        message.contains('bad decrypt') ||
        message.contains('cipher')) {
      return true;
    }
    if (error is PlatformException) {
      final details = '${error.message} ${error.details}'.toLowerCase();
      return details.contains('badpadding') ||
          details.contains('bad_decrypt') ||
          details.contains('cipher');
    }
    return false;
  }

  void _logStorageError(String operation, {String where = 'TokenService'}) {
    unawaited(
      AnalyticsService.logSecureStorageError(
        operation: operation,
        where: where,
      ),
    );
  }
}
