import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_bottom_navigation.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: navigationShell,
          ),
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: c.surface,
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: TsBottomNavigation(
                active: TsNavTab.values[navigationShell.currentIndex],
                onTap: (tab) {
                  final i = TsNavTab.values.indexOf(tab);
                  navigationShell.goBranch(
                    i,
                    initialLocation: i == navigationShell.currentIndex,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
