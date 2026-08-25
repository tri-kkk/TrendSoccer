import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_logo.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';

enum TsAppBarType { title, back, homeGuest, homeMember }

class TsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TsAppBar({
    this.type = TsAppBarType.title,
    this.title,
    this.onBack,
    this.authLabel = 'Log in',
    this.onAuthTap,
    this.tierLabel = 'PREMIUM',
    this.onAvatarTap,
    super.key,
  });

  final TsAppBarType type;
  final String? title;
  final VoidCallback? onBack;
  final String authLabel;
  final VoidCallback? onAuthTap;
  final String tierLabel;
  final VoidCallback? onAvatarTap;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Material(
      color: c.canvas,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: switch (type) {
          TsAppBarType.title => Padding(
              padding: const EdgeInsets.all(TsSpacing.lg),
              child: Text(
                title ?? '',
                style: TsType.h3.copyWith(color: c.textPrimary),
                textAlign: TextAlign.center,
              ),
            ),
          TsAppBarType.back => Padding(
              padding: const EdgeInsets.all(TsSpacing.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: TsIcon(
                      TsIcons.arrowBack,
                      size: TsIconSize.md,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: Text(
                      title ?? '',
                      style: TsType.h3.copyWith(color: c.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.xl, height: TsSpacing.xl),
                ],
              ),
            ),
          TsAppBarType.homeGuest => Padding(
              padding: const EdgeInsets.symmetric(
                vertical: TsSpacing.md,
                horizontal: TsSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TsLogo(TsLogoType.horizon, height: TsSpacing.xxl),
                  TsButton(
                    label: authLabel,
                    style: TsButtonStyle.primary,
                    size: TsButtonSize.small,
                    onPressed: onAuthTap,
                  ),
                ],
              ),
            ),
          TsAppBarType.homeMember => Padding(
              padding: const EdgeInsets.symmetric(
                vertical: TsSpacing.md,
                horizontal: TsSpacing.lg,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TsLogo(TsLogoType.horizon, height: TsSpacing.xxl),
                  Row(
                    children: [
                      TsBadge(label: tierLabel, tone: TsBadgeTone.primary),
                      const SizedBox(width: TsSpacing.sm),
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: TsIcon(
                          TsIcons.accountCircle,
                          size: TsIconSize.md,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        },
        ),
      ),
    );
  }
}
