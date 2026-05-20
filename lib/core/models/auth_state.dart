enum AuthStatus { guest, loggedIn }

enum LoginMethod { none, google, naver }

enum PlanType { none, free, trial, premium }

DateTime? _parseJsonDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

class SubscriptionInfo {
  const SubscriptionInfo({
    required this.isActive,
    this.plan,
    this.startDate,
    this.expiresAt,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      isActive: json['isActive'] as bool? ?? false,
      plan: json['plan'] as String?,
      startDate: _parseJsonDateTime(json['startDate']),
      expiresAt: _parseJsonDateTime(json['expiresAt']),
    );
  }

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

  factory TrialInfo.fromJson(Map<String, dynamic> json) {
    return TrialInfo(
      used: json['used'] as bool? ?? false,
      expiresAt: _parseJsonDateTime(json['expiresAt']),
    );
  }

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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawSubscription = json['subscription'];
    final rawTrial = json['trial'];

    return UserProfile(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      tier: json['tier'] as String? ?? 'free',
      subscription: rawSubscription is Map<String, dynamic>
          ? SubscriptionInfo.fromJson(rawSubscription)
          : null,
      trial: rawTrial is Map<String, dynamic>
          ? TrialInfo.fromJson(rawTrial)
          : null,
    );
  }

  final String userId;
  final String email;
  final String name;
  final String? avatarUrl;
  final String tier;
  final SubscriptionInfo? subscription;
  final TrialInfo? trial;

  static PlanType planTypeFromTier(String tier) {
    return switch (tier.toLowerCase()) {
      'guest' => PlanType.none,
      'free' => PlanType.free,
      'trial' => PlanType.trial,
      'premium' => PlanType.premium,
      _ => PlanType.free,
    };
  }
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
