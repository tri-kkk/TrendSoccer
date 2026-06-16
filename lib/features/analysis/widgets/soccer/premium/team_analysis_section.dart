import 'package:flutter/material.dart';

import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
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
    this.initialExpanded = false,
    this.isLoading = false,
    this.teamLogo,
    this.teamLogoMap = const {},
    this.onRetry,
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
  final bool initialExpanded;
  final bool isLoading;
  final String? teamLogo;
  final Map<String, String> teamLogoMap;
  final VoidCallback? onRetry;

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

  Widget _buildScoreBoxRow(TsSemanticColors semantic) {
    final meetings = widget.recentForm;
    final teamLogoMap = widget.teamLogoMap;

    return Row(
      children: [
        for (var i = 0; i < meetings.length; i++) ...[
          Expanded(
            child: Builder(
              builder: (context) {
                final meeting = meetings[i];
                String? opponentLogo;
                if (meeting.result == ScoreBoxResult.lose) {
                  opponentLogo = meeting.opponentLogo;
                  if (opponentLogo == null && teamLogoMap.isNotEmpty) {
                    final opponent = meeting.opponent ?? '';
                    final opponentKo = meeting.opponentKo ?? '';
                    opponentLogo = findTeamLogo(teamLogoMap, opponent);
                    if (opponentLogo == null && opponentKo.isNotEmpty) {
                      opponentLogo = findTeamLogo(teamLogoMap, opponentKo);
                    }
                  }
                }
                return ScoreBox(
                  score: meeting.score,
                  result: meeting.result,
                  homeTeamLogo: meeting.winTeamLogo ?? widget.teamLogo,
                  awayTeamLogo: opponentLogo,
                  loseEmblemInitial:
                      opponentLogo == null ? meeting.loseEmblemInitial : null,
                );
              },
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

  Widget _buildLoadingPlaceholder(TsSemanticColors semantic) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.lg),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: semantic.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
        const SizedBox(height: TsSpacing.lg),
        Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: semantic.interactivePrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final w = widget;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: semantic.surfaceBase,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CardSectionTitle(
            title: w.title,
            isExpanded: _isExpanded,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
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
                  if (w.isLoading)
                    _buildLoadingPlaceholder(semantic)
                  else ...[
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.soccerRecent10,
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
                        label: l10n.soccerStatWins,
                        value: '${w.wins}',
                        type: CircleBadgeType.win,
                      ),
                      const SizedBox(width: 48),
                      CircleBadge(
                        label: l10n.labelDraw,
                        value: '${w.draws}',
                        type: CircleBadgeType.draw,
                      ),
                      const SizedBox(width: 48),
                      CircleBadge(
                        label: l10n.soccerStatLosses,
                        value: '${w.losses}',
                        type: CircleBadgeType.lose,
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.soccerRecentForm,
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
                        child: StatsCard(value: w.recordWins, label: l10n.soccerStatWins),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.recordDraws, label: l10n.labelDraw),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.recordLosses, label: l10n.soccerStatLosses),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.winRate, label: l10n.soccerStatWinRate),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.soccerStatGoalLine,
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
                          label: l10n.soccerStatOver15,
                          isHighlight: w.goalLineO15Highlight,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.lg),
                      Expanded(
                        child: StatsCard(
                          value: w.goalLineO25,
                          label: l10n.soccerStatOver25,
                          isHighlight: w.goalLineO25Highlight,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.lg),
                      Expanded(
                        child: StatsCard(
                          value: w.goalLineO35,
                          label: l10n.soccerStatOver35,
                          isHighlight: w.goalLineO35Highlight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.soccerMarketIndicators,
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
                          label: l10n.soccerStatOver25,
                          isHighlight: w.marketO25Highlight,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(
                          value: w.marketBtts,
                          label: l10n.soccerMarketBtts,
                          isHighlight: w.marketBttsHighlight,
                        ),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.marketCs, label: l10n.soccerMarketCs),
                      ),
                      const SizedBox(width: TsSpacing.sm),
                      Expanded(
                        child: StatsCard(value: w.marketFts, label: l10n.soccerMarketFts),
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.soccerStatTeamInsights,
                      style: TsType.bodyLRegular.copyWith(
                        color: semantic.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: TsSpacing.lg),
                  InsightsCard(comments: w.teamInsights),
                  if (w.onRetry != null) ...[
                    const SizedBox(height: TsSpacing.md),
                    TextButton(
                      onPressed: w.onRetry,
                      child: Text(
                        l10n.retry,
                        style: TsType.labelSRegular.copyWith(
                          color: semantic.interactivePrimary,
                        ),
                      ),
                    ),
                  ],
                  ],
                    ],
                  ),
                ),
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
