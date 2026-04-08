import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_state.dart';

/// Global provider that holds the current user's authentication state.
///
/// Defaults to [AuthStatus.guest]. Update via:
/// ```dart
/// ref.read(userProvider.notifier).login(
///   name: 'Son Heung-min',
///   email: 'son@spurs.com',
/// );
/// ```
final userProvider =
    NotifierProvider<UserNotifier, UserState>(UserNotifier.new);

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() => const UserState(authStatus: AuthStatus.guest);

  void login({required String name, required String email}) {
    state = UserState(
      authStatus: AuthStatus.loggedIn,
      name: name,
      email: email,
    );
  }

  void logout() {
    state = const UserState(authStatus: AuthStatus.guest);
  }

  void update({String? name, String? email}) {
    state = state.copyWith(name: name, email: email);
  }
}
