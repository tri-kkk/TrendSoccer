import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:trendsoccer/core/models/auth_state.dart';

final authProvider = ChangeNotifierProvider<MockAuthProvider>(
  (ref) => MockAuthProvider(),
);

class MockAuthProvider extends ChangeNotifier {
  AuthState _state = const AuthState();

  AuthState get state => _state;

  bool get isLoggedIn => _state.isLoggedIn;

  bool get isPremium => _state.isPremium;

  bool get isTrial => _state.isTrial;

  bool get hasFullAccess =>
      _state.planType == PlanType.premium || _state.planType == PlanType.trial;

  PlanType get planType => _state.planType;

  String get userName => _state.userName;

  String get userEmail => _state.userEmail;

  void loginWithGoogle() {
    _state = AuthState(
      status: AuthStatus.loggedIn,
      loginMethod: LoginMethod.google,
      planType: PlanType.premium,
      userName: 'TrendSoccer',
      userEmail: 'trendsoccer@gmail.com',
      premiumExpiresAt: DateTime.now().add(const Duration(days: 30)),
    );
    notifyListeners();
  }

  void loginWithNaver() {}

  void completeSignup() {
    _state = AuthState(
      status: AuthStatus.loggedIn,
      loginMethod: LoginMethod.naver,
      planType: PlanType.trial,
      userName: '트렌드사커',
      userEmail: 'naver@trendsoccer.com',
      trialExpiresAt: DateTime.now().add(const Duration(hours: 48)),
    );
    notifyListeners();
  }

  void subscribePremium({required int months}) {
    _state = _state.copyWith(
      planType: PlanType.premium,
      premiumExpiresAt: DateTime.now().add(Duration(days: months * 30)),
      clearTrialExpiresAt: true,
    );
    notifyListeners();
  }

  void signOut() {
    _state = const AuthState();
    notifyListeners();
  }

  void deleteAccount() {
    _state = const AuthState();
    notifyListeners();
  }
}
