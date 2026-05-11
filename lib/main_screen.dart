import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

/// Tab shell with bottom [NavigationBar] (v2 tabs).
class MainScreen extends StatelessWidget {
  const MainScreen({required this.child, super.key});

  final Widget child;

  static const List<String> _tabPaths = [
    '/trend',
    '/analysis',
    '/fixture',
    '/premium',
    '/menu',
  ];

  int _selectedIndexForLocation(String path) {
    for (var i = 0; i < _tabPaths.length; i++) {
      if (path.startsWith(_tabPaths[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForLocation(path);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: semantic.surfaceRaised,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(_tabPaths[index]),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.trending_up, color: semantic.textTertiary),
            selectedIcon: Icon(Icons.trending_up, color: semantic.interactivePrimary),
            label: 'Trend',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics, color: semantic.textTertiary),
            selectedIcon: Icon(Icons.analytics, color: semantic.interactivePrimary),
            label: 'Analysis',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today, color: semantic.textTertiary),
            selectedIcon: Icon(Icons.calendar_today, color: semantic.interactivePrimary),
            label: 'Fixture',
          ),
          NavigationDestination(
            icon: Icon(Icons.star, color: semantic.textTertiary),
            selectedIcon: Icon(Icons.star, color: semantic.interactivePrimary),
            label: 'Premium',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu, color: semantic.textTertiary),
            selectedIcon: Icon(Icons.menu, color: semantic.interactivePrimary),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
