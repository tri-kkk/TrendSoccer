import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum BaseballH2HWinner {
  home,
  away,
  draw,
}

class BaseballH2HMatch {
  const BaseballH2HMatch({
    required this.date,
    required this.awayTeam,
    required this.homeTeam,
    required this.score,
    required this.winner,
    this.awayTeamKo,
    this.homeTeamKo,
  });

  final String date;
  final String awayTeam;
  final String homeTeam;
  final String? awayTeamKo;
  final String? homeTeamKo;
  final String score;
  final BaseballH2HWinner winner;

  String get homeDisplayName {
    final ko = homeTeamKo?.trim();
    if (ko != null && ko.isNotEmpty) return ko;
    return homeTeam;
  }

  String get awayDisplayName {
    final ko = awayTeamKo?.trim();
    if (ko != null && ko.isNotEmpty) return ko;
    return awayTeam;
  }

  factory BaseballH2HMatch.fromParsed({
    required String date,
    required String homeTeam,
    required String awayTeam,
    required String score,
    required BaseballH2HWinner winner,
    String? homeTeamKo,
    String? awayTeamKo,
  }) {
    final homeKo = _normalizeOptionalKo(homeTeamKo);
    final awayKo = _normalizeOptionalKo(awayTeamKo);

    if ((homeKo == null || homeKo.isEmpty) && homeTeam.isNotEmpty) {
      debugPrint(
        '[BASEBALL] H2H WARNING: missing Ko for home "$homeTeam" on $date',
      );
    }
    if ((awayKo == null || awayKo.isEmpty) && awayTeam.isNotEmpty) {
      debugPrint(
        '[BASEBALL] H2H WARNING: missing Ko for away "$awayTeam" on $date',
      );
    }

    return BaseballH2HMatch(
      date: date,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamKo: homeKo,
      awayTeamKo: awayKo,
      score: score,
      winner: winner,
    );
  }

  static String? _normalizeOptionalKo(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  bool get awayWon => winner == BaseballH2HWinner.away;
  bool get homeWon => winner == BaseballH2HWinner.home;
  bool get isDraw => winner == BaseballH2HWinner.draw;

  String get scoreDisplay => score;
}

class BaseballH2HSection extends StatelessWidget {
  const BaseballH2HSection({
    required this.matches,
    this.isLoading = false,
    super.key,
  });

  final List<BaseballH2HMatch> matches;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'H2H',
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
          child: isLoading
              ? Text(
                  '상대 전적 데이터를 불러오는 중...',
                  style: TsType.bodyMRegular.copyWith(
                    color: semantic.textSecondary,
                  ),
                )
              : matches.isEmpty
              ? Text(
                  '상대 전적 데이터가 없습니다.',
                  style: TsType.bodyMRegular.copyWith(
                    color: semantic.textSecondary,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < matches.length; i++) ...[
                      _H2HMatchRow(match: matches[i]),
                      if (i < matches.length - 1) ...[
                        const SizedBox(height: TsSpacing.lg),
                        Container(height: 1, color: semantic.borderSubtle),
                        const SizedBox(height: TsSpacing.lg),
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
  required bool isHomeWinner,
}) {
  final semantic = Theme.of(context).extension<TsSemanticColors>()!;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: isHomeWinner ? const Color(0x3300DF81) : const Color(0x1AEF4444),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      'W',
      style: TsType.labelSRegular.copyWith(
        color: isHomeWinner
            ? semantic.interactivePrimary
            : TsColors.systemError500,
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

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              match.date,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            ),
          ),
          const SizedBox(width: TsSpacing.sm),
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
                          if (homeWon) ...[
                            _buildWinBadge(context, isHomeWinner: true),
                            const SizedBox(width: TsSpacing.sm),
                          ],
                          Expanded(
                            child: Text(
                              match.homeDisplayName,
                              style: labelStyle,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Text(
                      match.scoreDisplay,
                      style: labelStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: TsSpacing.sm),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              match.awayDisplayName,
                              style: labelStyle,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (awayWon) ...[
                            const SizedBox(width: TsSpacing.sm),
                            _buildWinBadge(context, isHomeWinner: false),
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
      ),
    );
  }
}
