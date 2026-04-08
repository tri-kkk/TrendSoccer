/// Authentication status of the current user.
enum AuthStatus {
  /// Not signed in — limited access.
  guest,

  /// Signed in with valid credentials.
  loggedIn,
}

/// Immutable snapshot of the current user's authentication state.
///
/// ```dart
/// const initial = UserState(authStatus: AuthStatus.guest);
///
/// final updated = initial.copyWith(
///   authStatus: AuthStatus.loggedIn,
///   name: 'Son Heung-min',
///   email: 'son@spurs.com',
/// );
/// ```
class UserState {
  const UserState({
    required this.authStatus,
    this.name,
    this.email,
  });

  /// Current authentication status.
  final AuthStatus authStatus;

  /// Display name. Null when [authStatus] is [AuthStatus.guest].
  final String? name;

  /// Email address. Null when [authStatus] is [AuthStatus.guest].
  final String? email;

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass explicit `null` via the sentinel to clear nullable fields:
  /// ```dart
  /// state.copyWith(authStatus: AuthStatus.guest, name: null, email: null);
  /// ```
  UserState copyWith({
    AuthStatus? authStatus,
    String? name,
    String? email,
  }) {
    return UserState(
      authStatus: authStatus ?? this.authStatus,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserState &&
          runtimeType == other.runtimeType &&
          authStatus == other.authStatus &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode => Object.hash(authStatus, name, email);

  @override
  String toString() =>
      'UserState(authStatus: $authStatus, name: $name, email: $email)';
}
