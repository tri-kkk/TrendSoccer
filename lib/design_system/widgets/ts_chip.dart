import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsChipTone { defaultTone, live }

class TsChip extends StatelessWidget {
  const TsChip({
    required this.label,
    this.selected = false,
    this.tone = TsChipTone.defaultTone,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final TsChipTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final Color fill;
    final Color? stroke;
    final Color labelColor;

    switch ((tone, selected)) {
      case (TsChipTone.defaultTone, false):
        fill = c.surfaceRaised;
        stroke = null;
        labelColor = c.textSecondary;
      case (TsChipTone.defaultTone, true):
        fill = c.primaryMuted;
        stroke = c.primary;
        labelColor = c.primary;
      case (TsChipTone.live, false):
        fill = c.surfaceRaised;
        stroke = c.error;
        labelColor = c.error;
      case (TsChipTone.live, true):
        fill = c.error;
        stroke = null;
        labelColor = c.onPrimary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: TsRadius.full,
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: TsRadius.full,
            border: stroke != null ? Border.all(color: stroke, width: 1) : null,
          ),
          child: SizedBox(
            height: TsSpacing.xxl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.md),
              child: Center(
                child: Text(
                  label,
                  style: TsType.bodyMMedium.copyWith(color: labelColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
