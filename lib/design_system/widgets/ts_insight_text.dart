import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icon_spec.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsInsightTone { strength, weakness, confirmed }

class TsInsightText extends StatelessWidget {
  const TsInsightText({
    required this.text,
    this.tone = TsInsightTone.strength,
    super.key,
  });

  final String text;
  final TsInsightTone tone;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final TsIconSpec icon;
    final Color iconColor;
    switch (tone) {
      case TsInsightTone.strength:
        icon = TsIcons.trendingUp;
        iconColor = c.dataPositive;
      case TsInsightTone.weakness:
        icon = TsIcons.trendingDown;
        iconColor = c.dataNegative;
      case TsInsightTone.confirmed:
        icon = TsIcons.checkCircleOutline;
        iconColor = c.dataPositive;
    }

    return Container(
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: TsRadius.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TsIcon(icon, size: TsIconSize.sm, color: iconColor),
          const SizedBox(width: TsSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TsType.bodyMRegular.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
