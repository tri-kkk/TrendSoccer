import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:trendsoccer/core/config/app_config.dart';
import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/services/auth_service.dart';
import 'package:trendsoccer/core/services/fcm_service.dart';
import 'package:trendsoccer/core/services/token_service.dart';

final authProvider = ChangeNotifierProvider<SupabaseAuthProvider>(
  (ref) => SupabaseAuthProvider(ref),
);

class SupabaseAuthProvider extends ChangeNotifier {
  SupabaseAuthProvider(this._ref);

  final Ref _ref;

  AuthState _state = const AuthState();
  UserProfile? userProfile;

  AuthState get state => _state;

  bool get isLoggedIn => _state.isLoggedIn;

  bool get isGuest => _state.status == AuthStatus.guest;

  AuthStatus get authStatus => _state.status;

  bool get isPremium => _state.isPremium;

  bool get isTrial => _state.isTrial;

  bool get hasFullAccess => _state.planType == PlanType.premium;

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

  PlanType _resolvePlanType({
    DateTime? premiumExpiresAt,
    String? tier,
  }) {
    if (!isLoggedIn) return PlanType.none;
    final effectiveTier = tier ?? userProfile?.tier;
    final expiresAt = premiumExpiresAt ?? _state.premiumExpiresAt;
    if (effectiveTier == 'premium') {
      return PlanType.premium;
    }
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

  void _resetToGuest() {
    _state = const AuthState();
    userProfile = null;
    notifyListeners();
  }

  void _syncStateFromUserProfile(UserProfile profile) {
    userProfile = profile;
    _state = _state.copyWith(
      userName: profile.name,
      userEmail: profile.email,
      planType: _resolvePlanType(
        premiumExpiresAt: profile.premiumExpiresAt,
        tier: profile.tier,
      ),
      premiumExpiresAt: profile.premiumExpiresAt,
      clearTrialExpiresAt: true,
    );
    notifyListeners();
  }

  Future<void> initFromStoredToken() async {
    final hasToken = await _ref.read(tokenServiceProvider).hasToken();
    if (!hasToken) {
      _resetToGuest();
      return;
    }

    _state = _state.copyWith(status: AuthStatus.loggedIn);
    notifyListeners();
    await loadProfile();

    if (!await _ref.read(tokenServiceProvider).hasToken()) {
      _resetToGuest();
      return;
    }

    try {
      await _ref.read(fcmServiceProvider).initialize();
    } catch (e) {
      debugPrint('[Auth] FCM initialize failed: $e');
    }
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _ref.read(authServiceProvider).fetchProfile();
      _syncStateFromUserProfile(profile);
    } on ApiException catch (e) {
      debugPrint('[Auth] loadProfile warning: $e');
    } on DioException catch (e) {
      debugPrint('[Auth] loadProfile network warning: $e');
    } catch (e) {
      debugPrint('[Auth] loadProfile warning: $e');
    }
  }

  Future<void> signOut() async {
    await _ref.read(tokenServiceProvider).deleteToken();
    _resetToGuest();
  }

  Future<void> withdraw() async {
    await _ref.read(authServiceProvider).withdraw();
    await _ref.read(tokenServiceProvider).deleteToken();
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
      } on ApiException catch (e) {
        throw _mapAuthException(e);
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

  Future<void> loginWithNaver() async {
    final result = await FlutterNaverLogin.logIn();
    switch (result.status) {
      case NaverLoginStatus.loggedOut:
        return;
      case NaverLoginStatus.error:
        throw Exception(
          (result.errorMessage?.isNotEmpty ?? false)
              ? result.errorMessage!
              : 'Naver sign-in failed',
        );
      case NaverLoginStatus.loggedIn:
        break;
    }

    final loginToken = result.accessToken;
    String naverAccessToken;
    if (loginToken != null && loginToken.accessToken.isNotEmpty) {
      naverAccessToken = loginToken.accessToken;
    } else {
      final currentToken = await FlutterNaverLogin.getCurrentAccessToken();
      if (currentToken.accessToken.isEmpty) {
        throw Exception('Naver sign-in failed: access token is missing');
      }
      naverAccessToken = currentToken.accessToken;
    }

    try {
      final response =
          await _ref.read(authServiceProvider).naverAuth(naverAccessToken);
      await _applyLoginResponse(response, LoginMethod.naver);
    } on ApiException catch (e) {
      throw _mapAuthException(e);
    }
  }

  Future<bool> completeSignup({
    required bool terms,
    required bool privacy,
    required bool marketing,
  }) async {
    try {
      await _ref.read(authServiceProvider).agreeTerms(
            email: userEmail,
            termsAgreed: terms,
            privacyAgreed: privacy,
            marketingAgreed: marketing,
          );
      await loadProfile();
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
    await withdraw();
  }
}
