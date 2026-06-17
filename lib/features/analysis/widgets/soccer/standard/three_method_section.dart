import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class ThreeMethodData {
  const ThreeMethodData({
    required this.label,
    this.win,
    this.draw,
    this.lose,
  });

  final String label;
  final double? win;
  final double? draw;
  final double? lose;
}

class ThreeMethodAnalysisSection extends StatelessWidget {
  const ThreeMethodAnalysisSection({
    required this.methods,
    this.showTitle = true,
    super.key,
  });

  final List<ThreeMethodData> methods;
  final bool showTitle;

  double _normalizedRate(double? value) {
    if (value == null) return 0;
    if (value <= 1) return value;
    return value / 100;
  }

  String _pickLabel(AppLocalizations l10n, double win, double lose) {
    if (win >= lose) {
      return l10n.soccerHomeWinPct((win * 100).round());
    }
    return l10n.soccerAwayWinPct((lose * 100).round());
  }

  Widget _buildMethodBar(
    BuildContext context,
    ThreeMethodData method,
    TsSemanticColors semantic,
  ) {
    final win = _normalizedRate(method.win);
    final draw = _normalizedRate(method.draw);
    final lose = _normalizedRate(method.lose);
    final total = win + draw + lose;

    if (total <= 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                method.label,
                style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
              ),
              Text(
                '-',
                style: TsType.labelSBold.copyWith(color: semantic.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: 8,
              child: ColoredBox(color: semantic.surfaceContainer),
            ),
          ),
        ],
      );
    }

    final winFlex = math.max(1, (win / total * 100).round());
    final drawFlex = math.max(1, (draw / total * 100).round());
    final loseFlex = math.max(1, (lose / total * 100).round());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              method.label,
              style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            ),
            Text(
              _pickLabel(context.l10n, win, lose),
              style: TsType.labelSBold.copyWith(color: semantic.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: double.infinity,
            height: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: winFlex,
                  child: Container(
                    height: 8,
                    color: semantic.interactivePrimary,
                  ),
                ),
                Expanded(
                  flex: drawFlex,
                  child: Container(
                    height: 8,
                    color: semantic.textTertiary,
                  ),
                ),
                Expanded(
                  flex: loseFlex,
                  child: Container(
                    height: 8,
                    color: TsColors.systemError500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;

    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            l10n.soccerMethod3,
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
              for (var i = 0; i < methods.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.sm),
                _buildMethodBar(context, methods[i], semantic),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
