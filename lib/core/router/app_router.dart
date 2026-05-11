import 'package:go_router/go_router.dart';
import 'package:trendsoccer/features/analysis/analysis_page.dart';
import 'package:trendsoccer/features/auth/login_page.dart';
import 'package:trendsoccer/features/auth/signup_complete_page.dart';
import 'package:trendsoccer/features/auth/signup_terms_page.dart';
import 'package:trendsoccer/features/fixture/fixture_page.dart';
import 'package:trendsoccer/features/menu/menu_page.dart';
import 'package:trendsoccer/features/premium/premium_page.dart';
import 'package:trendsoccer/features/splash/splash_page.dart';
import 'package:trendsoccer/features/trend/trend_page.dart';
import 'package:trendsoccer/main_screen.dart';

/// v2 app routing: tab shell + auth/splash stubs.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup/terms',
        builder: (context, state) => const SignupTermsPage(),
      ),
      GoRoute(
        path: '/signup/complete',
        builder: (context, state) => const SignupCompletePage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/trend',
            builder: (context, state) => const TrendPage(),
          ),
          GoRoute(
            path: '/analysis',
            builder: (context, state) => const AnalysisPage(),
          ),
          GoRoute(
            path: '/fixture',
            builder: (context, state) => const FixturePage(),
          ),
          GoRoute(
            path: '/premium',
            builder: (context, state) => const PremiumPage(),
          ),
          GoRoute(
            path: '/menu',
            builder: (context, state) => const MenuPage(),
          ),
        ],
      ),
    ],
  );
}
