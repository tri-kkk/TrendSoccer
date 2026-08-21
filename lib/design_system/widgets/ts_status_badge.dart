import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsMatchStatus { live, halfTime, finished, postponed, cancelled }

class TsStatusBadge extends StatelessWidget {
  const TsStatusBadge(this.status, {this.label, super.key});

  final TsMatchStatus status;
  final String? label;

  String get _defaultLabel => switch (status) {
        TsMatchStatus.live => 'LIVE',
        TsMatchStatus.halfTime => 'HT',
        TsMatchStatus.finished => 'FT',
        TsMatchStatus.postponed => 'PPD',
        TsMatchStatus.cancelled => 'CAN',
      };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final Color background;
    final Color labelColor;
    switch (status) {
      case TsMatchStatus.live:
        background = c.dataNegativeSubtle;
        labelColor = c.error;
      case TsMatchStatus.halfTime:
        background = c.dataNeutralSubtle;
        labelColor = c.dataNeutral;
      case TsMatchStatus.finished:
        background = c.dataNeutralSubtle;
        labelColor = c.textSecondary;
      case TsMatchStatus.postponed:
        background = c.dataNeutralSubtle;
        labelColor = c.warning;
      case TsMatchStatus.cancelled:
        background = c.dataNeutralSubtle;
        labelColor = c.textTertiary;
    }

    final text = label ?? _defaultLabel;
    final textWidget = Text(
      text,
      style: TsType.labelXsBold.copyWith(color: labelColor),
    );

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
        child: status == TsMatchStatus.live
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: c.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.xs),
                  textWidget,
                ],
              )
            : textWidget,
      ),
    );
  }
}
