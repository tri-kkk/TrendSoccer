import 'package:go_router/go_router.dart';

/// Lightweight navigation bridge for services that must not import [AppRouter].
abstract final class AppNavigation {
  static GoRouter? _router;

  static void bind(GoRouter router) {
    _router = router;
  }

  static void go(String location) {
    _router?.go(location);
  }
}
