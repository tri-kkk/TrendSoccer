import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/analysis_page.dart';
import '../../features/analysis/soccer_match_report_page.dart';
import '../../features/fixture/fixture_page.dart';
import '../../features/menu/menu_page.dart';
import '../../features/report/report_page.dart';
import '../../features/trend/trend_page.dart';
import '../../main_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/trend',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/trend',
          pageBuilder: (context, state) => const CupertinoPage(
            child: TrendPage(),
          ),
        ),
        GoRoute(
          path: '/analysis',
          pageBuilder: (context, state) => const CupertinoPage(
            child: AnalysisPage(),
          ),
        ),
        GoRoute(
          path: '/fixture',
          pageBuilder: (context, state) => const CupertinoPage(
            child: FixturePage(),
          ),
        ),
        GoRoute(
          path: '/report',
          pageBuilder: (context, state) => const CupertinoPage(
            child: ReportPage(),
          ),
        ),
        GoRoute(
          path: '/menu',
          pageBuilder: (context, state) => const CupertinoPage(
            child: MenuPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/analysis/soccer/match-report/:matchId',
      builder: (context, state) => SoccerMatchReportPage(
        matchId: state.pathParameters['matchId']!,
      ),
    ),
  ],
);
