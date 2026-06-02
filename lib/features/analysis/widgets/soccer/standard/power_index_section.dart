import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/report/ratio_bar.dart';

class PowerIndexSection extends StatelessWidget {
  const PowerIndexSection({
    required this.homeRatio,
    required this.homePowerDisplay,
    required this.awayPowerDisplay,
    this.showTitle = true,
    super.key,
  });

  final double homeRatio;
  final String homePowerDisplay;
  final String awayPowerDisplay;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final awayRatio = (1.0 - homeRatio).clamp(0.0, 1.0);
    final hr = homeRatio.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            l10n.soccerPowerIndex,
            style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.sm),
        ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    homePowerDisplay,
                    style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                  ),
                  Text(
                    awayPowerDisplay,
                    style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.sm),
              RatioBar(
                segments: [
                  RatioSegment(
                    flex: hr,
                    color: semantic.interactivePrimary,
                    bottomLabel: l10n.soccerHomePower,
                  ),
                  RatioSegment(
                    flex: awayRatio,
                    color: TsColors.systemError500,
                    bottomLabel: l10n.soccerAwayPower,
                  ),
                ],
                height: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
