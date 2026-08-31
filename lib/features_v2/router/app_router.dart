import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/features_v2/auth/login_screen.dart';
import 'package:trendsoccer/features_v2/auth/signup_complete_screen.dart';
import 'package:trendsoccer/features_v2/auth/signup_terms_screen.dart';
import 'package:trendsoccer/features_v2/auth/splash_screen.dart';
import 'package:trendsoccer/features_v2/feed/feed_highlights_screen.dart';
import 'package:trendsoccer/features_v2/feed/feed_news_screen.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_screen.dart';
import 'package:trendsoccer/features_v2/feed/preview_detail_screen.dart';
import 'package:trendsoccer/features_v2/home/home_screen.dart';
import 'package:trendsoccer/features_v2/matches/match_report_screen.dart';
import 'package:trendsoccer/features_v2/matches/matches_screen.dart';
import 'package:trendsoccer/features_v2/menu/help_screen.dart';
import 'package:trendsoccer/features_v2/menu/menu_screen.dart';
import 'package:trendsoccer/features_v2/menu/notification_settings_screen.dart';
import 'package:trendsoccer/features_v2/menu/payment_failed_screen.dart';
import 'package:trendsoccer/features_v2/menu/payment_success_screen.dart';
import 'package:trendsoccer/features_v2/menu/privacy_screen.dart';
import 'package:trendsoccer/features_v2/menu/subscribe_screen.dart';
import 'package:trendsoccer/features_v2/menu/terms_screen.dart';
import 'package:trendsoccer/features_v2/reports/combo_detail_screen.dart';
import 'package:trendsoccer/features_v2/reports/reports_baseball_screen.dart';
import 'package:trendsoccer/features_v2/reports/reports_combo_screen.dart';
import 'package:trendsoccer/features_v2/reports/reports_soccer_premium_screen.dart';
import 'package:trendsoccer/features_v2/reports/reports_soccer_screen.dart';
import 'package:trendsoccer/features_v2/shell/main_shell.dart';
import 'package:trendsoccer/features_v2/system/billing_loading_screen.dart';
import 'package:trendsoccer/features_v2/system/force_update_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _homeKey = GlobalKey<NavigatorState>();
final _matchesKey = GlobalKey<NavigatorState>();
final _reportsKey = GlobalKey<NavigatorState>();
final _feedKey = GlobalKey<NavigatorState>();
final _menuKey = GlobalKey<NavigatorState>();

GoRoute _r(String path, String name, Widget child) => GoRoute(
      path: path,
      name: name,
      builder: (_, _) => child,
    );

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/splash',
  redirect: (context, state) {
    final p = state.uri.path;
    if (p == '/reports' || p == '/reports/') return '/reports/soccer';
    if (p == '/feed' || p == '/feed/') return '/feed/preview';
    return null;
  },
  routes: [
    _r('/splash', 'splash', const SplashScreen()),
    _r('/login', 'login', const LoginScreen()),
    _r('/signup/terms', 'signupTerms', const SignupTermsScreen()),
    _r('/signup/complete', 'signupComplete', const SignupCompleteScreen()),
    GoRoute(
      path: '/matches/:sport/:matchId',
      name: 'matchReport',
      builder: (_, s) => MatchReportScreen(
        sport: s.pathParameters['sport']!,
        matchId: s.pathParameters['matchId']!,
        initialHeader: MatchHeaderData.fromRouteExtra(s.extra),
      ),
    ),
    GoRoute(
      path: '/reports/combo/:comboId',
      name: 'comboDetail',
      builder: (_, s) => ComboDetailScreen(comboId: s.pathParameters['comboId']!),
    ),
    GoRoute(
      path: '/feed/preview/:slug',
      name: 'previewDetail',
      builder: (_, s) => PreviewDetailScreen(slug: s.pathParameters['slug']!),
    ),
    _r('/menu/subscribe', 'subscribe', const SubscribeScreen()),
    _r('/menu/payment/success', 'paymentSuccess', const PaymentSuccessScreen()),
    _r('/menu/payment/failed', 'paymentFailed', const PaymentFailedScreen()),
    GoRoute(
      path: '/force-update',
      name: 'forceUpdate',
      builder: (_, s) =>
          ForceUpdateScreen(args: s.extra as ForceUpdateArgs?),
    ),
    _r('/billing-loading', 'billingLoading', const BillingLoadingScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeKey,
          routes: [_r('/home', 'home', const HomeScreen())],
        ),
        StatefulShellBranch(
          navigatorKey: _matchesKey,
          routes: [_r('/matches', 'matches', const MatchesScreen())],
        ),
        StatefulShellBranch(
          navigatorKey: _reportsKey,
          initialLocation: '/reports/soccer',
          routes: [
            _r('/reports/soccer', 'reportsSoccer', const ReportsSoccerScreen()),
            _r('/reports/soccer/premium', 'reportsSoccerPremium', const ReportsSoccerPremiumScreen()),
            _r('/reports/baseball', 'reportsBaseball', const ReportsBaseballScreen()),
            _r('/reports/combo', 'reportsCombo', const ReportsComboScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _feedKey,
          initialLocation: '/feed/preview',
          routes: [
            _r('/feed/preview', 'feedPreview', const FeedPreviewScreen()),
            _r('/feed/news', 'feedNews', const FeedNewsScreen()),
            _r('/feed/highlights', 'feedHighlights', const FeedHighlightsScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _menuKey,
          routes: [
            GoRoute(
              path: '/menu',
              name: 'menu',
              builder: (_, _) => const MenuScreen(),
              routes: [
                GoRoute(
                  path: 'notification-settings',
                  name: 'notificationSettings',
                  builder: (_, _) => const NotificationSettingsScreen(),
                ),
                GoRoute(
                  path: 'privacy',
                  name: 'privacy',
                  builder: (_, _) => const PrivacyScreen(),
                ),
                GoRoute(
                  path: 'terms',
                  name: 'terms',
                  builder: (_, _) => const TermsScreen(),
                ),
                GoRoute(
                  path: 'help',
                  name: 'help',
                  builder: (_, _) => const HelpScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
