import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';

class OverUnderSection extends StatelessWidget {
  const OverUnderSection({
    required this.baseLine,
    required this.overOdds,
    required this.underOdds,
    this.isFavoredUnder = true,
    super.key,
  });

  final String baseLine;
  final String overOdds;
  final String underOdds;
  final bool isFavoredUnder;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final baselineLabel = baseLine == '-' || baseLine.isEmpty
        ? l10n.baseballBaselineDash
        : l10n.baseballBaselineValue(baseLine);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.baseballOverUnder,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33F59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    baselineLabel,
                    style: TsType.bodyLRegular.copyWith(color: TsColors.systemWarning500),
                  ),
                ),
              ),
              const SizedBox(height: TsSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _UOBox(
                      label: l10n.labelOver,
                      value: overOdds,
                      isFavored: !isFavoredUnder,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _UOBox(
                      label: l10n.labelUnder,
                      value: underOdds,
                      isFavored: isFavoredUnder,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UOBox extends StatelessWidget {
  const _UOBox({
    required this.label,
    required this.value,
    required this.isFavored,
  });

  final String label;
  final String value;
  final bool isFavored;

  static const Color _favoredBg = Color(0x3300DF81);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: isFavored ? _favoredBg : semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: isFavored
            ? Border.all(color: semantic.interactivePrimary, width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            value,
            style: TsType.headingH1.copyWith(
              color: isFavored ? semantic.interactivePrimary : semantic.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
