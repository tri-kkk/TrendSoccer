import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';

class FinalProbabilitySection extends StatelessWidget {
  const FinalProbabilitySection({
    required this.homeProb,
    required this.drawProb,
    required this.awayProb,
    this.showTitle = true,
    super.key,
  });

  final double homeProb;
  final double drawProb;
  final double awayProb;
  final bool showTitle;

  static int _flexFromPercent(int percent) => percent < 1 ? 1 : percent;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final homePercent = (homeProb * 100).round();
    final drawPercent = (drawProb * 100).round();
    final awayPercent = (awayProb * 100).round();
    final homeFlex = _flexFromPercent(homePercent);
    final drawFlex = _flexFromPercent(drawPercent);
    final awayFlex = _flexFromPercent(awayPercent);

    final barTextStyle = TsType.headingH3.copyWith(
      color: semantic.interactiveOnPrimary,
    );
    final drawBarTextStyle = TsType.headingH3.copyWith(
      color: semantic.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            l10n.soccerFinalProbability,
            style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: TsSpacing.sm),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 32,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: homeFlex,
                      child: Container(
                        color: semantic.interactivePrimary,
                        alignment: Alignment.center,
                        child: Text(
                          '$homePercent%',
                          style: barTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: drawFlex,
                      child: Container(
                        color: semantic.surfaceContainer,
                        alignment: Alignment.center,
                        child: Text(
                          '$drawPercent%',
                          style: drawBarTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: awayFlex,
                      child: Container(
                        color: TsColors.systemError500,
                        alignment: Alignment.center,
                        child: Text(
                          '$awayPercent%',
                          style: barTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TsSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.labelHome,
                    style: TsType.labelSRegular.copyWith(
                      color: semantic.textTertiary,
                    ),
                  ),
                  Text(
                    l10n.soccerDraw,
                    style: TsType.labelSRegular.copyWith(
                      color: semantic.textTertiary,
                    ),
                  ),
                  Text(
                    l10n.labelAway,
                    style: TsType.labelSRegular.copyWith(
                      color: semantic.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
