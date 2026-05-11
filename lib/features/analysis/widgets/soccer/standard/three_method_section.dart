import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class ThreeMethodAnalysisSection extends StatelessWidget {
  const ThreeMethodAnalysisSection({
    super.key,
    this.paLabel = 'P/A비교',
    required this.paPercent,
    required this.paHomeRatio,
    this.minMaxLabel = 'MIN-MAX 비교',
    required this.minMaxPercent,
    required this.minMaxHomeRatio,
    this.firstGoalLabel = '선제골',
    required this.firstGoalPercent,
    required this.firstGoalHomeRatio,
  });

  final String paLabel;
  final String paPercent;
  final double paHomeRatio;

  final String minMaxLabel;
  final String minMaxPercent;
  final double minMaxHomeRatio;

  final String firstGoalLabel;
  final String firstGoalPercent;
  final double firstGoalHomeRatio;

  Widget _buildMethodRow(
    String label,
    String percent,
    double homeRatio,
    TsSemanticColors semantic,
  ) {
    final homeFlex = (homeRatio * 100).round().clamp(1, 99);
    final awayFlex = ((1 - homeRatio) * 100).round().clamp(1, 99);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            Text(
              percent,
              style: TsType.labelSRegular.copyWith(color: semantic.textPrimary),
            ),
          ],
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
                  flex: homeFlex,
                  child: Container(color: semantic.interactivePrimary),
                ),
                Expanded(
                  flex: awayFlex,
                  child: Container(color: TsColors.systemError500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3-Method 분석',
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
            children: [
              _buildMethodRow(paLabel, paPercent, paHomeRatio, semantic),
              const SizedBox(height: TsSpacing.sm),
              _buildMethodRow(
                minMaxLabel,
                minMaxPercent,
                minMaxHomeRatio,
                semantic,
              ),
              const SizedBox(height: TsSpacing.sm),
              _buildMethodRow(
                firstGoalLabel,
                firstGoalPercent,
                firstGoalHomeRatio,
                semantic,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
