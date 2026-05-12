import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum BaseballH2HWinner {
  away,
  home,
}

class BaseballH2HMatch {
  const BaseballH2HMatch({
    required this.date,
    required this.awayTeam,
    required this.homeTeam,
    required this.score,
    required this.winner,
  });

  final String date;
  final String awayTeam;
  final String homeTeam;
  final String score;
  final BaseballH2HWinner winner;

  bool get awayWon => winner == BaseballH2HWinner.away;
  bool get homeWon => winner == BaseballH2HWinner.home;
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
                if (i < matches.length - 1) ...[
                  const SizedBox(height: 16),
                  Container(height: 1, color: semantic.borderSubtle),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Widget _buildWinBadge(
  BuildContext context, {
  required bool isHomeWin,
}) {
  final semantic = Theme.of(context).extension<TsSemanticColors>()!;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: isHomeWin ? const Color(0x1AEF4444) : const Color(0x3300DF81),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      'W',
      style: TsType.labelSRegular.copyWith(
        color: isHomeWin ? TsColors.systemError500 : semantic.interactivePrimary,
      ),
    ),
  );
}

class _H2HMatchRow extends StatelessWidget {
  const _H2HMatchRow({required this.match});

  final BaseballH2HMatch match;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final awayWon = match.awayWon;
    final homeWon = match.homeWon;
    final labelStyle = TsType.labelSRegular.copyWith(color: semantic.textPrimary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            match.date,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            child: SizedBox(
              width: 300,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (awayWon) ...[
                          _buildWinBadge(context, isHomeWin: false),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            match.awayTeam,
                            style: labelStyle,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    match.score,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            match.homeTeam,
                            style: labelStyle,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (homeWon) ...[
                          const SizedBox(width: 8),
                          _buildWinBadge(context, isHomeWin: true),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
