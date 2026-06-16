import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
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
import 'package:trendsoccer/features/menu/notification_settings_page.dart';
import 'package:trendsoccer/features/menu/privacy_policy_page.dart';
import 'package:trendsoccer/features/menu/subscribe_fail_page.dart';
import 'package:trendsoccer/features/menu/subscribe_page.dart';
import 'package:trendsoccer/features/menu/subscribe_success_page.dart';
import 'package:trendsoccer/features/menu/terms_of_service_page.dart';
import 'package:trendsoccer/features/premium/premium_page.dart';
import 'package:trendsoccer/features/report/soccer_report_detail_page.dart';
import 'package:trendsoccer/features/report/soccer_report_list_page.dart';
import 'package:trendsoccer/features/maintenance/maintenance_page.dart';
import 'package:trendsoccer/features/splash/splash_page.dart';
import 'package:trendsoccer/features/trend/trend_page.dart';
import 'package:trendsoccer/features/update/force_update_page.dart';
import 'package:trendsoccer/main_screen.dart';

/// v2 app routing: tab shell + auth/splash stubs.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/maintenance',
        builder: (context, state) {
          final message = state.extra is String ? state.extra! as String : null;
          return MaintenancePage(maintenanceMessage: message);
        },
      ),
      GoRoute(
        path: '/force-update',
        builder: (context, state) {
          final message = state.extra is String ? state.extra! as String : null;
          return ForceUpdatePage(updateMessage: message);
        },
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
        builder: (context, state) {
          final months = state.extra is int ? state.extra! as int : 3;
          return SubscribeSuccessPage(months: months);
        },
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
        path: '/analysis/soccer/match-report/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId'] ?? '';
          final extra = state.extra;
          final headerData = MatchHeaderData.fromRouteExtra(extra);
          final matchTimestampUtc =
              MatchHeaderData.timestampFromRouteExtra(extra)?.toUtc();
          return SoccerMatchReportPage(
            matchId: matchId,
            initialHeader: headerData,
            matchTimestampUtc: matchTimestampUtc,
          );
        },
      ),
      GoRoute(
        path: '/analysis/baseball/match-report/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId'] ?? '';
          final headerData = MatchHeaderData.fromRouteExtra(state.extra);
          return BaseballMatchReportPage(
            matchId: matchId,
            initialHeader: headerData,
          );
        },
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/trend',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TrendPage(),
            ),
          ),
          GoRoute(
            path: '/analysis',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const AnalysisPage(),
            ),
          ),
          GoRoute(
            path: '/fixture',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FixturePage(),
            ),
          ),
          GoRoute(
            path: '/premium',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const PremiumPage(),
            ),
          ),
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const MenuPage(),
            ),
            routes: [
              GoRoute(
                path: 'reports/soccer',
                builder: (context, state) => const SoccerReportListPage(),
              ),
              GoRoute(
                path: 'reports/soccer/:slug',
                builder: (context, state) => SoccerReportDetailPage(
                  slug: state.pathParameters['slug'] ?? '',
                ),
              ),
              GoRoute(
                path: 'privacy',
                builder: (context, state) => const PrivacyPolicyPage(),
              ),
              GoRoute(
                path: 'terms',
                builder: (context, state) => const TermsOfServicePage(),
              ),
              GoRoute(
                path: 'help',
                builder: (context, state) => const HelpCenterPage(),
              ),
              GoRoute(
                path: 'notification-settings',
                builder: (context, state) => const NotificationSettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
