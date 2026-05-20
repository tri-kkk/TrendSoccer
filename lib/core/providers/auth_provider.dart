import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:trendsoccer/core/config/app_config.dart';
import 'package:trendsoccer/core/models/api_response.dart';
import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/services/auth_service.dart';
import 'package:trendsoccer/core/services/fcm_service.dart';

final authProvider = ChangeNotifierProvider<SupabaseAuthProvider>(
  (ref) => SupabaseAuthProvider(ref),
);

class SupabaseAuthProvider extends ChangeNotifier {
  SupabaseAuthProvider(this._ref) {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          if (data.session != null) {
            _applySession(data.session!);
            unawaited(_afterSignedIn());
          }
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          if (data.session != null) {
            _applySession(data.session!);
          }
        case AuthChangeEvent.initialSession:
          if (data.session != null) {
            _applySession(data.session!);
            unawaited(loadProfile());
          } else {
            _resetToGuest();
          }
        case AuthChangeEvent.signedOut:
          _resetToGuest();
        case AuthChangeEvent.passwordRecovery:
        case AuthChangeEvent.mfaChallengeVerified:
          break;
        default:
          break;
      }
    });
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _applySession(session);
    }
  }

  final Ref _ref;

  AuthState _state = const AuthState();
  UserProfile? userProfile;

  StreamSubscription? _authSubscription;

  AuthState get state => _state;

  bool get isLoggedIn => _state.isLoggedIn;

  bool get isGuest => _state.status == AuthStatus.guest;

  AuthStatus get authStatus => _state.status;

  bool get isPremium => _state.isPremium;

  bool get isTrial => _state.isTrial;

  bool get hasFullAccess =>
      _state.planType == PlanType.premium || _state.planType == PlanType.trial;

  PlanType get planType => _state.planType;

  String get userName => _state.userName;

  String get userEmail => _state.userEmail;

  LoginMethod get loginMethod => _state.loginMethod;

  DateTime? get trialExpiresAt => _state.trialExpiresAt;

  DateTime? get premiumExpiresAt => _state.premiumExpiresAt;

  bool get needsConsent {
    if (!isLoggedIn) return false;
    final profile = userProfile;
    if (profile == null) return true;
    final consents = profile.consents;
    if (consents == null) return true;
    return !consents.isComplete;
  }

  void _applySession(Session session) {
    final user = session.user;
    final metadata = user.userMetadata ?? {};
    _state = AuthState(
      status: AuthStatus.loggedIn,
      loginMethod: _loginMethodFromUser(user),
      planType: PlanType.free,
      userName: _stringFromMetadata(metadata['full_name']) ?? '',
      userEmail: user.email ?? '',
    );
    notifyListeners();
  }

  void _resetToGuest() {
    _state = const AuthState();
    userProfile = null;
    notifyListeners();
  }

  String? _stringFromMetadata(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  LoginMethod _loginMethodFromUser(User user) {
    final provider = user.appMetadata['provider'] as String? ??
        (user.identities?.isNotEmpty == true
            ? user.identities!.first.provider
            : null);
    return switch (provider) {
      'google' => LoginMethod.google,
      'naver' => LoginMethod.naver,
      _ => LoginMethod.none,
    };
  }

  void updateFromProfile(UserProfile profile) {
    userProfile = profile;
    final resolvedPlanType = _planTypeFromProfile(profile);
    DateTime? trialExpiresAt;
    DateTime? premiumExpiresAt;
    var clearTrialExpiresAt = false;
    var clearPremiumExpiresAt = false;

    final trial = profile.trial;
    if (trial != null && !trial.used) {
      trialExpiresAt = trial.expiresAt;
    } else {
      clearTrialExpiresAt = true;
    }

    final subscription = profile.subscription;
    if (subscription?.isActive == true) {
      premiumExpiresAt = subscription!.expiresAt;
    } else {
      clearPremiumExpiresAt = true;
    }

    _state = _state.copyWith(
      userName: profile.name,
      userEmail: profile.email,
      planType: resolvedPlanType,
      trialExpiresAt: trialExpiresAt,
      premiumExpiresAt: premiumExpiresAt,
      clearTrialExpiresAt: clearTrialExpiresAt,
      clearPremiumExpiresAt: clearPremiumExpiresAt,
    );
    notifyListeners();
  }

  PlanType _planTypeFromProfile(UserProfile profile) {
    final subscription = profile.subscription;
    if (subscription?.isActive == true) {
      return PlanType.premium;
    }

    final trial = profile.trial;
    if (trial != null &&
        !trial.used &&
        trial.expiresAt != null &&
        trial.expiresAt!.isAfter(DateTime.now())) {
      return PlanType.trial;
    }

    return UserProfile.planTypeFromTier(profile.tier);
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _ref.read(authServiceProvider).fetchProfile();
      updateFromProfile(profile);
    } on ApiException catch (e) {
      debugPrint('[Auth] loadProfile failed: $e');
    } on DioException catch (e) {
      debugPrint('[Auth] loadProfile network error: $e');
    } catch (e) {
      debugPrint('[Auth] loadProfile failed: $e');
    }
  }

  Future<void> _afterSignedIn() async {
    await loadProfile();
    try {
      await _ref.read(fcmServiceProvider).initialize();
    } catch (e) {
      debugPrint('[Auth] FCM initialize failed: $e');
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    _resetToGuest();
  }

  Future<void> withdraw() async {
    // TODO(step 1-9): call membership withdraw API
  }

  Future<void> loginWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: AppConfig.googleWebClientId,
    );
    final account = await googleSignIn.signIn();
    if (account == null) return;

    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null) {
      throw Exception('Google sign-in failed: idToken is null');
    }

    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
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
      final data =
          await _ref.read(authServiceProvider).naverAuth(naverAccessToken);
      await _handleNaverAuthResponse(
        data,
        stubMode: AuthService.useNaverStub,
      );
    } on ApiException catch (e) {
      if (e.code == 'ACCOUNT_DELETED') {
        throw ApiException(
          code: e.code,
          message: '탈퇴한 계정입니다. 다른 계정으로 로그인해주세요.',
        );
      }
      if (e.code == 'CONSENT_REQUIRED') {
        _state = AuthState(
          status: AuthStatus.loggedIn,
          loginMethod: LoginMethod.naver,
          planType: PlanType.free,
          userName: result.account?.name ?? '',
          userEmail: result.account?.email ?? '',
        );
        userProfile = null;
        notifyListeners();
        return;
      }
      rethrow;
    }
  }

  Future<void> _handleNaverAuthResponse(
    Map<String, dynamic> data, {
    required bool stubMode,
  }) async {
    final user = data['user'];
    if (user is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Invalid Naver auth response',
      );
    }

    final session = data['session'];
    final sessionMap =
        session is Map<String, dynamic> ? session : null;

    await _applyNaverAuthState(
      user: user,
      stubMode: stubMode,
      session: sessionMap,
    );

    final isNewUser = user['isNewUser'] as bool? ?? false;
    if (isNewUser) {
      userProfile = null;
      notifyListeners();
      return;
    }

    userProfile = UserProfile(
      userId: user['userId'] as String? ?? '',
      email: user['email'] as String? ?? '',
      name: user['name'] as String? ?? '',
      avatarUrl: user['avatarUrl'] as String?,
      tier: 'free',
      consents: const UserConsents(
        terms: true,
        privacy: true,
        marketing: false,
      ),
    );
    notifyListeners();
    await loadProfile();
  }

  Future<void> _applyNaverAuthState({
    required Map<String, dynamic> user,
    required bool stubMode,
    required Map<String, dynamic>? session,
  }) async {
    if (stubMode) {
      _state = AuthState(
        status: AuthStatus.loggedIn,
        loginMethod: LoginMethod.naver,
        planType: PlanType.free,
        userName: user['name'] as String? ?? '',
        userEmail: user['email'] as String? ?? '',
      );
      notifyListeners();
      return;
    }

    final refreshToken = session?['refreshToken'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await Supabase.instance.client.auth.setSession(refreshToken);
    }
  }

  Future<bool> completeSignup({
    required bool terms,
    required bool privacy,
    required bool marketing,
  }) async {
    var hadError = false;

    try {
      await _ref.read(authServiceProvider).saveConsent(
            terms: terms,
            privacy: privacy,
            marketing: marketing,
          );
    } on ApiException catch (e) {
      hadError = true;
      debugPrint('[Auth] saveConsent failed: $e');
    } on DioException catch (e) {
      hadError = true;
      debugPrint('[Auth] saveConsent network error: $e');
    } catch (e) {
      hadError = true;
      debugPrint('[Auth] saveConsent failed: $e');
    }

    try {
      final trialInfo = await _ref.read(authServiceProvider).grantTrial();
      final expiresAt = trialInfo.expiresAt ??
          DateTime.now().add(const Duration(hours: 48));
      final consents = UserConsents(
        terms: terms,
        privacy: privacy,
        marketing: marketing,
      );

      if (userProfile != null) {
        final profile = userProfile!;
        userProfile = UserProfile(
          userId: profile.userId,
          email: profile.email,
          name: profile.name,
          avatarUrl: profile.avatarUrl,
          tier: 'trial',
          subscription: profile.subscription,
          trial: trialInfo,
          consents: consents,
        );
      }

      _state = _state.copyWith(
        planType: PlanType.trial,
        trialExpiresAt: expiresAt,
        clearPremiumExpiresAt: true,
      );
      notifyListeners();
    } on ApiException catch (e) {
      hadError = true;
      debugPrint('[Auth] grantTrial failed: $e');
    } on DioException catch (e) {
      hadError = true;
      debugPrint('[Auth] grantTrial network error: $e');
    } catch (e) {
      hadError = true;
      debugPrint('[Auth] grantTrial failed: $e');
    }

    await loadProfile();
    return !hadError;
  }

  void subscribePremium({required int months}) {
    _state = _state.copyWith(
      planType: PlanType.premium,
      premiumExpiresAt: DateTime.now().add(Duration(days: months * 30)),
      clearTrialExpiresAt: true,
    );
    notifyListeners();
  }

  void deleteAccount() {
    // TODO(step 1-9): call account deletion API
    _resetToGuest();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
