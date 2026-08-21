import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsButtonStyle { primary, secondary, ghost, danger }

enum TsButtonSize { large, small }

class TsButton extends StatelessWidget {
  const TsButton({
    required this.label,
    this.onPressed,
    this.style = TsButtonStyle.primary,
    this.size = TsButtonSize.large,
    this.icon,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final TsButtonStyle style;
  final TsButtonSize size;
  final TsIconSpec? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final enabled = onPressed != null;
    final height =
        size == TsButtonSize.large ? TsSpacing.xxxl : TsSpacing.xxl;
    final horizontalPadding =
        size == TsButtonSize.large ? TsSpacing.lg : TsSpacing.md;
    final iconSize = size == TsButtonSize.large ? 20.0 : TsSpacing.lg;
    final textStyle =
        size == TsButtonSize.large ? TsType.bodyLBold : TsType.bodyMBold;

    final Color background;
    final Color labelColor;
    final Border? border;

    switch (style) {
      case TsButtonStyle.primary:
        background = enabled ? c.primary : c.textDisabled;
        labelColor = c.onPrimary;
        border = null;
      case TsButtonStyle.secondary:
        background = Colors.transparent;
        labelColor = enabled ? c.textPrimary : c.textDisabled;
        border = Border.all(
          color: enabled ? c.primary : c.textDisabled,
          width: 1,
        );
      case TsButtonStyle.ghost:
        background = Colors.transparent;
        labelColor = enabled ? c.primary : c.textDisabled;
        border = null;
      case TsButtonStyle.danger:
        background = c.error;
        labelColor = c.onPrimary;
        border = null;
    }

    Widget child = Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: background,
          borderRadius: TsRadius.sm,
          border: border,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: TsRadius.sm,
          child: SizedBox(
            height: height,
            width: expand ? double.infinity : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    TsIcon(icon!, size: iconSize, color: labelColor),
                    const SizedBox(width: TsSpacing.sm),
                  ],
                  Text(label, style: textStyle.copyWith(color: labelColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (style == TsButtonStyle.danger && !enabled) {
      child = Opacity(opacity: 0.4, child: child);
    }

    return child;
  }
}
