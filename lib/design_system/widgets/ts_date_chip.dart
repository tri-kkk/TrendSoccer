import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsDateChip extends StatelessWidget {
  const TsDateChip({
    required this.weekday,
    required this.day,
    this.selected = false,
    this.isToday = false,
    this.onTap,
    super.key,
  });

  final String weekday;
  final String day;
  final bool selected;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final weekdayStyle = TsType.labelXsMedium.copyWith(
      color: selected ? c.primary : c.textTertiary,
    );
    final dayStyle = TsType.tabular(
      (selected ? TsType.bodyLBold : TsType.bodyLMedium).copyWith(
        color: selected ? c.primary : c.textPrimary,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 56,
        padding: const EdgeInsets.all(TsSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? c.primaryMuted : null,
          borderRadius: TsRadius.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(weekday, style: weekdayStyle),
            const SizedBox(height: TsSpacing.xxs),
            Text(day, style: dayStyle),
            const SizedBox(height: TsSpacing.xxs),
            Container(
              width: TsSpacing.xs,
              height: TsSpacing.xs,
              decoration: BoxDecoration(
                color: isToday ? c.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
