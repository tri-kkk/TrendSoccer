import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/services/api_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiServiceProvider));
});

class AuthService {
  AuthService(this._api);

  final ApiService _api;

  // TODO: Set useNaverStub = false when backend endpoint is live
  static const bool useNaverStub = true;

  static const _mePath = '/api/v1/mobile/me';
  static const _withdrawPath = '/api/v1/mobile/me/withdraw';
  static const _subscriptionByEmailPath = '/api/subscription';
  static const _googleAuthPath = '/api/v1/mobile/auth/google';
  static const _naverAuthPath = '/api/v1/mobile/auth/naver';
  static const _agreeTermsPath = '/api/auth/agree-terms';

  static const _deviceInfo = <String, String>{
    'platform': 'android',
    'appVersion': '1.0.0',
  };

  Future<UserProfile> fetchProfile() async {
    return _api.get<UserProfile>(
      _mePath,
      fromJson: (json) =>
          UserProfile.fromJson(json! as Map<String, dynamic>),
    );
  }

  /// Payment polling (v3 section 4-7).
  Future<Map<String, dynamic>> fetchSubscriptionByEmail(String email) async {
    return _api.get<Map<String, dynamic>>(
      _subscriptionByEmailPath,
      queryParameters: <String, String>{'email': email},
      fromJson: (json) {
        final map = json! as Map<String, dynamic>;
        return <String, dynamic>{
          'status': map['status'],
          'expires_at': map['expires_at'] ?? map['expiresAt'],
        };
      },
    );
  }

  Future<LoginResponse> googleAuth(String accessToken) async {
    print(
      '[AUTH] Request body token field: accessToken (OAuth), value length: ${accessToken.length}',
    );
    return _api.post<LoginResponse>(
      _googleAuthPath,
      data: <String, dynamic>{
        'accessToken': accessToken,
        'deviceInfo': _deviceInfo,
      },
      fromJson: (json) =>
          LoginResponse.fromJson(json! as Map<String, dynamic>),
    );
  }

  Future<LoginResponse> naverAuth(String accessToken) async {
    if (useNaverStub) {
      return _naverAuthStubResponse();
    }

    return _api.post<LoginResponse>(
      _naverAuthPath,
      data: <String, dynamic>{
        'accessToken': accessToken,
        'deviceInfo': _deviceInfo,
      },
      fromJson: (json) =>
          LoginResponse.fromJson(json! as Map<String, dynamic>),
    );
  }

  LoginResponse _naverAuthStubResponse() {
    final expiresAt =
        DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String();

    return LoginResponse.fromJson(<String, dynamic>{
      'session': <String, dynamic>{
        'accessToken': 'stub-jwt',
        'tokenType': 'Bearer',
        'expiresAt': expiresAt,
      },
      'user': <String, dynamic>{
        'userId': 'stub-uuid',
        'email': 'user@naver.com',
        'name': '네이버 사용자',
        'avatarUrl': null,
        'tier': 'free',
        'premiumExpiresAt': null,
        'isNewUser': true,
        'requiresConsent': true,
      },
    });
  }

  Future<void> withdraw() async {
    await _api.post<Object?>(
      _withdrawPath,
      fromJson: (json) => json,
    );
  }

  Future<void> agreeTerms({
    required String email,
    required bool termsAgreed,
    required bool privacyAgreed,
    required bool marketingAgreed,
  }) async {
    await _api.post<Object?>(
      _agreeTermsPath,
      data: <String, dynamic>{
        'email': email,
        'termsAgreed': termsAgreed,
        'privacyAgreed': privacyAgreed,
        'marketingAgreed': marketingAgreed,
      },
      fromJson: (json) => json,
    );
  }
}
