import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class BaseballH2HMatch {
  const BaseballH2HMatch({
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.homeWin,
  });

  final String date;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final bool homeWin;
}

class BaseballH2HSection extends StatelessWidget {
  const BaseballH2HSection({
    required this.matches,
    super.key,
  });

  final List<BaseballH2HMatch> matches;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상대 전적',
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
              for (var i = 0; i < matches.length; i++) ...[
                _H2HMatchRow(match: matches[i]),
                if (i < matches.length - 1) const SizedBox(height: TsSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _H2HMatchRow extends StatelessWidget {
  const _H2HMatchRow({required this.match});

  final BaseballH2HMatch match;

  static const Color _homeWinBg = Color(0x3300DF81);
  static const Color _awayWinBg = Color(0x33EF4444);

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final hw = match.homeWin;
    final scoreText = '${match.awayScore} : ${match.homeScore}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          match.date,
          style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  match.awayTeam,
                  style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: TsSpacing.sm),
              Text(
                scoreText,
                style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
              ),
              const SizedBox(width: TsSpacing.sm),
              Flexible(
                child: Text(
                  match.homeTeam,
                  style: TsType.bodyMBold.copyWith(color: semantic.textPrimary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: hw ? _homeWinBg : _awayWinBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            hw ? '홈' : '원정',
            style: TsType.labelSRegular.copyWith(
              color: hw ? semantic.interactivePrimary : TsColors.systemError500,
            ),
          ),
        ),
      ],
    );
  }
}
