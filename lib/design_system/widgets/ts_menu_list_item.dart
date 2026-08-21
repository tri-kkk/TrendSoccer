import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsMenuListItem extends StatelessWidget {
  const TsMenuListItem({
    required this.label,
    this.icon,
    this.value,
    this.onTap,
    super.key,
  });

  final String label;
  final TsIconSpec? icon;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: Row(
          children: [
            if (icon != null) ...[
              TsIcon(icon!, size: TsIconSize.md, color: c.textSecondary),
              const SizedBox(width: TsSpacing.md),
            ],
            Expanded(
              child: Text(
                label,
                style: TsType.bodyLMedium.copyWith(color: c.textPrimary),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TsType.bodyMRegular.copyWith(color: c.textTertiary),
                textAlign: TextAlign.right,
              )
            else
              TsIcon(
                TsIcons.chevronRight,
                size: TsIconSize.md,
                color: c.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
