import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';

class TsRadio extends StatelessWidget {
  const TsRadio({required this.selected, this.onTap, super.key});

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: TsSpacing.xl,
        height: TsSpacing.xl,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? c.primary : c.borderDefault,
            width: TsSpacing.xxs,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: TsSpacing.md,
                  height: TsSpacing.md,
                  decoration: BoxDecoration(
                    color: c.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
