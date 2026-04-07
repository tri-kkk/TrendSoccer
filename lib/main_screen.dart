import 'package:flutter/material.dart';

import 'core/theme/tokens/component_tokens.dart';
import 'features/analysis/analysis_page.dart';
import 'features/fixture/fixture_page.dart';
import 'features/menu/menu_page.dart';
import 'features/report/report_page.dart';
import 'features/trend/trend_page.dart';
import 'shared/widgets/navigation/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  NavigationTab _currentTab = NavigationTab.trend;

  static const _pages = [
    TrendPage(),
    AnalysisPage(),
    FixturePage(),
    ReportPage(),
    MenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentTab: _currentTab,
        onTabChanged: (tab) {
          setState(() => _currentTab = tab);
        },
      ),
    );
  }
}
