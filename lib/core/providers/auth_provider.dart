import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:trendsoccer/core/config/app_config.dart';
import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/api_client.dart';
import 'package:trendsoccer/core/services/auth_service.dart';
import 'package:trendsoccer/core/services/fcm_service.dart';
import 'package:trendsoccer/core/services/token_service.dart';

final authProvider = ChangeNotifierProvider<SupabaseAuthProvider>(
  (ref) => SupabaseAuthProvider(ref),
);

class _ProfileSubscriptionInfo {
  const _ProfileSubscriptionInfo({this.status, this.expiresAt});

  final String? status;
  final DateTime? expiresAt;

  static _ProfileSubscriptionInfo? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw);
    final expiresRaw = map['expiresAt'] ?? map['expires_at'];
    return _ProfileSubscriptionInfo(
      status: map['status'] as String?,
      expiresAt: expiresRaw is String && expiresRaw.isNotEmpty
          ? DateTime.tryParse(expiresRaw)
          : null,
    );
  }
}

class _ProfileTrialInfo {
  const _ProfileTrialInfo({this.endsAt, this.active = false});

  final DateTime? endsAt;
  final bool active;

  static _ProfileTrialInfo? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw);

    final endsAtRaw = map['endsAt'] ?? map['ends_at'];
    final expiresAtRaw = map['expiresAt'] ?? map['expires_at'];
    final endsAt = (endsAtRaw is String && endsAtRaw.isNotEmpty
            ? DateTime.tryParse(endsAtRaw)
            : null) ??
        (expiresAtRaw is String && expiresAtRaw.isNotEmpty
            ? DateTime.tryParse(expiresAtRaw)
            : null);
    final active = map['active'] == true;

    print(
      '[AUTH] Trial parse: active=$active, endsAt=$endsAt, '
      'expiresAt field=${map['expiresAt']}',
    );

    return _ProfileTrialInfo(endsAt: endsAt, active: active);
  }
}

class SupabaseAuthProvider extends ChangeNotifier {
  SupabaseAuthProvider(this._ref);

  final Ref _ref;

  static const _authJwtKey = 'auth_jwt';
  static const _authProviderKey = 'auth_provider';
  static const _authExpiresAtKey = 'auth_expires_at';
  static const _meUrl = 'https://www.trendsoccer.com/api/v1/mobile/me';

  AuthState _state = const AuthState();
  UserProfile? userProfile;
  _ProfileSubscriptionInfo? _subscription;
  _ProfileTrialInfo? _trial;

  AuthState get state => _state;

  bool get isLoggedIn => _state.isLoggedIn;

  bool get isGuest => _state.status == AuthStatus.guest;

  AuthStatus get authStatus => _state.status;

  bool get isPremium => _state.isPremium;

  bool get isTrial => _state.isTrial;

  bool get hasFullAccess {
    final result = _state.planType == PlanType.premium ||
        _state.planType == PlanType.trial;
    print(
      '[AUTH] hasFullAccess: planType=${_state.planType}, result=$result',
    );
    return result;
  }

  PlanType get planType => _state.planType;

  String get userName => _state.userName;

  String get userEmail => _state.userEmail;

  String? get avatarUrl => userProfile?.avatarUrl;

  LoginMethod get loginMethod => _state.loginMethod;

  DateTime? get trialExpiresAt => _state.trialExpiresAt;

  DateTime? get premiumExpiresAt => _state.premiumExpiresAt;

  bool get needsConsent {
    if (!isLoggedIn) return false;
    final profile = userProfile;
    if (profile == null) return true;
    if (profile.termsAgreedAt != null) return false;
    return profile.requiresConsent;
  }

  PlanType _planTypeFromProfile(UserProfile profile) {
    final tier = profile.tier;
    final hasActiveSubscription =
        _subscription != null && _subscription!.status == 'active';
    final active = _trial?.active ?? false;
    final trialEndsAt = _trial?.endsAt ?? profile.trialEndsAt;
    final isTrialActive = active ||
        (trialEndsAt != null && trialEndsAt.isAfter(DateTime.now()));

    final PlanType planType;
    if (tier == 'premium' && hasActiveSubscription) {
      planType = PlanType.premium;
    } else if (tier == 'premium' && !hasActiveSubscription && isTrialActive) {
      planType = PlanType.trial;
    } else {
      planType = PlanType.free;
    }

    print(
      '[AUTH] Tier mapping: apiTier=$tier, hasSubscription=$hasActiveSubscription, '
      'isTrialActive=$isTrialActive → planType=$planType',
    );
    return planType;
  }

  PlanType _resolvePlanType({
    DateTime? premiumExpiresAt,
    String? tier,
  }) {
    if (!isLoggedIn) return PlanType.none;
    if (userProfile != null) {
      return _planTypeFromProfile(userProfile!);
    }
    final effectiveTier = tier;
    if (effectiveTier == 'free') {
      return PlanType.free;
    }
    final expiresAt = premiumExpiresAt ?? _state.premiumExpiresAt;
    if (expiresAt != null && expiresAt.isAfter(DateTime.now())) {
      return PlanType.premium;
    }
    return PlanType.free;
  }

  UserProfile _userProfileFromLoginUser(LoginUser user) {
    return UserProfile(
      userId: user.userId,
      email: user.email,
      name: user.name,
      avatarUrl: user.avatarUrl,
      tier: user.tier,
      premiumExpiresAt: user.premiumExpiresAt,
      isNewUser: user.isNewUser,
      requiresConsent: user.requiresConsent,
    );
  }

  Future<void> _applyLoginResponse(
    LoginResponse response,
    LoginMethod loginMethod,
  ) async {
    await _ref.read(tokenServiceProvider).saveToken(response.session.accessToken);

    final user = response.user;
    userProfile = _userProfileFromLoginUser(user);
    _state = AuthState(
      status: AuthStatus.loggedIn,
      loginMethod: loginMethod,
      planType: _resolvePlanType(
        premiumExpiresAt: user.premiumExpiresAt,
        tier: user.tier,
      ),
      userName: user.name,
      userEmail: user.email,
      premiumExpiresAt: user.premiumExpiresAt,
    );
    notifyListeners();

    try {
      await _ref.read(fcmServiceProvider).initialize();
    } catch (e) {
      debugPrint('[Auth] FCM initialize failed: $e');
    }
  }

  Future<void> _persistNaverAuthSession(String jwt) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(_authJwtKey, jwt);
    await prefs.setString(_authProviderKey, 'naver');
  }

  ApiException _mapAuthException(ApiException e) {
    if (e.code == 'COOLDOWN_ACTIVE') {
      final daysLeft = _daysLeftFromMessage(e.message);
      final message = daysLeft != null
          ? '탈퇴 후 재가입 대기 중입니다. ($daysLeft일 남음)'
          : '탈퇴 후 재가입 대기 중입니다.';
      return ApiException(code: e.code, message: message, messageEn: e.messageEn);
    }
    if (e.code == 'ACCOUNT_DELETED') {
      return ApiException(
        code: e.code,
        message: '탈퇴한 계정입니다. 다른 계정으로 로그인해주세요.',
        messageEn: e.messageEn,
      );
    }
    return e;
  }

  int? _daysLeftFromMessage(String message) {
    final match = RegExp(r'(\d+)').firstMatch(message);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  Never _handleMobileAuthDioException(DioException e, {required String logLabel}) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    if (statusCode == 403 && responseData is Map) {
      final map = responseData is Map<String, dynamic>
          ? responseData
          : Map<String, dynamic>.from(responseData);
      final error = map['error'];
      if (error is Map) {
        final errorMap =
            error is Map<String, dynamic> ? error : Map<String, dynamic>.from(error);
        final errorCode = errorMap['code'] ?? '';
        final message = errorMap['message'] ?? '';
        final daysLeft = errorMap['daysLeft'];

        print(
          '[AUTH] $logLabel login blocked: code=$errorCode, daysLeft=$daysLeft',
        );

        if (errorCode == 'COOLDOWN_ACTIVE') {
          throw Exception(
            message is String && message.isNotEmpty
                ? message
                : '재가입은 탈퇴 후 7일이 지난 뒤 가능합니다.',
          );
        }
      }
    }

    if (statusCode == 401) {
      throw Exception('네이버 인증이 만료되었습니다. 다시 시도해주세요.');
    }

    if (statusCode == 400) {
      throw Exception('이메일 정보가 필요합니다. 네이버 계정 설정을 확인해주세요.');
    }

    print('[AUTH] $logLabel login DioException: ${e.message}');
    throw Exception(
      logLabel == 'Google'
          ? '로그인에 실패했습니다. 다시 시도해주세요.'
          : '네이버 로그인에 실패했습니다. 다시 시도해주세요.',
    );
  }

  void _resetToGuest() {
    _state = const AuthState();
    userProfile = null;
    _subscription = null;
    _trial = null;
    notifyListeners();
  }

  Map<String, dynamic>? _coerceUserMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Map<String, dynamic>? _extractMeUser(Map<String, dynamic>? response) {
    if (response == null) {
      return null;
    }

    final data = response['data'];
    if (data is Map) {
      final nestedUser = _coerceUserMap(data['user']);
      if (nestedUser != null) {
        return nestedUser;
      }
      final dataMap = _coerceUserMap(data);
      if (dataMap != null && dataMap.containsKey('tier')) {
        return dataMap;
      }
    }

    final directUser = _coerceUserMap(response['user']);
    if (directUser != null) {
      return directUser;
    }

    if (response.containsKey('tier')) {
      return response;
    }

    return null;
  }

  void _applyMeUserJson(Map<String, dynamic> user) {
    _subscription = _ProfileSubscriptionInfo.fromJson(user['subscription']);
    _trial = _ProfileTrialInfo.fromJson(user['trial']);
    print(
      '[AUTH] loadProfile: tier=${user['tier']}, '
      'trial=${user['trial']}, subscription=${user['subscription']}',
    );
    _syncStateFromUserProfile(UserProfile.fromJson(user));
  }

  void _applyPostSignupPlanFromAgreeTerms(bool isTrial) {
    final agreedAt = DateTime.now();
    final existing = userProfile;

    if (isTrial) {
      final trialEnds = agreedAt.add(const Duration(hours: 48));
      _trial = _ProfileTrialInfo(endsAt: trialEnds, active: true);
      _subscription = null;
      userProfile = UserProfile(
        userId: existing?.userId ?? '',
        email: existing?.email ?? _state.userEmail,
        name: existing?.name ?? _state.userName,
        avatarUrl: existing?.avatarUrl,
        tier: 'premium',
        premiumExpiresAt: existing?.premiumExpiresAt,
        trialEndsAt: trialEnds,
        isNewUser: existing?.isNewUser ?? false,
        requiresConsent: false,
        trialUsed: true,
        termsAgreedAt: agreedAt,
      );
      _state = _state.copyWith(
        planType: PlanType.trial,
        trialExpiresAt: trialEnds,
        clearPremiumExpiresAt: true,
      );
      print(
        '[AUTH] Post-signup tier from agreeTerms: trial until $trialEnds',
      );
    } else {
      _trial = null;
      _subscription = null;
      userProfile = UserProfile(
        userId: existing?.userId ?? '',
        email: existing?.email ?? _state.userEmail,
        name: existing?.name ?? _state.userName,
        avatarUrl: existing?.avatarUrl,
        tier: 'free',
        premiumExpiresAt: existing?.premiumExpiresAt,
        trialEndsAt: existing?.trialEndsAt,
        isNewUser: existing?.isNewUser ?? false,
        requiresConsent: false,
        trialUsed: existing?.trialUsed ?? false,
        termsAgreedAt: agreedAt,
      );
      _state = _state.copyWith(
        planType: PlanType.free,
        clearTrialExpiresAt: true,
        clearPremiumExpiresAt: true,
      );
      print('[AUTH] Post-signup tier from agreeTerms: free');
    }
    notifyListeners();
  }

  void _schedulePostSignupProfileRefresh(String? jwt) {
    print('[AUTH] Post-signup loadProfile delayed 1s (background)');
    unawaited(_refreshProfileAfterSignup(jwt));
  }

  Future<void> _refreshProfileAfterSignup(String? jwt) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    try {
      await loadProfile(jwt: jwt);
    } catch (e) {
      debugPrint('[Auth] Post-signup loadProfile failed (non-critical): $e');
    }
  }

  void _syncStateFromUserProfile(UserProfile profile) {
    userProfile = profile;
    final planType = _planTypeFromProfile(profile);
    final trialEndsAt = _trial?.endsAt ?? profile.trialEndsAt;
    _state = _state.copyWith(
      userName: profile.name,
      userEmail: profile.email,
      planType: planType,
      trialExpiresAt: planType == PlanType.trial ? trialEndsAt : null,
      premiumExpiresAt: planType == PlanType.premium
          ? (_subscription?.expiresAt ?? profile.premiumExpiresAt)
          : null,
      clearTrialExpiresAt: planType != PlanType.trial,
      clearPremiumExpiresAt: planType != PlanType.premium,
    );
    notifyListeners();
  }

  void _markConsentRequired() {
    final existing = userProfile;
    userProfile = UserProfile(
      userId: existing?.userId ?? '',
      email: existing?.email ?? _state.userEmail,
      name: existing?.name ?? _state.userName,
      avatarUrl: existing?.avatarUrl,
      tier: existing?.tier ?? 'free',
      premiumExpiresAt: existing?.premiumExpiresAt,
      trialEndsAt: existing?.trialEndsAt,
      isNewUser: existing?.isNewUser ?? false,
      requiresConsent: true,
      trialUsed: existing?.trialUsed ?? false,
      termsAgreedAt: existing?.termsAgreedAt,
    );
    notifyListeners();
  }

  bool _responseIndicatesConsentRequired(Object? data) {
    if (data is! Map) return false;
    final map = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data);
    if (map['code'] == 'CONSENT_REQUIRED') return true;
    final error = map['error'];
    if (error is Map && error['code'] == 'CONSENT_REQUIRED') {
      return true;
    }
    return false;
  }

  Future<void> _clearNaverAuthPrefs(SharedPreferences prefs) async {
    await prefs.remove(_authJwtKey);
    await prefs.remove(_authProviderKey);
    await prefs.remove(_authExpiresAtKey);
  }

  Future<void> initFromStoredToken() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    final storedJwt = prefs.getString(_authJwtKey);
    final provider = prefs.getString(_authProviderKey);

    if (storedJwt != null && storedJwt.isNotEmpty) {
      await _ref.read(tokenServiceProvider).saveToken(storedJwt);
    }

    final hasToken = await _ref.read(tokenServiceProvider).hasToken();
    if (!hasToken) {
      _resetToGuest();
      return;
    }

    _state = _state.copyWith(
      status: AuthStatus.loggedIn,
      loginMethod:
          provider == 'naver' ? LoginMethod.naver : LoginMethod.google,
    );
    notifyListeners();
    await loadProfile();

    if (!await _ref.read(tokenServiceProvider).hasToken()) {
      await _clearNaverAuthPrefs(prefs);
      _resetToGuest();
      return;
    }

    try {
      await _ref.read(fcmServiceProvider).initialize();
    } catch (e) {
      debugPrint('[Auth] FCM initialize failed: $e');
    }
  }

  Future<Map<String, String>> _buildMeRequestHeaders({String? jwt}) async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (jwt != null && jwt.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwt';
    } else {
      final prefs = _ref.read(sharedPreferencesProvider);
      final storedJwt = prefs.getString(_authJwtKey);
      if (storedJwt != null && storedJwt.isNotEmpty) {
        headers['Authorization'] = 'Bearer $storedJwt';
      } else {
        final token = await _ref.read(tokenServiceProvider).getToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        } else {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
        }
      }
    }

    return headers;
  }

  Future<void> loadProfile({String? jwt}) async {
    const url = _meUrl;
    print('[AUTH] loadProfile URL: $url');
    try {
      final headers = await _buildMeRequestHeaders(jwt: jwt);
      print(
        '[AUTH] loadProfile: auth header present=${headers.containsKey('Authorization')}',
      );

      final dio = Dio();
      final response = await dio.get<dynamic>(
        url,
        options: Options(headers: headers),
      );
      final raw = response.data;

      print('[AUTH] loadProfile: raw response type=${raw.runtimeType}');
      final rawString = raw.toString();
      print(
        '[AUTH] loadProfile: raw response=${rawString.substring(0, math.min(500, rawString.length))}',
      );

      Map<String, dynamic>? responseData;
      if (raw is Map<String, dynamic>) {
        responseData = raw;
      } else if (raw is Map) {
        responseData = Map<String, dynamic>.from(raw);
      }

      print(
        '[AUTH] loadProfile: has data key=${responseData?.containsKey('data')}, '
        'has user key=${responseData?.containsKey('user')}',
      );
      print('[AUTH] loadProfile: data content=${responseData?['data']}');
      print('[AUTH] loadProfile: data type=${responseData?['data']?.runtimeType}');
      print(
        '[AUTH] loadProfile: data keys=${responseData?['data'] is Map ? (responseData!['data'] as Map).keys : 'not a map'}',
      );

      if (responseData?['data'] is Map) {
        final data = responseData!['data'] is Map<String, dynamic>
            ? responseData['data'] as Map<String, dynamic>
            : Map<String, dynamic>.from(responseData['data'] as Map);
        print('[AUTH] loadProfile: data keys=${data.keys}');
        print('[AUTH] loadProfile: data.user type=${data['user']?.runtimeType}');
      }

      if (responseData != null &&
          responseData.containsKey('success') &&
          responseData['success'] != true) {
        final error = responseData['error'];
        if (error is Map<String, dynamic>) {
          final apiError = ApiError.fromJson(error);
          if (apiError.code == 'CONSENT_REQUIRED') {
            print('[AUTH] loadProfile: CONSENT_REQUIRED');
            _markConsentRequired();
            return;
          }
          throw ApiException.fromApiError(apiError);
        }
        throw const ApiException(
          code: 'REQUEST_FAILED',
          message: 'Request failed',
        );
      }

      final user = _extractMeUser(responseData);
      if (user == null) {
        print(
          '[AUTH] loadProfile: could not find user in response. '
          'Keys: ${responseData != null ? responseData.keys : 'not a map'}',
        );
        return;
      }

      print(
        '[AUTH] loadProfile: user found, tier=${user['tier']}, email=${user['email']}',
      );
      print(
        '[AUTH] Tier mapping: apiTier=${user['tier']}, '
        'subscription=${user['subscription']}, trial=${user['trial']}',
      );

      _applyMeUserJson(user);
    } on ApiException catch (e) {
      if (e.code == 'CONSENT_REQUIRED') {
        print('[AUTH] loadProfile: CONSENT_REQUIRED');
        _markConsentRequired();
        return;
      }
      debugPrint('[Auth] loadProfile warning: $e');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        print('[AUTH] loadProfile: 401 token expired, signing out');
        await signOut();
        return;
      }
      if (statusCode == 409 || _responseIndicatesConsentRequired(e.response?.data)) {
        print('[AUTH] loadProfile: CONSENT_REQUIRED (409)');
        _markConsentRequired();
        return;
      }
      debugPrint('[Auth] loadProfile network warning: $e');
    } catch (e) {
      debugPrint('[Auth] loadProfile warning: $e');
    }
  }

  Future<void> signOut() async {
    final loginMethod = _state.loginMethod;
    try {
      final dio = Dio();
      String? csrfToken;
      try {
        final csrfResponse =
            await dio.get('https://www.trendsoccer.com/api/auth/csrf');
        final data = csrfResponse.data;
        if (data is Map<String, dynamic>) {
          csrfToken = data['csrfToken'] as String?;
        } else if (data is Map) {
          csrfToken = data['csrfToken']?.toString();
        }
        print('[AUTH] CSRF token obtained');
      } catch (e) {
        print('[AUTH] CSRF fetch failed (non-critical): $e');
      }

      if (csrfToken != null) {
        try {
          await dio.post(
            'https://www.trendsoccer.com/api/auth/signout',
            data: {'csrfToken': csrfToken},
          );
          print('[AUTH] Backend signout success');
        } catch (e) {
          print('[AUTH] Backend signout failed (non-critical): $e');
        }
      }

      await _clearLocalAuth(loginMethod);
      print('[AUTH] Logout complete: state reset to guest');
    } catch (e) {
      print('[AUTH] Logout error: $e');
      _resetToGuest();
    }
  }

  Future<void> withdraw() async {
    await _ref.read(authServiceProvider).withdraw();
    await _clearLocalAuth(_state.loginMethod);
  }

  Future<void> _clearLocalAuth(LoginMethod loginMethod) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await _clearNaverAuthPrefs(prefs);
    await _ref.read(tokenServiceProvider).deleteToken();

    if (loginMethod == LoginMethod.google) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    } else if (loginMethod == LoginMethod.naver) {
      try {
        await FlutterNaverLogin.logOut();
      } catch (_) {}
    }

    _resetToGuest();
  }

  Future<void> loginWithGoogle() async {
    try {
      print('[AUTH] Step 1: Starting Google Sign-In');
      final googleSignIn = GoogleSignIn(
        serverClientId: AppConfig.googleWebClientId,
      );
      final account = await googleSignIn.signIn();
      if (account == null) return;

      print('[AUTH] Step 2: Got account: ${account.email}');
      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      final accessToken = authentication.accessToken;
      print(
        '[AUTH] Step 3: idToken=${idToken != null}, accessToken=${accessToken != null}, accessToken length: ${accessToken?.length}',
      );
      if (accessToken == null) {
        throw Exception('Google sign-in failed: accessToken is null');
      }

      print('[AUTH] Step 4: Calling /api/v1/mobile/auth/google');
      try {
        final response =
            await _ref.read(authServiceProvider).googleAuth(accessToken);
        print(
          '[AUTH] Step 5: Login response received, isNewUser=${response.user.isNewUser}',
        );
        await _applyLoginResponse(response, LoginMethod.google);
        final session = Supabase.instance.client.auth.currentSession;
        await loadProfile(
          jwt: session?.accessToken ?? response.session.accessToken,
        );
      } on ApiException catch (e) {
        throw _mapAuthException(e);
      } on DioException catch (e) {
        _handleMobileAuthDioException(e, logLabel: 'Google');
      }
    } catch (e) {
      print('[AUTH] ERROR: ${e.runtimeType}: $e');
      if (e is ApiException) {
        print('[AUTH] API Error code: ${e.code}, message: ${e.message}');
      }
      if (e is DioException) {
        print(
          '[AUTH] Dio Error: ${e.type}, statusCode: ${e.response?.statusCode}, data: ${e.response?.data}',
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithNaver() async {
    try {
      print('[AUTH] Naver login: calling FlutterNaverLogin.logIn()');
      final result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedOut) {
        print('[AUTH] Naver login cancelled by user');
        return {'cancelled': true};
      }

      if (result.status == NaverLoginStatus.error) {
        print('[AUTH] Naver SDK error: ${result.errorMessage}');
        throw Exception('Naver login failed: ${result.errorMessage}');
      }

      final loginToken = result.accessToken;
      final String naverAccessToken;
      if (loginToken != null && loginToken.accessToken.isNotEmpty) {
        naverAccessToken = loginToken.accessToken;
      } else {
        final tokenResult = await FlutterNaverLogin.getCurrentAccessToken();
        naverAccessToken = tokenResult.accessToken;
      }

      final previewLength =
          math.min(10, naverAccessToken.length);
      print(
        '[AUTH] Naver accessToken obtained: ${naverAccessToken.substring(0, previewLength)}...',
      );

      if (naverAccessToken.isEmpty) {
        throw Exception('Naver access token is empty');
      }

      print('[AUTH] Posting to /api/v1/mobile/auth/naver');
      try {
        final response =
            await _ref.read(authServiceProvider).naverAuth(naverAccessToken);
        print(
          '[AUTH] Backend response: isNewUser=${response.user.isNewUser}, tier=${response.user.tier}',
        );

        final jwt = response.session.accessToken;
        await _persistNaverAuthSession(jwt);
        await _applyLoginResponse(response, LoginMethod.naver);
        await loadProfile(jwt: jwt);

        final user = response.user;
        print(
          '[AUTH] Naver login success: email=${user.email}, tier=${user.tier}, isNewUser=${user.isNewUser}',
        );

        return {
          'isNewUser': user.isNewUser,
          'requiresConsent': needsConsent,
          'user': user,
        };
      } on ApiException catch (e) {
        throw _mapAuthException(e);
      } on DioException catch (e) {
        _handleMobileAuthDioException(e, logLabel: 'Naver');
      }
    } catch (e) {
      print('[AUTH] Naver login error: $e');
      if (e.toString().contains('cancelled')) {
        return {'cancelled': true};
      }
      rethrow;
    }
  }

  Future<bool> completeSignup({
    required bool terms,
    required bool privacy,
    required bool marketing,
  }) async {
    try {
      final result = await _ref.read(authServiceProvider).agreeTerms(
            email: userEmail,
            termsAgreed: terms,
            privacyAgreed: privacy,
            marketingAgreed: marketing,
          );
      if (!result.success) {
        return false;
      }

      _applyPostSignupPlanFromAgreeTerms(result.isTrial);

      final storedToken = await _ref.read(tokenServiceProvider).getToken();
      final prefs = _ref.read(sharedPreferencesProvider);
      final currentJwt = storedToken ?? prefs.getString(_authJwtKey);
      _schedulePostSignupProfileRefresh(currentJwt);

      return true;
    } on ApiException catch (e) {
      debugPrint('[Auth] agreeTerms failed: $e');
      return false;
    } on DioException catch (e) {
      debugPrint('[Auth] agreeTerms network error: $e');
      return false;
    } catch (e) {
      debugPrint('[Auth] agreeTerms failed: $e');
      return false;
    }
  }

  void subscribePremium({required int months}) {
    _state = _state.copyWith(
      planType: PlanType.premium,
      premiumExpiresAt: DateTime.now().add(Duration(days: months * 30)),
      clearTrialExpiresAt: true,
    );
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final email = userEmail;
    if (email.isEmpty) {
      throw Exception('이메일 정보가 없습니다.');
    }

    final loginMethod = _state.loginMethod;

    try {
      print('[AUTH] Deleting account: $email');

      final dio = _ref.read(apiClientProvider);
      final response = await dio.post<dynamic>(
        '/api/user/delete',
        data: <String, dynamic>{'email': email},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw Exception('회원 탈퇴에 실패했습니다.');
      }

      print('[AUTH] Delete account response: $raw');

      if (raw['success'] == true) {
        await _clearLocalAuth(loginMethod);
        print('[AUTH] Account deleted successfully');
        return;
      }

      if (raw['code'] == 'COOLDOWN_ACTIVE') {
        final daysLeft = raw['daysLeft'] ?? 7;
        print('[AUTH] Delete account cooldown: $daysLeft days left');
        throw Exception('탈퇴 후 $daysLeft일간 재가입이 불가합니다. 쿨다운 기간입니다.');
      }

      throw Exception(raw['message'] as String? ?? '회원 탈퇴에 실패했습니다.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      Map<String, dynamic>? dataMap;
      if (responseData is Map<String, dynamic>) {
        dataMap = responseData;
      } else if (responseData is Map) {
        dataMap = Map<String, dynamic>.from(responseData);
      }

      if (statusCode == 403 ||
          dataMap?['code'] == 'COOLDOWN_ACTIVE') {
        final daysLeft = dataMap?['daysLeft'] ?? 7;
        print('[AUTH] Delete account cooldown: $daysLeft days left');
        throw Exception('탈퇴 후 $daysLeft일간 재가입이 불가합니다. 쿨다운 기간입니다.');
      }
      if (statusCode == 404) {
        throw Exception('사용자를 찾을 수 없습니다.');
      }

      print('[AUTH] Delete account error: ${e.message}');
      throw Exception('회원 탈퇴에 실패했습니다. 다시 시도해주세요.');
    } catch (e) {
      print('[AUTH] Delete account error: $e');
      rethrow;
    }
  }
}
