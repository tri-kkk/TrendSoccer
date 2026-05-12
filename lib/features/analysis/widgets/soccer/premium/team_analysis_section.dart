import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/premium/h2h_section.dart';
import 'package:trendsoccer/shared/widgets/premium/circle_badge.dart';
import 'package:trendsoccer/shared/widgets/premium/insights_card.dart';
import 'package:trendsoccer/shared/widgets/premium/score_box.dart';
import 'package:trendsoccer/shared/widgets/premium/section_title.dart';
import 'package:trendsoccer/shared/widgets/premium/stats_card.dart';

class TeamAnalysisSection extends StatefulWidget {
  const TeamAnalysisSection({
    required this.title,
    required this.last10Label,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.recentForm,
    required this.recordWins,
    required this.recordDraws,
    required this.recordLosses,
    required this.winRate,
    required this.goalLineO15,
    required this.goalLineO15Highlight,
    required this.goalLineO25,
    required this.goalLineO25Highlight,
    required this.goalLineO35,
    this.goalLineO35Highlight = false,
    required this.marketO25,
    required this.marketO25Highlight,
    required this.marketBtts,
    required this.marketBttsHighlight,
    required this.marketCs,
    required this.marketFts,
    required this.teamInsights,
    super.key,
  });

  final String title;
  final String last10Label;
  final int wins;
  final int draws;
  final int losses;
  final List<H2HMeeting> recentForm;
  final String recordWins;
  final String recordDraws;
  final String recordLosses;
  final String winRate;
  final String goalLineO15;
  final bool goalLineO15Highlight;
  final String goalLineO25;
  final bool goalLineO25Highlight;
  final String goalLineO35;
  final bool goalLineO35Highlight;
  final String marketO25;
  final bool marketO25Highlight;
  final String marketBtts;
  final bool marketBttsHighlight;
  final String marketCs;
  final String marketFts;
  final List<String> teamInsights;

  @override
  State<TeamAnalysisSection> createState() => _TeamAnalysisSectionState();
}

class _TeamAnalysisSectionState extends State<TeamAnalysisSection> {
  bool _isExpanded = false;

  Widget _buildScoreBoxRow(TsSemanticColors semantic) {
    final meetings = widget.recentForm;
    return Row(
      children: [
        for (var i = 0; i < meetings.length; i++) ...[
          Expanded(
            child: ScoreBox(
              score: meetings[i].score,
              result: meetings[i].result,
            ),
          ),
          if (i < meetings.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: semantic.textTertiary,
              ),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final w = widget;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CardSectionTitle(
            title: w.title,
            isExpanded: _isExpanded,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: semantic.surfaceOverlay,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '최근 10경기',
                      style: TsType.bodyLRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleBadge(
                        label: '승',
                        value: '${w.wins}',
                        type: CircleBadgeType.win,
                      ),
                      const SizedBox(width: 48),
                      CircleBadge(
                        label: '무',
                        value: '${w.draws}',
                        type: CircleBadgeType.draw,
                      ),
                      const SizedBox(width: 48),
                      CircleBadge(
                        label: '패',
                        value: '${w.losses}',
                        type: CircleBadgeType.lose,
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '최근 폼',
                      style: TsType.bodyLRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  _buildScoreBoxRow(semantic),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      w.last10Label,
                      style: TsType.bodyLRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(value: w.recordWins, label: '승'),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.recordDraws, label: '무'),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.recordLosses, label: '패'),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.winRate, label: '승률'),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '골 라인',
                      style: TsType.bodyLRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          value: w.goalLineO15,
                          label: 'O 1.5',
                          isHighlight: w.goalLineO15Highlight,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.lg),
                      Expanded(
                        child: StatsCard(
                          value: w.goalLineO25,
                          label: 'O 2.5',
                          isHighlight: w.goalLineO25Highlight,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.lg),
                      Expanded(
                        child: StatsCard(
                          value: w.goalLineO35,
                          label: 'O 3.5',
                          isHighlight: w.goalLineO35Highlight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '마켓 지표 (최근 10경기)',
                      style: TsType.bodyLRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          value: w.marketO25,
                          label: 'O 2.5',
                          isHighlight: w.marketO25Highlight,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(
                          value: w.marketBtts,
                          label: 'BTTS',
                          isHighlight: w.marketBttsHighlight,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.marketCs, label: 'CS'),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.marketFts, label: 'FTS'),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      '팀 인사이트',
                      style: TsType.bodyLRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  InsightsCard(comments: w.teamInsights),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
