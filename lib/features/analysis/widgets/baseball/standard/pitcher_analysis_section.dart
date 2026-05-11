import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class PitcherAnalysisSection extends StatelessWidget {
  const PitcherAnalysisSection({
    required this.analysisText,
    super.key,
  });

  final String analysisText;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '투수 분석',
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
          child: Text(
            analysisText,
            style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
          ),
        ),
      ],
    );
  }
}
