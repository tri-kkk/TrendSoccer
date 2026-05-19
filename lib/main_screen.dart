import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';import 'package:trendsoccer/shared/widgets/badge/ts_badge.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/logo/ts_logo.dart';
import 'package:trendsoccer/shared/widgets/navigation/ts_bottom_navigation.dart';

/// Tab shell with bottom [TsBottomNavigation] (v2 tabs).
class MainScreen extends ConsumerWidget {
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

  TsBadgeType _badgeForPlan(PlanType planType) {
    return switch (planType) {
      PlanType.none || PlanType.free => TsBadgeType.free,
      PlanType.trial => TsBadgeType.trial,
      PlanType.premium => TsBadgeType.premium,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForLocation(path);
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final brightness = Theme.of(context).brightness;
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      body: Column(
        children: [
          if (selectedIndex == 0 ||
              selectedIndex == 1 ||
              selectedIndex == 2 ||
              selectedIndex == 3 ||
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
                    GestureDetector(
                      onTap: selectedIndex == 0
                          ? null
                          : () => context.go('/trend'),
                      behavior: HitTestBehavior.opaque,
                      child: TsLogo(
                        type: TsLogoType.horizon,
                        color: brightness == Brightness.dark
                            ? TsLogoColor.white
                            : TsLogoColor.black,
                      ),
                    ),
                    if (!auth.isLoggedIn)
                      TsButton(
                        label: '로그인',
                        variant: TsButtonVariant.primary,
                        size: TsButtonSize.small,
                        onPressed: () => context.push('/login'),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TsBadge(type: _badgeForPlan(auth.planType)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => context.go('/menu'),
                            child: SvgPicture.asset(
                              TsAssets.iconAccountCircle,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                semantic.textPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: TsBottomNavigation(
          currentIndex: selectedIndex,
          onTap: (index) => context.go(_tabPaths[index]),
        ),
      ),
    );
  }
}
