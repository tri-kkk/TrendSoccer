import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/tokens/component_tokens.dart';

/// Current selected tab state provider.
///
/// Manages the currently active navigation tab.
/// Default: [NavigationTab.trend]
final currentTabProvider =
    NotifierProvider<CurrentTabNotifier, NavigationTab>(CurrentTabNotifier.new);

class CurrentTabNotifier extends Notifier<NavigationTab> {
  @override
  NavigationTab build() => NavigationTab.trend;

  void setTab(NavigationTab tab) => state = tab;
}

/// Navigation tab to route path mapping.
///
/// Converts [NavigationTab] enum to route path string.
String getRouteFromTab(NavigationTab tab) {
  switch (tab) {
    case NavigationTab.trend:
      return '/trend';
    case NavigationTab.analysis:
      return '/analysis';
    case NavigationTab.fixture:
      return '/fixture';
    case NavigationTab.report:
      return '/report';
    case NavigationTab.menu:
      return '/menu';
  }
}

/// Route path to navigation tab mapping.
///
/// Converts route path string to [NavigationTab] enum.
NavigationTab getTabFromRoute(String route) {
  final path = route.split('?').first;
  if (path == '/report' || path.startsWith('/report/')) {
    return NavigationTab.report;
  }
  switch (path) {
    case '/trend':
      return NavigationTab.trend;
    case '/analysis':
      return NavigationTab.analysis;
    case '/fixture':
      return NavigationTab.fixture;
    case '/menu':
      return NavigationTab.menu;
    default:
      return NavigationTab.trend;
  }
}
