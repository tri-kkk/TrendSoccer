import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsSegmentTabs extends StatelessWidget {
  const TsSegmentTabs({
    required this.labels,
    required this.activeIndex,
    required this.onTap,
    super.key,
  }) : assert(labels.length == 2 || labels.length == 3);

  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: c.canvas,
        border: Border(bottom: BorderSide(color: c.borderSubtle, width: 1)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          labels[i],
                          style: (i == activeIndex
                                  ? TsType.bodyLBold
                                  : TsType.bodyLMedium)
                              .copyWith(
                            color: i == activeIndex
                                ? c.textPrimary
                                : c.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: TsSpacing.xxs,
                      color: i == activeIndex ? c.primary : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
