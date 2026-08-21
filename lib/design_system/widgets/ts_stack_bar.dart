import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

enum TsStackLine { threeWay, twoWay }

class TsStackBar extends StatelessWidget {
  const TsStackBar({
    required this.home,
    this.draw = 0,
    required this.away,
    this.line = TsStackLine.threeWay,
    this.homeValue,
    this.drawValue,
    this.awayValue,
    this.homeLabel,
    this.drawLabel,
    this.awayLabel,
    this.showValues = true,
    this.showLabels = true,
    super.key,
  });

  final double home;
  final double draw;
  final double away;
  final TsStackLine line;
  final String? homeValue;
  final String? drawValue;
  final String? awayValue;
  final String? homeLabel;
  final String? drawLabel;
  final String? awayLabel;
  final bool showValues;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final homeFlex = (home.clamp(0.0, 1.0) * 1000).round().clamp(1, 1000);
    final drawFlex = (draw.clamp(0.0, 1.0) * 1000).round().clamp(1, 1000);
    final awayFlex = (away.clamp(0.0, 1.0) * 1000).round().clamp(1, 1000);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showValues) ...[
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    homeValue ?? '',
                    style: TsType.tabular(
                      TsType.h3.copyWith(color: c.dataPositive),
                    ),
                  ),
                ),
              ),
              if (line == TsStackLine.threeWay)
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      drawValue ?? '',
                      style: TsType.tabular(
                        TsType.h3.copyWith(color: c.dataNeutral),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    awayValue ?? '',
                    style: TsType.tabular(
                      TsType.h3.copyWith(color: c.dataNegative),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.xs),
        ],
        if (showLabels) ...[
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    homeLabel ?? 'Wins',
                    style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
                  ),
                ),
              ),
              if (line == TsStackLine.threeWay)
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      drawLabel ?? 'Draws',
                      style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
                    ),
                  ),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    awayLabel ?? 'Wins',
                    style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.xs),
        ],
        ClipRRect(
          borderRadius:
              line == TsStackLine.threeWay ? TsRadius.xs : TsRadius.full,
          child: SizedBox(
            height: line == TsStackLine.threeWay ? 4 : 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: homeFlex,
                  child: Container(
                    color: c.dataPositive,
                    child: const SizedBox.expand(),
                  ),
                ),
                if (line == TsStackLine.threeWay)
                  Expanded(
                    flex: drawFlex,
                    child: Container(
                      color: c.dataNeutral,
                      child: const SizedBox.expand(),
                    ),
                  ),
                Expanded(
                  flex: awayFlex,
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
