import 'package:go_router/go_router.dart';

import '../../features/analysis/analysis_page.dart';
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
          path: '/report',
          builder: (context, state) => const ReportPage(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuPage(),
        ),
      ],
    ),
  ],
);
