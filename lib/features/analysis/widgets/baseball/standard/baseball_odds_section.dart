import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';

class BaseballOULine {
  const BaseballOULine({
    required this.line,
    required this.over,
    required this.under,
    required this.isBaseLine,
  });

  final String line;
  final String over;
  final String under;
  final bool isBaseLine;
}

class BaseballOddsSection extends StatelessWidget {
  const BaseballOddsSection({
    required this.awayOdds,
    required this.homeOdds,
    required this.overUnderLines,
    super.key,
  });

  final String awayOdds;
  final String homeOdds;
  final List<BaseballOULine> overUnderLines;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.labelOdds,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _OddsBox(
                      label: l10n.labelHome,
                      odds: homeOdds,
                      isHome: true,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  SizedBox(
                    width: 170,
                    child: _OddsBox(
                      label: l10n.labelAway,
                      odds: awayOdds,
                      isHome: false,
                    ),
                  ),
                ],
              ),
              if (overUnderLines.isNotEmpty) ...[
                const SizedBox(height: TsSpacing.lg),
                Text(
                  l10n.baseballOverUnder,
                  style: TsType.bodyLRegular.copyWith(
                    color: semantic.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TsSpacing.lg),
                const _OuTableHeaderRow(),
                const SizedBox(height: TsSpacing.lg),
                Column(
                  children: [
                    for (var i = 0; i < overUnderLines.length; i++) ...[
                      _OuLineRow(line: overUnderLines[i]),
                      if (i < overUnderLines.length - 1) ...[
                        const SizedBox(height: TsSpacing.sm),
                        Container(height: 1, color: semantic.borderSubtle),
                        const SizedBox(height: TsSpacing.sm),
                      ],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OddsBox extends StatelessWidget {
  const _OddsBox({
    required this.label,
    required this.odds,
    required this.isHome,
  });

  final String label;
  final String odds;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.xs),
          Text(
            odds,
            style: TsType.headingH1.copyWith(
              color: isHome ? semantic.interactivePrimary : TsColors.systemError500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OuTableHeaderRow extends StatelessWidget {
  const _OuTableHeaderRow();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final primaryStyle = TsType.bodyLRegular.copyWith(color: semantic.textPrimary);
    final overStyle = TsType.headingH3.copyWith(color: TsColors.systemError500);
    final underStyle =
        TsType.headingH3.copyWith(color: semantic.interactivePrimary);
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(l10n.baseballOddsBaseline, style: primaryStyle),
        ),
        Expanded(
          child: Text(l10n.labelOver, style: overStyle, textAlign: TextAlign.center),
        ),
        Text(l10n.labelUnder, style: underStyle, textAlign: TextAlign.right),
      ],
    );
  }
}

class _OuLineRow extends StatelessWidget {
  const _OuLineRow({required this.line});

  final BaseballOULine line;

  static final Color _baselineChipBg =
      TsColors.systemWarning500.withValues(alpha: 0.2);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final lineLabelStyle = TsType.bodyLRegular.copyWith(color: semantic.textPrimary);
    final overStyle = TsType.headingH3.copyWith(color: TsColors.systemError500);
    final underStyle =
        TsType.headingH3.copyWith(color: semantic.interactivePrimary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Row(
            children: [
              Text(line.line, style: lineLabelStyle),
              if (line.isBaseLine) ...[
                const SizedBox(width: TsSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _baselineChipBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.baseballOddsBaseline,
                    style: TsType.labelSRegular.copyWith(
                      color: TsColors.systemWarning500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Text(line.over, style: overStyle, textAlign: TextAlign.center),
        ),
        Text(line.under, style: underStyle, textAlign: TextAlign.right),
      ],
    );
  }
}
