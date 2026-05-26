import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/baseball_info_box.dart';
import 'package:trendsoccer/shared/widgets/baseball/premium/confidence_chip.dart';

class WinRateSection extends StatelessWidget {
  const WinRateSection({
    required this.awayWinRate,
    required this.homeWinRate,
    required this.confidence,
    this.awayTeam,
    this.homeTeam,
    super.key,
  });

  final String awayWinRate;
  final String homeWinRate;
  final ConfidenceLevel confidence;
  final String? awayTeam;
  final String? homeTeam;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '최근 10경기 승률',
              style: TsType.headingH2.copyWith(color: semantic.textPrimary),
            ),
            Text(
              '최근 10경기',
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ],
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: BaseballInfoBox(
                      label: '원정',
                      value: awayWinRate,
                      teamName: awayTeam,
                      valueColor: TsColors.systemError500,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: BaseballInfoBox(
                      label: '홈',
                      value: homeWinRate,
                      teamName: homeTeam,
                      valueColor: semantic.interactivePrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '신뢰도',
                    style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                  ),
                  ConfidenceChip(level: confidence),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
