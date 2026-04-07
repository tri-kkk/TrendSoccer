import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/tokens/component_tokens.dart';
import 'shared/widgets/navigation/bottom_navigation.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  NavigationTab _getCurrentTab(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    switch (location) {
      case '/trend':
        return NavigationTab.trend;
      case '/analysis':
        return NavigationTab.analysis;
      case '/fixture':
        return NavigationTab.fixture;
      case '/report':
        return NavigationTab.report;
      case '/menu':
        return NavigationTab.menu;
      default:
        return NavigationTab.trend;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavigation(
        currentTab: _getCurrentTab(context),
        onTabChanged: (tab) {
          switch (tab) {
            case NavigationTab.trend:
              context.go('/trend');
            case NavigationTab.analysis:
              context.go('/analysis');
            case NavigationTab.fixture:
              context.go('/fixture');
            case NavigationTab.report:
              context.go('/report');
            case NavigationTab.menu:
              context.go('/menu');
          }
        },
      ),
    );
  }
}
