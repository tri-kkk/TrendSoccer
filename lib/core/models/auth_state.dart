enum AuthStatus { guest, loggedIn }

enum LoginMethod { none, google, naver }

enum PlanType { none, free, trial, premium }

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.isActive,
    this.plan,
    this.startDate,
    this.expiresAt,
  });

  final bool isActive;
  final String? plan;
  final DateTime? startDate;
  final DateTime? expiresAt;
}

class TrialInfo {
  const TrialInfo({
    required this.used,
    this.expiresAt,
  });

  final bool used;
  final DateTime? expiresAt;
}

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.tier,
    this.subscription,
    this.trial,
  });

  final String userId;
  final String email;
  final String name;
  final String? avatarUrl;
  final String tier;
  final SubscriptionInfo? subscription;
  final TrialInfo? trial;
}

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
