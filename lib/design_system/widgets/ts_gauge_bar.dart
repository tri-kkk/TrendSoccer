import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsGaugeLine { threeWay, twoWay, oneWay }

class TsGaugeBar extends StatelessWidget {
  const TsGaugeBar({
    required this.home,
    this.draw = 0,
    this.away = 0,
    this.line = TsGaugeLine.threeWay,
    this.homeLabel,
    this.drawLabel,
    this.awayLabel,
    this.showValues = true,
    this.baseline,
    super.key,
  });

  final double home;
  final double draw;
  final double away;
  final TsGaugeLine line;
  final String? homeLabel;
  final String? drawLabel;
  final String? awayLabel;
  final bool showValues;
  final double? baseline;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final homeFlex = (home.clamp(0.0, 1.0) * 1000).round();
    final drawFlex = (draw.clamp(0.0, 1.0) * 1000).round();
    final awayFlex = (away.clamp(0.0, 1.0) * 1000).round();
    final remainderFlex = ((1 - home.clamp(0.0, 1.0)) * 1000).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showValues) ...[
          Row(
            children: [
              Expanded(
                flex: homeFlex.clamp(1, 1000),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    homeLabel ?? '',
                    style: TsType.tabular(
                      TsType.labelSBold.copyWith(color: c.dataPositive),
                    ),
                  ),
                ),
              ),
              if (line == TsGaugeLine.threeWay)
                Expanded(
                  flex: drawFlex.clamp(1, 1000),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      drawLabel ?? '',
                      style: TsType.tabular(
                        TsType.labelSBold.copyWith(color: c.dataNeutral),
                      ),
                    ),
                  ),
                ),
              if (line != TsGaugeLine.oneWay)
                Expanded(
                  flex: awayFlex.clamp(1, 1000),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      awayLabel ?? '',
                      style: TsType.tabular(
                        TsType.labelSBold.copyWith(color: c.dataNegative),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TsSpacing.xs),
        ],
        if (line == TsGaugeLine.oneWay)
          Stack(
            children: [
              ClipRRect(
                borderRadius: TsRadius.full,
                child: Container(
                  height: 10,
                  color: c.surfaceRaised,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: homeFlex.clamp(1, 1000),
                        child: Container(
                          color: c.dataPositive,
                          child: const SizedBox.expand(),
                        ),
                      ),
                      Expanded(
                        flex: remainderFlex.clamp(1, 1000),
                        child: const SizedBox.expand(),
                      ),
                    ],
                  ),
                ),
              ),
              if (baseline != null)
                Align(
                  alignment: Alignment(baseline!.clamp(0.0, 1.0) * 2 - 1, 0),
                  child: Container(
                    width: TsSpacing.xxs,
                    height: 10,
                    color: c.canvas,
                  ),
                ),
            ],
          )
        else
          ClipRRect(
            borderRadius: TsRadius.xs,
            child: Container(
              height: 4,
              color: c.surfaceRaised,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: homeFlex.clamp(1, 1000),
                    child: Container(
                      color: c.dataPositive,
                      child: const SizedBox.expand(),
                    ),
                  ),
                  if (line == TsGaugeLine.threeWay)
                    Expanded(
                      flex: drawFlex.clamp(1, 1000),
                      child: Container(
                        color: c.dataNeutral,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  Expanded(
                    flex: awayFlex.clamp(1, 1000),
                    child: Container(
                      color: c.dataNegative,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
