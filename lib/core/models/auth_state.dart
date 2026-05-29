enum AuthStatus { guest, loggedIn }

enum LoginMethod { none, google, naver }

/// Client-side plan display state.
///
/// Server [UserProfile.tier] is only `'free'` | `'premium'`.
/// [none] — not authenticated (no JWT); client-side "guest" concept.
/// [premium] — active access: paid subscription or trial (server `tier` is
/// `'premium'` with [UserProfile.premiumExpiresAt] in the future; trial is
/// `premium` + `trial_used` on the server, not a separate tier).
/// [trial] — retained for UI that distinguishes trial vs paid premium.
enum PlanType {
  none,
  free,
  trial,
  premium,
}

DateTime? _parseJsonDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

bool _readJsonBool(Map<String, dynamic> json, String camel, String snake) {
  final value = json[camel] ?? json[snake];
  if (value is bool) return value;
  return false;
}

DateTime? _readJsonDateTime(
  Map<String, dynamic> json,
  String camel,
  String snake,
) {
  return _parseJsonDateTime(json[camel] ?? json[snake]);
}

String? _readJsonString(Map<String, dynamic> json, String camel, String snake) {
  final value = json[camel] ?? json[snake];
  if (value is String) return value;
  return null;
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.tokenType,
    this.expiresAt,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['accessToken'] as String? ?? '',
      tokenType: json['tokenType'] as String?,
      expiresAt: _parseJsonDateTime(json['expiresAt']),
    );
  }

  final String accessToken;
  final String? tokenType;
  final DateTime? expiresAt;
}

class LoginUser {
  const LoginUser({
    required this.userId,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.tier,
    this.premiumExpiresAt,
    this.isNewUser = false,
    this.requiresConsent = false,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      tier: json['tier'] as String? ?? 'free',
      premiumExpiresAt: _parseJsonDateTime(json['premiumExpiresAt']),
      isNewUser: json['isNewUser'] as bool? ?? false,
      requiresConsent: json['requiresConsent'] as bool? ?? false,
    );
  }

  final String userId;
  final String email;
  final String name;
  final String? avatarUrl;
  final String tier;
  final DateTime? premiumExpiresAt;
  final bool isNewUser;
  final bool requiresConsent;
}

class AgreeTermsResult {
  const AgreeTermsResult({
    required this.success,
    required this.isTrial,
    required this.message,
  });

  final bool success;
  final bool isTrial;
  final String message;
}

class LoginResponse {
  const LoginResponse({
    required this.session,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rawSession = json['session'];
    final rawUser = json['user'];

    return LoginResponse(
      session: rawSession is Map<String, dynamic>
          ? AuthSession.fromJson(rawSession)
          : AuthSession.fromJson(const {}),
      user: rawUser is Map<String, dynamic>
          ? LoginUser.fromJson(rawUser)
          : LoginUser.fromJson(const {}),
    );
  }

  final AuthSession session;
  final LoginUser user;
}

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.tier,
    this.premiumExpiresAt,
    this.trialEndsAt,
    this.isNewUser = false,
    this.requiresConsent = false,
    this.trialUsed = false,
    this.termsAgreedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final trial = json['trial'];
    DateTime? trialEndsAt;
    var trialUsed = _readJsonBool(json, 'trialUsed', 'trial_used');
    if (trial is Map<String, dynamic>) {
      trialEndsAt = _readJsonDateTime(trial, 'endsAt', 'ends_at');
      if (trial['used'] == true) {
        trialUsed = true;
      }
    } else if (trial is Map) {
      final trialMap = Map<String, dynamic>.from(trial);
      trialEndsAt = _readJsonDateTime(trialMap, 'endsAt', 'ends_at');
      if (trialMap['used'] == true) {
        trialUsed = true;
      }
    }

    var premiumExpiresAt = _readJsonDateTime(
      json,
      'premiumExpiresAt',
      'premium_expires_at',
    );
    final subscription = json['subscription'];
    if (subscription is Map<String, dynamic>) {
      final subscriptionExpiresAt =
          _readJsonDateTime(subscription, 'expiresAt', 'expires_at');
      if (subscriptionExpiresAt != null) {
        premiumExpiresAt = subscriptionExpiresAt;
      }
    } else if (subscription is Map) {
      final subscriptionMap = Map<String, dynamic>.from(subscription);
      final subscriptionExpiresAt =
          _readJsonDateTime(subscriptionMap, 'expiresAt', 'expires_at');
      if (subscriptionExpiresAt != null) {
        premiumExpiresAt = subscriptionExpiresAt;
      }
    }

    return UserProfile(
      userId: _readJsonString(json, 'userId', 'user_id') ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl: _readJsonString(json, 'avatarUrl', 'avatar_url'),
      tier: json['tier'] as String? ?? 'free',
      premiumExpiresAt: premiumExpiresAt,
      trialEndsAt: trialEndsAt,
      isNewUser: _readJsonBool(json, 'isNewUser', 'is_new_user'),
      requiresConsent: _readJsonBool(json, 'requiresConsent', 'requires_consent'),
      trialUsed: trialUsed,
      termsAgreedAt: _readJsonDateTime(json, 'termsAgreedAt', 'terms_agreed_at'),
    );
  }

  final String userId;
  final String email;
  final String name;
  final String? avatarUrl;
  final String tier;
  final DateTime? premiumExpiresAt;
  final DateTime? trialEndsAt;
  final bool isNewUser;
  final bool requiresConsent;
  final bool trialUsed;
  final DateTime? termsAgreedAt;
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
