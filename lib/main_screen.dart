import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/shared/widgets/navigation/ts_bottom_navigation.dart';

/// Tab shell with bottom [TsBottomNavigation] (v2 tabs).
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
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForLocation(path);

    return Scaffold(
      body: child,
      bottomNavigationBar: TsBottomNavigation(
        currentIndex: selectedIndex,
        onTap: (index) => context.go(_tabPaths[index]),
      ),
    );
  }
}
