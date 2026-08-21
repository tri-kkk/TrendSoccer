import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_radio.dart';

class TsSheetOptionRow extends StatelessWidget {
  const TsSheetOptionRow({
    required this.label,
    required this.selected,
    this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: TsSpacing.xxxl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TsRadio(selected: selected),
            const SizedBox(width: TsSpacing.lg),
            Expanded(
              child: Text(
                label,
                style: (selected ? TsType.bodyLBold : TsType.bodyLRegular)
                    .copyWith(color: c.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
