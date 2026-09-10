import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/utils/plan_tier_label.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_bottom_navigation.dart';
import 'package:trendsoccer/design_system/widgets/ts_segment_tabs.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';

/// Shared feed header: app bar, segment tabs, optional filter row.
class FeedHeaderShell extends ConsumerWidget {
  const FeedHeaderShell({
    required this.segment,
    required this.child,
    this.filterRow,
    super.key,
  });

  final FeedSegment segment;
  final Widget child;
  final Widget? filterRow;

  void _onSegmentTap(BuildContext context, int index) {
    final targetSegment = feedSegmentAtIndex(index);
    if (targetSegment == segment) return;
    final route = feedRouteFor(targetSegment);
    if (GoRouterState.of(context).uri.path != route) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isGuest = auth.planType == PlanType.none;
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final segmentLabels = feedSegmentLabels(l10n);
    final activeSegmentIndex = feedSegmentIndex(segment);

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: isGuest ? TsAppBarType.homeGuest : TsAppBarType.homeMember,
        authLabel: 'Log in',
        onAuthTap: () => context.push('/login'),
        tierLabel: PlanTierLabel.forPlanType(auth.planType),
        onAvatarTap: () {
          StatefulNavigationShell.of(context).goBranch(
            TsNavTab.values.indexOf(TsNavTab.menu),
          );
        },
      ),
      body: ColoredBox(
        color: c.canvas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FeedHeaderControls(
              segmentLabels: segmentLabels,
              activeSegmentIndex: activeSegmentIndex,
              onSegmentTap: (index) => _onSegmentTap(context, index),
            ),
            if (filterRow != null) ...[
              const SizedBox(height: _FeedHeaderControls.gapBelow),
              filterRow!,
              const SizedBox(height: _FeedHeaderControls.gapBelow),
            ] else
              const SizedBox(height: _FeedHeaderControls.gapBelow),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _FeedHeaderControls extends StatelessWidget {
  const _FeedHeaderControls({
    required this.segmentLabels,
    required this.activeSegmentIndex,
    required this.onSegmentTap,
  });

  /// Figma HeaderControls: padding top 12 + tabs 44 = 56.
  static const double height = 56;
  static const double topPadding = TsSpacing.md;
  static const double gapBelow = TsSpacing.lg;

  final List<String> segmentLabels;
  final int activeSegmentIndex;
  final ValueChanged<int> onSegmentTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: topPadding),
        child: TsSegmentTabs(
          labels: segmentLabels,
          activeIndex: activeSegmentIndex,
          onTap: onSegmentTap,
        ),
      ),
    );
  }
}
