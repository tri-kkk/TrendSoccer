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
  static const _subscriptionPath = '/api/v1/mobile/me/subscription';
  static const _consentPath = '/api/v1/mobile/me/consent';
  static const _trialPath = '/api/v1/mobile/auth/trial';
  static const _naverAuthPath = '/api/v1/mobile/auth/naver';

  Future<UserProfile> fetchProfile() async {
    return _api.get<UserProfile>(
      _mePath,
      fromJson: (json) =>
          UserProfile.fromJson(json! as Map<String, dynamic>),
    );
  }

  Future<SubscriptionInfo?> fetchSubscription() async {
    return _api.get<SubscriptionInfo>(
      _subscriptionPath,
      fromJson: (json) =>
          SubscriptionInfo.fromJson(json! as Map<String, dynamic>),
    );
  }

  Future<void> saveConsent({
    required bool terms,
    required bool privacy,
    required bool marketing,
  }) async {
    await _api.post<Object?>(
      _consentPath,
      data: <String, bool>{
        'terms': terms,
        'privacy': privacy,
        'marketing': marketing,
      },
      fromJson: (json) => json,
    );
  }

  Future<TrialInfo> grantTrial() async {
    return _api.post<TrialInfo>(
      _trialPath,
      fromJson: (json) =>
          TrialInfo.fromJson(json! as Map<String, dynamic>),
    );
  }

  Future<Map<String, dynamic>> naverAuth(String accessToken) async {
    if (useNaverStub) {
      return _naverAuthStubResponse();
    }

    return _api.post<Map<String, dynamic>>(
      _naverAuthPath,
      data: <String, dynamic>{
        'accessToken': accessToken,
        'deviceInfo': <String, String>{
          'platform': 'android',
          'appVersion': '1.0.0',
        },
      },
      fromJson: (json) => json! as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> _naverAuthStubResponse() {
    final expiresAt = DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String();

    return <String, dynamic>{
      'session': <String, dynamic>{
        'accessToken': 'stub-jwt',
        'refreshToken': 'stub-refresh',
        'expiresAt': expiresAt,
      },
      'user': <String, dynamic>{
        'userId': 'stub-uuid',
        'email': 'user@naver.com',
        'name': '네이버 사용자',
        'avatarUrl': null,
        'isNewUser': true,
      },
    };
  }
}
