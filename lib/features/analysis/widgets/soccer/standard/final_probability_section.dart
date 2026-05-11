import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/report/ratio_bar.dart';

class FinalProbabilitySection extends StatelessWidget {
  const FinalProbabilitySection({
    required this.homeProb,
    required this.drawProb,
    required this.awayProb,
    required this.homeProbLabel,
    required this.drawProbLabel,
    required this.awayProbLabel,
    super.key,
  });

  final double homeProb;
  final double drawProb;
  final double awayProb;
  final String homeProbLabel;
  final String drawProbLabel;
  final String awayProbLabel;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최종 예측 확률',
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
          child: RatioBar(
            segments: [
              RatioSegment(
                flex: homeProb,
                color: semantic.interactivePrimary,
                label: '홈 승률 $homeProbLabel',
                bottomLabel: '홈',
              ),
              RatioSegment(
                flex: drawProb,
                color: semantic.surfaceContainer,
                label: '무승부 $drawProbLabel',
                bottomLabel: '무승부',
              ),
              RatioSegment(
                flex: awayProb,
                color: TsColors.systemError500,
                label: '원정 승률 $awayProbLabel',
                bottomLabel: '원정',
              ),
            ],
            height: 32,
          ),
        ),
      ],
    );
  }
}
