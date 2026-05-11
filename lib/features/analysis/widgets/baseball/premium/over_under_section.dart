import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오버 / 언더',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg, vertical: TsSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0x33F59E0B),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '기준선 $baseLine',
                  style: TsType.bodyLRegular.copyWith(color: TsColors.systemWarning500),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: TsSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _UOBox(
                      label: '오버',
                      value: overOdds,
                      isFavored: !isFavoredUnder,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _UOBox(
                      label: '언더',
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
