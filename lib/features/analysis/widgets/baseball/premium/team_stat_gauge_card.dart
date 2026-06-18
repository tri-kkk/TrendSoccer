import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class GaugeData {
  const GaugeData({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    required this.homeRatio,
  });

  final String label;
  final String homeValue;
  final String awayValue;
  final double homeRatio;
}

/// Label + ratio bar + home / away values (tertiary) — Premium baseball (Figma).
class TeamStatGaugeCard extends StatelessWidget {
  const TeamStatGaugeCard({required this.data, super.key});

  final GaugeData data;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final hr = data.homeRatio.clamp(0.0, 1.0);
    final tertiaryStyle = TsType.labelSRegular.copyWith(color: semantic.textTertiary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.xs),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label,
            style: tertiaryStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    flex: (hr * 100).round().clamp(1, 99),
                    child: Container(color: semantic.interactivePrimary),
                  ),
                  Expanded(
                    flex: ((1.0 - hr) * 100).round().clamp(1, 99),
                    child: Container(color: TsColors.systemError500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TsSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.homeValue,
                  style: tertiaryStyle,
                ),
                Text(
                  data.awayValue,
                  style: tertiaryStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
