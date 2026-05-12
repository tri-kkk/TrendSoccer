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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Over / Under',
                  style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              const _OuTableHeaderRow(),
              const SizedBox(height: 16),
              for (var i = 0; i < overUnderLines.length; i++) ...[
                _OuLineRow(line: overUnderLines[i]),
                if (i < overUnderLines.length - 1) ...[
                  const SizedBox(height: 8),
                  Container(height: 1, color: semantic.borderSubtle),
                  const SizedBox(height: 8),
                ],
              ],
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

class _OuTableHeaderRow extends StatelessWidget {
  const _OuTableHeaderRow();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final primaryStyle = TsType.bodyLRegular.copyWith(color: semantic.textPrimary);
    final overStyle = TsType.headingH3.copyWith(color: TsColors.systemError500);
    final underStyle = TsType.headingH3.copyWith(color: semantic.interactivePrimary);
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text('기준', style: primaryStyle),
        ),
        Expanded(
          child: Text('오버', style: overStyle, textAlign: TextAlign.center),
        ),
        Expanded(
          child: Text('언더', style: underStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class _OuLineRow extends StatelessWidget {
  const _OuLineRow({required this.line});

  final BaseballOULine line;

  static const Color _baselineChipBg = Color(0x33F59E0B);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final lineLabelStyle = TsType.bodyLRegular.copyWith(color: semantic.textPrimary);
    final overStyle = TsType.headingH3.copyWith(color: TsColors.systemError500);
    final underStyle = TsType.headingH3.copyWith(color: semantic.interactivePrimary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Row(
            children: [
              Text(line.line, style: lineLabelStyle),
              if (line.isBaseLine) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _baselineChipBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '기준선',
                    style: TsType.bodyLRegular.copyWith(color: TsColors.systemWarning500),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Text(line.over, style: overStyle, textAlign: TextAlign.center),
        ),
        Expanded(
          child: Text(line.under, style: underStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
