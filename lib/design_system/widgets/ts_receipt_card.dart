import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsReceiptCard extends StatelessWidget {
  const TsReceiptCard({required this.rows, super.key});

  final List<(String label, String value)> rows;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: TsSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rows[i].$1,
                    style: TsType.bodyLMedium.copyWith(color: c.textTertiary),
                  ),
                ),
                Text(
                  rows[i].$2,
                  style: TsType.tabular(
                    TsType.bodyLBold.copyWith(color: c.textPrimary),
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
