import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
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
            if (selectedIndex == 0 ||
                selectedIndex == 1 ||
                selectedIndex == 2 ||
                selectedIndex == 4)
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
          if (selectedIndex == 3)
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: TsColors.membershipPremium500,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Premium',
                            style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: semantic.surfaceContainer,
                            border: Border.all(color: semantic.borderSubtle, width: 1),
                          ),
                          child: Icon(Icons.person, size: 20, color: semantic.textTertiary),
                        ),
                      ],
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
