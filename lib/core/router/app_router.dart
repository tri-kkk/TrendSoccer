import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/baseball_match_report_page.dart';
import 'package:trendsoccer/features/analysis/analysis_page.dart';
import 'package:trendsoccer/features/analysis/soccer_match_report_page.dart';
import 'package:trendsoccer/features/auth/login_page.dart';
import 'package:trendsoccer/features/auth/signup_complete_page.dart';
import 'package:trendsoccer/features/auth/signup_terms_page.dart';
import 'package:trendsoccer/features/fixture/fixture_page.dart';
import 'package:trendsoccer/features/menu/menu_page.dart';
import 'package:trendsoccer/features/menu/subscribe_page.dart';
import 'package:trendsoccer/features/premium/premium_page.dart';
import 'package:trendsoccer/features/splash/splash_page.dart';
import 'package:trendsoccer/features/trend/trend_page.dart';
import 'package:trendsoccer/main_screen.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';

Widget _menuStubRoutePage(BuildContext context, String title) {
  final semantic = Theme.of(context).extension<TsSemanticColors>()!;
  return Scaffold(
    backgroundColor: semantic.surfaceBase,
    appBar: TsAppBar(location: TsAppBarLocation.backTitle, title: title),
    body: Center(
      child: Text(
        title,
        style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
      ),
    ),
  );
}

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
        path: '/menu/about',
        builder: (context, state) => _menuStubRoutePage(context, 'About'),
      ),
      GoRoute(
        path: '/menu/privacy',
        builder: (context, state) => _menuStubRoutePage(context, '개인정보처리방침'),
      ),
      GoRoute(
        path: '/menu/terms',
        builder: (context, state) => _menuStubRoutePage(context, '이용약관'),
      ),
      GoRoute(
        path: '/menu/help',
        builder: (context, state) => _menuStubRoutePage(context, '도움말'),
      ),
      GoRoute(
        path: '/menu/reports/soccer',
        builder: (context, state) => _menuStubRoutePage(context, 'Soccer Reports'),
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
