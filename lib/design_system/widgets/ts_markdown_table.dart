import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsMarkdownTable extends StatelessWidget {
  const TsMarkdownTable({
    required this.headers,
    required this.rows,
    super.key,
  });

  final (String, String) headers;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    Widget row(
      String first,
      String second, {
      required TextStyle firstStyle,
      required TextStyle secondStyle,
      bool topBorder = false,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(
          vertical: TsSpacing.xs,
          horizontal: TsSpacing.sm,
        ),
        decoration: topBorder
            ? BoxDecoration(
                border: Border(top: BorderSide(color: c.borderSubtle, width: 1)),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Text(first, style: firstStyle),
            ),
            Text(second, style: secondStyle),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: TsRadius.sm,
        border: Border.all(color: c.borderSubtle, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            headers.$1,
            headers.$2,
            firstStyle: TsType.bodyMBold.copyWith(color: c.textPrimary),
            secondStyle: TsType.bodyMBold.copyWith(color: c.textPrimary),
          ),
          for (final data in rows)
            row(
              data.$1,
              data.$2,
              firstStyle: TsType.bodyMMedium.copyWith(color: c.textSecondary),
              secondStyle: TsType.tabular(
                TsType.bodyMBold.copyWith(color: c.textPrimary),
              ),
              topBorder: true,
            ),
        ],
      ),
    );
  }
}
