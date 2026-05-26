import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/premium/circle_badge.dart';
import 'package:trendsoccer/shared/widgets/premium/insights_card.dart';
import 'package:trendsoccer/shared/widgets/premium/score_box.dart';
import 'package:trendsoccer/shared/widgets/premium/section_title.dart';
import 'package:trendsoccer/shared/widgets/premium/stats_card.dart';

class H2HMeeting {
  const H2HMeeting({
    required this.score,
    required this.result,
  });

  final String score;
  final ScoreBoxResult result;
}

class MostCommonScore {
  const MostCommonScore({
    required this.count,
    required this.score,
  });

  final int count;
  final String score;
}

class H2HSection extends StatefulWidget {
  const H2HSection({
    required this.totalMatches,
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    required this.recentMeetings,
    required this.avgGoals,
    required this.over25,
    required this.over25Highlight,
    required this.btts,
    required this.mostCommonScores,
    required this.insights,
    this.collapsible = true,
    this.initialExpanded = false,
    this.headerTitle = 'H2H',
    this.homeTeamLogo,
    this.awayTeamLogo,
    super.key,
  });

  final int totalMatches;
  final int homeWins;
  final int draws;
  final int awayWins;
  final List<H2HMeeting> recentMeetings;
  final String avgGoals;
  final String over25;
  final bool over25Highlight;
  final String btts;
  final List<MostCommonScore> mostCommonScores;
  final List<String> insights;
  final bool collapsible;
  final bool initialExpanded;
  final String headerTitle;
  final String? homeTeamLogo;
  final String? awayTeamLogo;

  @override
  State<H2HSection> createState() => _H2HSectionState();
}

class _H2HSectionState extends State<H2HSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.collapsible ? widget.initialExpanded : true;
  }

  @override
  void didUpdateWidget(covariant H2HSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.collapsible) {
      _isExpanded = true;
    }
  }

  Widget _buildScoreBoxRow(TsSemanticColors semantic) {
    final meetings = widget.recentMeetings;
    return Row(
      children: [
        for (var i = 0; i < meetings.length; i++) ...[
          Expanded(
            child: ScoreBox(
              score: meetings[i].score,
              result: meetings[i].result,
              homeTeamLogo: widget.homeTeamLogo,
              awayTeamLogo: widget.awayTeamLogo,
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

  Widget _buildInnerContent(TsSemanticColors semantic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: semantic.surfaceOverlay,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              '역대 전적',
              style: TsType.bodyLRegular.copyWith(
                color: semantic.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: TsSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: Text(
              '(${widget.totalMatches} Matches)',
              style: TsType.labelSRegular.copyWith(
                color: semantic.textTertiary,
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
                value: '${widget.homeWins}',
                type: CircleBadgeType.win,
              ),
              const SizedBox(width: 48),
              CircleBadge(
                label: '무',
                value: '${widget.draws}',
                type: CircleBadgeType.draw,
              ),
              const SizedBox(width: 48),
              CircleBadge(
                label: '패',
                value: '${widget.awayWins}',
                type: CircleBadgeType.lose,
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: Text(
              '최근 맞대결',
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
              '통계',
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
                  value: widget.avgGoals,
                  label: '평균 득점',
                ),
              ),
              const SizedBox(width: TsSpacing.lg),
              Expanded(
                child: StatsCard(
                  value: widget.over25,
                  label: 'O 2.5',
                  isHighlight: widget.over25Highlight,
                ),
              ),
              const SizedBox(width: TsSpacing.lg),
              Expanded(
                child: StatsCard(
                  value: widget.btts,
                  label: 'BTTS',
                ),
              ),
            ],
          ),
          if (widget.mostCommonScores.isNotEmpty) ...[
            const SizedBox(height: TsSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: Text(
                '최대 스코어',
                style: TsType.bodyLRegular.copyWith(
                  color: semantic.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: TsSpacing.lg),
            Row(
              children: [
                for (var i = 0; i < widget.mostCommonScores.length; i++) ...[
                  if (i > 0) const SizedBox(width: TsSpacing.lg),
                  Expanded(
                    child: StatsCard(
                      value: '${widget.mostCommonScores[i].count}',
                      label: widget.mostCommonScores[i].score,
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: TsSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: Text(
              '매치 인사이트',
              style: TsType.bodyLRegular.copyWith(
                color: semantic.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: TsSpacing.lg),
          InsightsCard(comments: widget.insights),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final inner = _buildInnerContent(semantic);

    if (!widget.collapsible) {
      return inner;
    }

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
            title: widget.headerTitle,
            isExpanded: _isExpanded,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const SizedBox(height: 12),
                inner,
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
