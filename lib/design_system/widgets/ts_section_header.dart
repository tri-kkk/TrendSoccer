import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsSectionHeader extends StatelessWidget {
  const TsSectionHeader({
    required this.title,
    this.icon,
    this.trailing,
    this.subtitle,
    super.key,
  });

  final String title;
  final TsIconSpec? icon;
  final String? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              TsIcon(icon!, size: TsIconSize.sm, color: c.primary),
              const SizedBox(width: TsSpacing.sm),
            ],
            Expanded(
              child: Text(
                title,
                style: TsType.h3.copyWith(color: c.textPrimary),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: TsType.labelSMedium.copyWith(color: c.textTertiary),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: TsSpacing.xs),
          Text(
            subtitle!,
            style: TsType.labelSRegular.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}
