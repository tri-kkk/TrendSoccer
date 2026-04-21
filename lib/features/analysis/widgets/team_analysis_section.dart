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

/// Home or Away team analysis section for the premium analysis tab.
///
/// ```dart
/// TeamAnalysisSection(
///   title: "Home",
///   wins: 7, draws: 2, loses: 1,
///   recentForm: [...],
///   recordW: 2, recordD: 3, recordL: 5, winPercent: 30,
///   over15: 90, over25: 50, over35: 40,
///   marketO25: 70, marketBTTS: 80, marketCS: 10, marketFTS: 20,
///   insights: ["text1", "text2", "text3"],
/// )
/// ```
class TeamAnalysisSection extends StatefulWidget {
  const TeamAnalysisSection({
    super.key,
    required this.title,
    required this.wins,
    required this.draws,
    required this.loses,
    required this.recentForm,
    required this.recordW,
    required this.recordD,
    required this.recordL,
    required this.winPercent,
    required this.over15,
    required this.over25,
    required this.over35,
    required this.marketO25,
    required this.marketBTTS,
    required this.marketCS,
    required this.marketFTS,
    required this.insights,
    this.initialExpanded = false,
  });

  final String title;
  final int wins;
  final int draws;
  final int loses;
  final List<ScoreData> recentForm;
  final int recordW;
  final int recordD;
  final int recordL;
  final int winPercent;
  final int over15;
  final int over25;
  final int over35;
  final int marketO25;
  final int marketBTTS;
  final int marketCS;
  final int marketFTS;
  final List<String> insights;
  final bool initialExpanded;

  @override
  State<TeamAnalysisSection> createState() => _TeamAnalysisSectionState();
}

class _TeamAnalysisSectionState extends State<TeamAnalysisSection> {
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
            title: widget.title,
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

// ── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.widget});

  final TeamAnalysisSection widget;

  /// Returns [HighlightStatsCard] when [percent] ≥ 60, otherwise [StatsCard].
  Widget _statCard({required String value, required String label, required int percent}) {
    if (percent >= 60) {
      return HighlightStatsCard(value: value, label: label);
    }
    return StatsCard(value: value, label: label);
  }

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
          _last10Games(),
          _recentForm(),
          _record(),
          _goalLines(),
          _marketStats(),
          _teamInsights(),
        ],
      ),
    );
  }

  // ── Last 10 Games ──────────────────────────────────────────────────────────

  Widget _last10Games() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Last 10 Games',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleBadge(result: MatchResult.win, count: widget.wins, size: 64.0),
            const SizedBox(width: 48),
            CircleBadge(result: MatchResult.draw, count: widget.draws, size: 64.0),
            const SizedBox(width: 48),
            CircleBadge(result: MatchResult.lose, count: widget.loses, size: 64.0),
          ],
        ),
      ],
    );
  }

  // ── Recently Form ──────────────────────────────────────────────────────────

  Widget _recentForm() {
    const arrowIcon = Icon(
      Icons.arrow_forward_ios,
      size: 12,
      color: AppColors.textTertiary,
    );

    final scores = widget.recentForm.take(5).toList();
    final interleaved = <Widget>[];
    for (final (i, s) in scores.indexed) {
      interleaved.add(
        ScoreBox(result: s.result, homeScore: s.homeScore, awayScore: s.awayScore),
      );
      if (i < scores.length - 1) interleaved.add(arrowIcon);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Recently Form',
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

  // ── Record ─────────────────────────────────────────────────────────────────

  Widget _record() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          '${widget.title} Record (Last 10G)',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Expanded(child: StatsCard(value: '${widget.recordW}', label: 'W')),
            const SizedBox(width: 8),
            Expanded(child: StatsCard(value: '${widget.recordD}', label: 'D')),
            const SizedBox(width: 8),
            Expanded(child: StatsCard(value: '${widget.recordL}', label: 'L')),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                value: '${widget.winPercent}%',
                label: 'Win %',
                percent: widget.winPercent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Goal Lines ─────────────────────────────────────────────────────────────

  Widget _goalLines() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Goal Lines',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _statCard(
                value: '${widget.over15}%',
                label: 'O 1.5',
                percent: widget.over15,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                value: '${widget.over25}%',
                label: 'O 2.5',
                percent: widget.over25,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                value: '${widget.over35}%',
                label: 'O 3.5',
                percent: widget.over35,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Market Stats ───────────────────────────────────────────────────────────

  Widget _marketStats() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Market Stats (Last 10G)',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _statCard(
                value: '${widget.marketO25}%',
                label: 'O 2.5',
                percent: widget.marketO25,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                value: '${widget.marketBTTS}%',
                label: 'BTTS',
                percent: widget.marketBTTS,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                value: '${widget.marketCS}%',
                label: 'CS',
                percent: widget.marketCS,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statCard(
                value: '${widget.marketFTS}%',
                label: 'FTS',
                percent: widget.marketFTS,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Team Insights ──────────────────────────────────────────────────────────

  Widget _teamInsights() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Team Insights',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        InsightsCard(insights: widget.insights),
      ],
    );
  }
}
