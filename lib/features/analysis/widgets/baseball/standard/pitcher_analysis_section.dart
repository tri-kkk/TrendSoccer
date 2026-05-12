import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class PitcherAnalysisSection extends StatelessWidget {
  const PitcherAnalysisSection({
    required this.paragraphs,
    super.key,
  });

  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final bodyStyle = TsType.bodyMRegular.copyWith(color: semantic.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '투수 분석',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < paragraphs.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                Text(paragraphs[i], style: bodyStyle),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
