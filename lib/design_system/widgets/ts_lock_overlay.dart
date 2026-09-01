import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';

enum TsLockSize { normal, compact, inline }

const double _inlineLockOverlayMinHeight = 32;
const double _inlineLockOverlayMinWidth = 200;

class TsLockOverlay extends StatelessWidget {
  const TsLockOverlay({
    this.size = TsLockSize.normal,
    this.headline = 'Premium content',
    this.subline = 'Subscribe to view full analysis',
    this.actionLabel = 'View plans',
    this.onAction,
    super.key,
  });

  final TsLockSize size;
  final String headline;
  final String subline;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return ClipRRect(
      borderRadius: TsRadius.md,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          constraints: size == TsLockSize.inline
              ? const BoxConstraints(
                  minHeight: _inlineLockOverlayMinHeight,
                  minWidth: _inlineLockOverlayMinWidth,
                )
              : null,
          decoration: BoxDecoration(
            color: c.scrim,
            borderRadius: TsRadius.md,
          ),
          padding: switch (size) {
        TsLockSize.normal => const EdgeInsets.symmetric(
            vertical: TsSpacing.xl,
            horizontal: TsSpacing.lg,
          ),
        TsLockSize.compact => const EdgeInsets.symmetric(
            vertical: TsSpacing.md,
            horizontal: TsSpacing.lg,
          ),
        TsLockSize.inline => const EdgeInsets.symmetric(
            vertical: TsSpacing.sm,
            horizontal: TsSpacing.lg,
          ),
      },
      child: switch (size) {
        TsLockSize.normal => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TsIcon(TsIcons.lock, size: TsIconSize.md, color: c.onScrim),
              const SizedBox(height: TsSpacing.md),
              Text(
                headline,
                style: TsType.h3.copyWith(color: c.onScrim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TsSpacing.sm),
              Text(
                subline,
                style: TsType.labelSMedium.copyWith(color: c.onScrimSubtle),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: actionLabel,
                style: TsButtonStyle.primary,
                size: TsButtonSize.small,
                onPressed: onAction,
              ),
            ],
          ),
        TsLockSize.compact => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TsIcon(TsIcons.lock, size: TsIconSize.md, color: c.onScrim),
              const SizedBox(height: TsSpacing.md),
              Text(
                headline,
                style: TsType.h3.copyWith(color: c.onScrim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TsSpacing.lg),
              TsButton(
                label: actionLabel,
                style: TsButtonStyle.primary,
                size: TsButtonSize.small,
                onPressed: onAction,
              ),
            ],
          ),
        TsLockSize.inline => Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TsIcon(TsIcons.lock, size: TsIconSize.xs, color: c.onScrim),
              const SizedBox(width: TsSpacing.sm),
              Flexible(
                child: Text(
                  headline,
                  style: TsType.bodyMBold.copyWith(
                    color: c.onScrim,
                    letterSpacing: TsType.h3.letterSpacing,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      },
        ),
      ),
    );
  }
}
