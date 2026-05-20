import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService();
});

class TokenService {
  TokenService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _authTokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String jwt) async {
    await _storage.write(key: _authTokenKey, value: jwt);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _authTokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
