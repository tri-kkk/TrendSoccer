import 'package:flutter/material.dart';

import '../../../core/models/premium_models.dart';
import '../../../core/theme/tokens/color_tokens.dart';
import '../../../core/theme/tokens/typography_tokens.dart';
import '../../../shared/widgets/premium/circle_badge.dart';
import '../../../shared/widgets/premium/highlight_stats_card.dart';
import '../../../shared/widgets/premium/insights_card.dart';
import '../../../shared/widgets/premium/score_box.dart';
import '../../../shared/widgets/premium/section_title.dart';
import '../../../shared/widgets/premium/stats_card.dart';

/// Head-to-Head section card for the premium analysis tab.
///
/// ```dart
/// H2HSection(
///   homeWins: 10, draws: 5, awayWins: 5,
///   totalMatches: 20,
///   recentScores: [...],
///   avgGoals: 2.7,
///   over25Percent: 60,
///   bttsPercent: 30,
///   mostCommon: [...],
///   insights: ["text1", "text2", "text3"],
/// )
/// ```
class H2HSection extends StatefulWidget {
  const H2HSection({
    super.key,
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    required this.totalMatches,
    required this.recentScores,
    required this.avgGoals,
    required this.over25Percent,
    required this.bttsPercent,
    required this.mostCommon,
    required this.insights,
    this.initialExpanded = true,
  });

  final int homeWins;
  final int draws;
  final int awayWins;
  final int totalMatches;
  final List<ScoreData> recentScores;
  final double avgGoals;
  final int over25Percent;
  final int bttsPercent;
  final List<CommonScore> mostCommon;
  final List<String> insights;
  final bool initialExpanded;

  @override
  State<H2HSection> createState() => _H2HSectionState();
}

class _H2HSectionState extends State<H2HSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'H2H',
            isExpanded: _isExpanded,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _Body(widget: widget),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.widget});

  final H2HSection widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          _allTimeRecord(),
          _recentMeetings(),
          _stats(),
          _mostCommon(),
          _matchInsights(),
        ],
      ),
    );
  }

  // ── All Time Record ──────────────────────────────────────────────────────

  Widget _allTimeRecord() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'All Time Record',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${widget.totalMatches} Matches)',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleBadge(result: MatchResult.win, count: widget.homeWins, size: 64.0),
            const SizedBox(width: 48),
            CircleBadge(result: MatchResult.draw, count: widget.draws, size: 64.0),
            const SizedBox(width: 48),
            CircleBadge(result: MatchResult.lose, count: widget.awayWins, size: 64.0),
          ],
        ),
      ],
    );
  }

  // ── Recently Meetings ────────────────────────────────────────────────────

  Widget _recentMeetings() {
    const arrowIcon = Icon(
      Icons.arrow_forward_ios,
      size: 12,
      color: AppColors.textTertiary,
    );

    final boxes = widget.recentScores.take(5).map(
          (s) => ScoreBox(
            result: s.result,
            homeScore: s.homeScore,
            awayScore: s.awayScore,
          ),
        );

    // Interleave score boxes with arrow icons
    final interleaved = <Widget>[];
    for (final (i, box) in boxes.indexed) {
      interleaved.add(box);
      if (i < widget.recentScores.take(5).length - 1) {
        interleaved.add(arrowIcon);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Recently Meetings',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: interleaved,
        ),
      ],
    );
  }

  // ── Stats ────────────────────────────────────────────────────────────────

  Widget _stats() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Stats',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                value: widget.avgGoals.toStringAsFixed(1),
                label: 'Avg Goals',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: HighlightStatsCard(
                value: '${widget.over25Percent}%',
                label: 'O 2.5',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatsCard(
                value: '${widget.bttsPercent}%',
                label: 'BTTS',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Most Common ──────────────────────────────────────────────────────────

  Widget _mostCommon() {
    final items = widget.mostCommon.take(3).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Most Common',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            for (final (i, cs) in items.indexed) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  value: cs.score,
                  label: '× ${cs.count}',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Match Insights ───────────────────────────────────────────────────────

  Widget _matchInsights() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Match Insights',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        InsightsCard(insights: widget.insights),
      ],
    );
  }
}
