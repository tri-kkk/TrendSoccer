import 'package:flutter/material.dart';

import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsResult { win, draw, loss }

class TsResultDot extends StatelessWidget {
  const TsResultDot(this.result, {this.label, super.key});

  final TsResult result;
  final String? label;

  String _defaultLabel(AppLocalizations l10n) => switch (result) {
        TsResult.win => l10n.labelWinShort,
        TsResult.draw => l10n.labelDrawShort,
        TsResult.loss => l10n.resultDotLoss,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        label ?? _defaultLabel(l10n),
        style: TsType.labelXsBold.copyWith(color: c.canvas),
      ),
    );
  }
}
