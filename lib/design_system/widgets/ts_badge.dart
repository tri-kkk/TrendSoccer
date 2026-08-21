import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsBadgeTone { neutral, positive, negative, primary }

class TsBadge extends StatelessWidget {
  const TsBadge({
    required this.label,
    this.tone = TsBadgeTone.neutral,
    super.key,
  });

  final String label;
  final TsBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final Color background;
    final Color labelColor;
    switch (tone) {
      case TsBadgeTone.neutral:
        background = c.dataNeutralSubtle;
        labelColor = c.dataNeutral;
      case TsBadgeTone.positive:
        background = c.dataPositiveSubtle;
        labelColor = c.dataPositive;
      case TsBadgeTone.negative:
        background = c.dataNegativeSubtle;
        labelColor = c.dataNegative;
      case TsBadgeTone.primary:
        background = c.primaryMuted;
        labelColor = c.primary;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: TsRadius.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: TsSpacing.xxs,
          horizontal: TsSpacing.sm,
        ),
        child: Text(
          label,
          style: TsType.labelXsBold.copyWith(color: labelColor),
        ),
      ),
    );
  }
}
