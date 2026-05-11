import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/logo/ts_logo.dart';
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
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: Column(
        children: [
          if (selectedIndex == 0 || selectedIndex == 1)
            SafeArea(
              bottom: false,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: semantic.surfaceBase,
                  border: Border(
                    bottom: BorderSide(
                      color: semantic.textDisabled,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TsLogo(
                      type: TsLogoType.horizon,
                      color: brightness == Brightness.dark
                          ? TsLogoColor.white
                          : TsLogoColor.black,
                    ),
                    TsButton(
                      label: '로그인',
                      variant: TsButtonVariant.primary,
                      size: TsButtonSize.small,
                      onPressed: () => context.push('/login'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: TsBottomNavigation(
        currentIndex: selectedIndex,
        onTap: (index) => context.go(_tabPaths[index]),
      ),
    );
  }
}
