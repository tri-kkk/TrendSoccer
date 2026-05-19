enum AuthStatus { guest, loggedIn }

enum LoginMethod { none, google, naver }

enum PlanType { none, free, trial, premium }

class AuthState {
  const AuthState({
    this.status = AuthStatus.guest,
    this.loginMethod = LoginMethod.none,
    this.planType = PlanType.none,
    this.userName = '',
    this.userEmail = '',
    this.trialExpiresAt,
    this.premiumExpiresAt,
  });

  final AuthStatus status;
  final LoginMethod loginMethod;
  final PlanType planType;
  final String userName;
  final String userEmail;
  final DateTime? trialExpiresAt;
  final DateTime? premiumExpiresAt;

  bool get isLoggedIn => status == AuthStatus.loggedIn;

  bool get isPremium => planType == PlanType.premium;

  bool get isTrial => planType == PlanType.trial;

  bool get isFreeOrGuest => planType == PlanType.free || planType == PlanType.none;

  AuthState copyWith({
    AuthStatus? status,
    LoginMethod? loginMethod,
    PlanType? planType,
    String? userName,
    String? userEmail,
    DateTime? trialExpiresAt,
    DateTime? premiumExpiresAt,
    bool clearTrialExpiresAt = false,
    bool clearPremiumExpiresAt = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      loginMethod: loginMethod ?? this.loginMethod,
      planType: planType ?? this.planType,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      trialExpiresAt:
          clearTrialExpiresAt ? null : (trialExpiresAt ?? this.trialExpiresAt),
      premiumExpiresAt: clearPremiumExpiresAt
          ? null
          : (premiumExpiresAt ?? this.premiumExpiresAt),
    );
  }
}
