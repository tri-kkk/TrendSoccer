import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:trendsoccer/core/config/app_config.dart';
import 'package:trendsoccer/core/models/auth_state.dart';

final authProvider = ChangeNotifierProvider<SupabaseAuthProvider>(
  (ref) => SupabaseAuthProvider(),
);

class SupabaseAuthProvider extends ChangeNotifier {
  SupabaseAuthProvider() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          if (data.session != null) {
            _applySession(data.session!);
          }
        case AuthChangeEvent.initialSession:
          if (data.session != null) {
            _applySession(data.session!);
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

    return switch (profile.tier.toLowerCase()) {
      'premium' => PlanType.premium,
      'trial' => PlanType.trial,
      'free' => PlanType.free,
      _ => PlanType.free,
    };
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

  void loginWithNaver() {
    // TODO(step 1-4): Supabase OAuth — custom Naver provider
  }

  void completeSignup() {
    // TODO(step 1-4): signup flow; profile/tier will come from /me endpoint
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
