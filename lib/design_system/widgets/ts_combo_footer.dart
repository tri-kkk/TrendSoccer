import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

enum TsComboOutcome { pending, hit, partial, miss }

class TsComboFooter extends StatelessWidget {
  const TsComboFooter({
    required this.totalIndexLabel,
    required this.confidenceLabel,
    this.outcome = TsComboOutcome.pending,
    this.outcomeLabel,
    this.showDivider = true,
    this.totalIndexCaption,
    this.confidenceCaption,
    this.resultCaption,
    super.key,
  });

  final String totalIndexLabel;
  final String confidenceLabel;
  final TsComboOutcome outcome;
  final String? outcomeLabel;
  final bool showDivider;
  final String? totalIndexCaption;
  final String? confidenceCaption;
  final String? resultCaption;

  String _defaultOutcomeLabel(AppLocalizations l10n) => switch (outcome) {
        TsComboOutcome.pending => l10n.comboStatusInProgress,
        TsComboOutcome.hit => l10n.comboMatchHit,
        TsComboOutcome.partial => l10n.comboStatusPartial,
        TsComboOutcome.miss => l10n.comboStatusMiss,
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
    final l10n = AppLocalizations.of(context)!;
    final resolvedTotalIndexCaption = totalIndexCaption ?? l10n.comboTotalOdds;
    final resolvedConfidenceCaption =
        confidenceCaption ?? l10n.comboFooterEstAccuracyCaption;
    final resolvedResultCaption = resultCaption ?? l10n.comboFooterResultCaption;

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
            cell(resolvedTotalIndexCaption, totalIndexLabel, c.dataPositive),
            cell(resolvedConfidenceCaption, confidenceLabel, c.textPrimary),
            cell(
              resolvedResultCaption,
              outcomeLabel ?? _defaultOutcomeLabel(l10n),
              _resultColor(c),
            ),
          ],
        ),
      ],
    );
  }
}
