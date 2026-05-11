import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/report/ratio_bar.dart';

class PowerIndexSection extends StatelessWidget {
  const PowerIndexSection({required this.homeRatio, super.key});

  final double homeRatio;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final awayRatio = (1.0 - homeRatio).clamp(0.0, 1.0);
    final hr = homeRatio.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '파워 인덱스',
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
                flex: hr,
                color: semantic.interactivePrimary,
                bottomLabel: '홈 파워',
              ),
              RatioSegment(
                flex: awayRatio,
                color: TsColors.systemError500,
                bottomLabel: '원정 파워',
              ),
            ],
            height: 8,
          ),
        ),
      ],
    );
  }
}
