import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsComboOutcome { pending, hit, partial, miss }

class TsComboFooter extends StatelessWidget {
  const TsComboFooter({
    required this.totalIndexLabel,
    required this.confidenceLabel,
    this.outcome = TsComboOutcome.pending,
    this.outcomeLabel,
    this.showDivider = true,
    this.totalIndexCaption = 'Total index',
    this.confidenceCaption = 'Est. accuracy',
    this.resultCaption = 'Result',
    super.key,
  });

  final String totalIndexLabel;
  final String confidenceLabel;
  final TsComboOutcome outcome;
  final String? outcomeLabel;
  final bool showDivider;
  final String totalIndexCaption;
  final String confidenceCaption;
  final String resultCaption;

  String get _defaultOutcomeLabel => switch (outcome) {
        TsComboOutcome.pending => 'In progress',
        TsComboOutcome.hit => 'Match',
        TsComboOutcome.partial => 'Partial',
        TsComboOutcome.miss => 'Mismatch',
      };

  Color _resultColor(TsThemeColors c) => switch (outcome) {
        TsComboOutcome.pending => c.dataNeutral,
        TsComboOutcome.hit => c.dataPositive,
        TsComboOutcome.partial => c.dataNeutral,
        TsComboOutcome.miss => c.dataNegative,
      };

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    Widget cell(String caption, String value, Color valueColor) {
      return Expanded(
        child: Column(
          children: [
            Text(
              caption,
              style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TsSpacing.xs),
            Text(
              value,
              style: TsType.tabular(
                TsType.h3.copyWith(color: valueColor),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDivider) Container(height: 1, color: c.borderSubtle),
        if (showDivider) const SizedBox(height: TsSpacing.md),
        Row(
          children: [
            cell(totalIndexCaption, totalIndexLabel, c.dataPositive),
            cell(confidenceCaption, confidenceLabel, c.textPrimary),
            cell(
              resultCaption,
              outcomeLabel ?? _defaultOutcomeLabel,
              _resultColor(c),
            ),
          ],
        ),
      ],
    );
  }
}
