import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/badge/ts_badge.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/logo/ts_logo.dart';

/// Layout metrics shared by the tab-shell AppBar and Analysis/Fixture SliverAppBar.
abstract final class TsShellAppBarMetrics {
  static const double barHeight = 56;
  static const double logoHeight = 32;
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    horizontal: 16,
  );

  static double get contentHeight => barHeight - contentPadding.vertical;
}

/// Logo row + login/profile actions — identical to [MainScreen] shell AppBar content.
class TsShellAppBarContent extends StatelessWidget {
  const TsShellAppBarContent({
    required this.auth,
    this.onLogoTap,
    this.showProfileWhenLoggedIn = true,
    this.logoHeight = TsShellAppBarMetrics.logoHeight,
    super.key,
  });

  final SupabaseAuthProvider auth;
  final VoidCallback? onLogoTap;
  final bool showProfileWhenLoggedIn;
  final double logoHeight;

  static var _metricsLogged = false;

  static void logMetricsOnce() {
    if (_metricsLogged) return;
    _metricsLogged = true;
      }

  static TsBadgeType badgeForPlan(PlanType planType) {
    return switch (planType) {
      PlanType.none || PlanType.free => TsBadgeType.free,
      PlanType.trial => TsBadgeType.trial,
      PlanType.premium => TsBadgeType.premium,
    };
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final brightness = Theme.of(context).brightness;

    return SizedBox(
      height: logoHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onLogoTap,
            behavior: HitTestBehavior.opaque,
            child: TsLogo(
              type: TsLogoType.horizon,
              height: logoHeight,
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
          else if (showProfileWhenLoggedIn)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TsBadge(type: badgeForPlan(auth.planType)),
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
    );
  }
}

/// Title slot for [SliverAppBar] — horizontal padding only; SliverAppBar centers vertically.
class TsShellAppBarTitle extends StatelessWidget {
  const TsShellAppBarTitle({
    required this.auth,
    this.onLogoTap,
    this.showProfileWhenLoggedIn = true,
    super.key,
  });

  final SupabaseAuthProvider auth;
  final VoidCallback? onLogoTap;
  final bool showProfileWhenLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TsShellAppBarContent(
        auth: auth,
        onLogoTap: onLogoTap,
        showProfileWhenLoggedIn: showProfileWhenLoggedIn,
        logoHeight: TsShellAppBarMetrics.logoHeight,
      ),
    );
  }
}
