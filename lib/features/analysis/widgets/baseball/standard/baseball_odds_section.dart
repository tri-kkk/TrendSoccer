import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class BaseballOULine {
  const BaseballOULine({
    required this.line,
    required this.over,
    required this.under,
    required this.isBaseLine,
  });

  final String line;
  final String over;
  final String under;
  final bool isBaseLine;
}

class BaseballOddsSection extends StatelessWidget {
  const BaseballOddsSection({
    required this.awayOdds,
    required this.homeOdds,
    required this.awayTeam,
    required this.homeTeam,
    required this.overUnderLines,
    super.key,
  });

  final String awayOdds;
  final String homeOdds;
  final String awayTeam;
  final String homeTeam;
  final List<BaseballOULine> overUnderLines;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '배당',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _OddsBox(
                      team: awayTeam,
                      odds: awayOdds,
                      isHome: false,
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: _OddsBox(
                      team: homeTeam,
                      odds: homeOdds,
                      isHome: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.lg),
              Divider(height: 1, thickness: 1, color: semantic.borderSubtle),
              const SizedBox(height: TsSpacing.lg),
              const _LineHeaderRow(),
              for (final line in overUnderLines) _LineRow(line: line),
            ],
          ),
        ),
      ],
    );
  }
}

class _OddsBox extends StatelessWidget {
  const _OddsBox({
    required this.team,
    required this.odds,
    required this.isHome,
  });

  final String team;
  final String odds;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            team,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.xs),
          Text(
            odds,
            style: TsType.headingH2.copyWith(
              color: isHome ? semantic.interactivePrimary : TsColors.systemError500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LineHeaderRow extends StatelessWidget {
  const _LineHeaderRow();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final style = TsType.labelSRegular.copyWith(color: semantic.textTertiary);
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.md),
        child: Row(
          children: [
            Expanded(child: Text('Line', style: style)),
            Expanded(
              child: Text('Over', style: style, textAlign: TextAlign.center),
            ),
            Expanded(
              child: Text('Under', style: style, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final BaseballOULine line;

  static const Color _baselineBg = Color(0x1A00DF81);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.md),
      decoration: BoxDecoration(
        color: line.isBaseLine ? _baselineBg : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.line,
              style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
            ),
          ),
          Expanded(
            child: Text(
              line.over,
              style: TsType.bodyMRegular.copyWith(color: semantic.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              line.under,
              style: TsType.bodyMRegular.copyWith(color: semantic.textPrimary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
