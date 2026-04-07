import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/providers/navigation_provider.dart';
import 'shared/widgets/navigation/bottom_navigation.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 라우트로부터 탭 상태 동기화
    final location = GoRouterState.of(context).uri.toString();
    final currentTab = getTabFromRoute(location);

    // Provider 업데이트 (라우트 변경 감지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(currentTabProvider) != currentTab) {
        ref.read(currentTabProvider.notifier).setTab(currentTab);
      }
    });

    final selectedTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavigation(
        currentTab: selectedTab,
        onTabChanged: (tab) {
          ref.read(currentTabProvider.notifier).setTab(tab);
          context.go(getRouteFromTab(tab));
        },
      ),
    );
  }
}
