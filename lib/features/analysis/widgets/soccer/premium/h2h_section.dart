import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/premium/card_section_title.dart';
import 'package:trendsoccer/shared/widgets/premium/circle_badge.dart';
import 'package:trendsoccer/shared/widgets/premium/score_box.dart';
import 'package:trendsoccer/shared/widgets/report/ratio_bar.dart';

class H2HMatchData {
  const H2HMatchData({
    required this.result,
    required this.score,
    this.homeLogoUrl,
    this.awayLogoUrl,
  });

  final MatchResult result;
  final String score;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
}

MatchResult _oppositeResult(MatchResult r) {
  switch (r) {
    case MatchResult.win:
      return MatchResult.lose;
    case MatchResult.lose:
      return MatchResult.win;
    case MatchResult.draw:
      return MatchResult.draw;
  }
}

String _flippedScore(String score) {
  final idx = score.indexOf('-');
  if (idx == -1) return score;
  final left = score.substring(0, idx).trim();
  final right = score.substring(idx + 1).trim();
  return '$right-$left';
}

class H2HSection extends StatefulWidget {
  const H2HSection({
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    required this.recentMatches,
    super.key,
  });

  final int homeWins;
  final int draws;
  final int awayWins;
  final List<H2HMatchData> recentMatches;

  @override
  State<H2HSection> createState() => _H2HSectionState();
}

class _H2HSectionState extends State<H2HSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardSectionTitle(
          title: '상대 전적',
          isExpanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded) ...[
          const SizedBox(height: TsSpacing.lg),
          Container(
            padding: const EdgeInsets.all(TsSpacing.lg),
            decoration: BoxDecoration(
              color: semantic.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleBadge(result: MatchResult.win, count: widget.homeWins),
                    CircleBadge(result: MatchResult.draw, count: widget.draws),
                    CircleBadge(result: MatchResult.lose, count: widget.awayWins),
                  ],
                ),
                const SizedBox(height: TsSpacing.lg),
                RatioBar(
                  segments: [
                    RatioSegment(
                      flex: widget.homeWins.toDouble(),
                      color: semantic.interactivePrimary,
                      bottomLabel: '홈',
                    ),
                    RatioSegment(
                      flex: widget.draws.toDouble(),
                      color: semantic.textTertiary,
                      bottomLabel: '무승부',
                    ),
                    RatioSegment(
                      flex: widget.awayWins.toDouble(),
                      color: TsColors.systemError500,
                      bottomLabel: '원정',
                    ),
                  ],
                  height: 8,
                ),
                const SizedBox(height: TsSpacing.lg),
                Column(
                  children: [
                    for (var i = 0; i < widget.recentMatches.length; i++) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ScoreBox(
                            result: widget.recentMatches[i].result,
                            score: widget.recentMatches[i].score,
                            teamLogoUrl: widget.recentMatches[i].homeLogoUrl,
                          ),
                          ScoreBox(
                            result: _oppositeResult(widget.recentMatches[i].result),
                            score: _flippedScore(widget.recentMatches[i].score),
                            teamLogoUrl: widget.recentMatches[i].awayLogoUrl,
                          ),
                        ],
                      ),
                      if (i < widget.recentMatches.length - 1)
                        const SizedBox(height: TsSpacing.sm),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
