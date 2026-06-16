import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/badge/ts_badge.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/logo/ts_logo.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/navigation/ts_bottom_navigation.dart';

const List<String> _tabPaths = [
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

void _showExitDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final dialogSemantic = Theme.of(
        dialogContext,
      ).extension<TsSemanticColors>()!;
      return Dialog(
        backgroundColor: dialogSemantic.surfaceOverlay,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dialogContext.l10n.exitTitle,
                style: TsType.headingH2.copyWith(
                  color: dialogSemantic.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                dialogContext.l10n.exitMessage,
                style: TsType.bodyLRegular.copyWith(
                  color: dialogSemantic.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TsButton(
                      label: dialogContext.l10n.cancel,
                      variant: TsButtonVariant.secondary,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TsButton(
                      label: dialogContext.l10n.exitConfirm,
                      variant: TsButtonVariant.primary,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        SystemNavigator.pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Tab shell with bottom [TsBottomNavigation] (v2 tabs).
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForLocation(path);
    final isMenuTab = selectedIndex == 4;
    final isAnalysisTab = path.startsWith('/analysis');
    final isRootTab = _tabPaths.contains(path);
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final brightness = Theme.of(context).brightness;
    final auth = ref.watch(authProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (isRootTab) {
          _showExitDialog(context);
          return;
        }

        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }

        _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: semantic.surfaceBase,
        body: Column(
          children: [
            if (isRootTab && !isAnalysisTab)
              SafeArea(
                bottom: false,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                          label: context.l10n.loginAppBarTitle,
                          variant: TsButtonVariant.primary,
                          size: TsButtonSize.small,
                          onPressed: () => context.push('/login'),
                        )
                      else if (!isMenuTab)
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
            Expanded(child: widget.child),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: TsBottomNavigation(
            currentIndex: selectedIndex,
            onTap: (index) {
              if (index == 1) {
                ref.read(selectedLeagueProvider.notifier).state = null;
                ref.read(selectedBaseballLeagueProvider.notifier).state = null;
                ref.read(soccerAnalysisDateProvider.notifier).state =
                    fixtureTodayDateString();
                ref.read(baseballAnalysisDateProvider.notifier).state =
                    baseballTodayDateString();
              }
              if (index == 2) {
                ref.read(fixtureSelectedDateProvider.notifier).state =
                    fixtureTodayDateString();
                ref.read(fixtureLiveFilterProvider.notifier).state = false;
                ref.read(fixtureSelectedLeagueProvider.notifier).state = null;
              }
              context.go(_tabPaths[index]);
              debugPrint(
                '[NAV] Tab changed: index=$index, '
                'path=${GoRouterState.of(context).uri}',
              );
            },
          ),
        ),
      ),
    );
  }
}
