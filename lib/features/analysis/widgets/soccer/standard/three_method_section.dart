import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/report/info_cell.dart';

class ThreeMethodSection extends StatelessWidget {
  const ThreeMethodSection({
    required this.paResult,
    required this.minMaxResult,
    required this.firstGoalResult,
    super.key,
  });

  final String paResult;
  final String minMaxResult;
  final String firstGoalResult;

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
          child: Row(
            children: [
              Expanded(
                child: InfoCell(value: paResult, label: 'P/A 분석'),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: InfoCell(value: minMaxResult, label: 'Min-Max'),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: InfoCell(
                  value: firstGoalResult,
                  label: '선제골',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
