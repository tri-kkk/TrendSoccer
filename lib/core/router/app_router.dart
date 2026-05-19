import 'package:go_router/go_router.dart';
import 'package:trendsoccer/features/analysis/baseball_match_report_page.dart';
import 'package:trendsoccer/features/analysis/analysis_page.dart';
import 'package:trendsoccer/features/analysis/soccer_match_report_page.dart';
import 'package:trendsoccer/features/auth/login_page.dart';
import 'package:trendsoccer/features/auth/signup_complete_page.dart';
import 'package:trendsoccer/features/auth/signup_terms_page.dart';
import 'package:trendsoccer/features/fixture/fixture_page.dart';
import 'package:trendsoccer/features/menu/about_page.dart';
import 'package:trendsoccer/features/menu/help_center_page.dart';
import 'package:trendsoccer/features/menu/menu_page.dart';
import 'package:trendsoccer/features/menu/privacy_policy_page.dart';
import 'package:trendsoccer/features/menu/subscribe_fail_page.dart';
import 'package:trendsoccer/features/menu/subscribe_page.dart';
import 'package:trendsoccer/features/menu/subscribe_success_page.dart';
import 'package:trendsoccer/features/menu/terms_of_service_page.dart';
import 'package:trendsoccer/features/premium/premium_page.dart';
import 'package:trendsoccer/features/report/soccer_report_detail_page.dart';
import 'package:trendsoccer/features/report/soccer_report_list_page.dart';
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
      GoRoute(
        path: '/menu/subscribe',
        builder: (context, state) => const SubscribePage(),
      ),
      GoRoute(
        path: '/menu/subscribe/success',
        builder: (context, state) => const SubscribeSuccessPage(),
      ),
      GoRoute(
        path: '/menu/subscribe/fail',
        builder: (context, state) => const SubscribeFailPage(),
      ),
      GoRoute(
        path: '/menu/about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/menu/privacy',
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: '/menu/terms',
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(
        path: '/menu/help',
        builder: (context, state) => const HelpCenterPage(),
      ),
      GoRoute(
        path: '/menu/reports/soccer',
        builder: (context, state) => const SoccerReportListPage(),
      ),
      GoRoute(
        path: '/menu/reports/soccer/:id',
        builder: (context, state) =>
            SoccerReportDetailPage(reportId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/analysis/soccer/match-report/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId'] ?? '';
          return SoccerMatchReportPage(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/analysis/baseball/match-report/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId'] ?? '';
          return BaseballMatchReportPage(matchId: matchId);
        },
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
