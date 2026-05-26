import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/baseball_info_box.dart';

class WinProbabilitySection extends StatelessWidget {
  const WinProbabilitySection({
    required this.awayProb,
    required this.homeProb,
    required this.awayTeam,
    required this.homeTeam,
    required this.description,
    super.key,
  });

  final String awayProb;
  final String homeProb;
  final String awayTeam;
  final String homeTeam;
  final String description;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '승리 확률',
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
              Row(
                children: [
                  Expanded(
                    child: BaseballInfoBox(
                      label: '원정',
                      value: awayProb,
                      valueColor: TsColors.systemError500,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: BaseballInfoBox(
                      label: '홈',
                      value: homeProb,
                      valueColor: semantic.interactivePrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Text(
                description,
                style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
