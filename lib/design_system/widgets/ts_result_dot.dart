import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsResult { win, draw, loss }

class TsResultDot extends StatelessWidget {
  const TsResultDot(this.result, {this.label, super.key});

  final TsResult result;
  final String? label;

  String get _defaultLabel => switch (result) {
        TsResult.win => 'W',
        TsResult.draw => 'D',
        TsResult.loss => 'L',
      };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    final Color background = switch (result) {
      TsResult.win => c.dataPositive,
      TsResult.draw => c.dataNeutral,
      TsResult.loss => c.dataNegative,
    };

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: background,
        borderRadius: TsRadius.full,
      ),
      alignment: Alignment.center,
      child: Text(
        label ?? _defaultLabel,
        style: TsType.labelXsBold.copyWith(color: c.canvas),
      ),
    );
  }
}
