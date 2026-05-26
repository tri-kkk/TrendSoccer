import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/soccer_premium_parser.dart';
import 'package:trendsoccer/features/analysis/models/soccer_team_stats_parser.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/premium/premium_sections.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/soccer_standard_tab.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/premium/score_box.dart';

class SoccerPremiumTab extends ConsumerWidget {
  const SoccerPremiumTab({
    required this.params,
    this.homeTeamLogo,
    this.awayTeamLogo,
    super.key,
  });

  final SoccerAnalysisParams params;
  final String? homeTeamLogo;
  final String? awayTeamLogo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFullAccess = ref.watch(authProvider).hasFullAccess;

    if (!hasFullAccess) {
      return const KeyedSubtree(
        key: ValueKey<Object>('soccer_report_premium_locked'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: _PremiumLockedState(),
        ),
      );
    }

    final premiumAsync = ref.watch(soccerH2HAnalysisProvider(params));

    return premiumAsync.when(
      loading: () => const KeyedSubtree(
        key: ValueKey<Object>('soccer_report_premium_loading'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: _PremiumTabLoading(),
        ),
      ),
      error: (error, stackTrace) => KeyedSubtree(
        key: const ValueKey<Object>('soccer_report_premium_error'),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: SoccerStandardTabError(
            onRetry: () => ref.invalidate(soccerH2HAnalysisProvider(params)),
          ),
        ),
      ),
      data: (raw) {
        final parsed = SoccerPremiumParsed.fromResponse(raw);
        return KeyedSubtree(
          key: const ValueKey<Object>('soccer_report_premium'),
          child: Padding(
            padding: const EdgeInsets.all(TsSpacing.lg),
            child: _PremiumContent(
              params: params,
              parsed: parsed,
              homeTeamLogo: homeTeamLogo,
              awayTeamLogo: awayTeamLogo,
            ),
          ),
        );
      },
    );
  }
}

class _PremiumLockedState extends ConsumerWidget {
  const _PremiumLockedState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '프리미엄 전용 분석',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.sm),
        Text(
          'H2H 심층 분석과 팀 인사이트는 프리미엄 구독 후 이용할 수 있습니다.',
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.xl),
        TsButton(
          label: '지금 구독하기',
          variant: TsButtonVariant.primary,
          onPressed: () => navigateToSubscribe(context, ref),
        ),
      ],
    );
  }
}

class _PremiumTabLoading extends StatelessWidget {
  const _PremiumTabLoading();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: semantic.interactivePrimary),
          const SizedBox(height: TsSpacing.lg),
          Text(
            'H2H 분석 로딩 중...',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PremiumContent extends ConsumerWidget {
  const _PremiumContent({
    required this.params,
    required this.parsed,
    this.homeTeamLogo,
    this.awayTeamLogo,
  });

  final SoccerAnalysisParams params;
  final SoccerPremiumParsed parsed;
  final String? homeTeamLogo;
  final String? awayTeamLogo;

  static const _h2hSectionTitle = 'H2H';
  static const _homeSectionTitle = '홈';
  static const _awaySectionTitle = '원정';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overall = parsed.overall ?? H2HOverall.empty;
    final patterns = parsed.scorePatterns ?? H2HScorePatterns.empty;
    final h2hData = _mapH2HData(parsed, patterns);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        H2HSection(
          headerTitle: _h2hSectionTitle,
          initialExpanded: true,
          homeTeamLogo: homeTeamLogo,
          awayTeamLogo: awayTeamLogo,
          totalMatches: overall.totalMatches,
          homeWins: overall.homeWins,
          draws: overall.draws,
          awayWins: overall.awayWins,
          recentMeetings: h2hData.recentMeetings,
          avgGoals: h2hData.avgGoals,
          over25: h2hData.over25,
          over25Highlight: h2hData.over25Highlight,
          btts: h2hData.btts,
          mostCommonScores: h2hData.mostCommonScores,
          insights: h2hData.insights,
        ),
        const SizedBox(height: TsSpacing.lg),
        _TeamStatsSectionHost(
          params: params,
          isHome: true,
          title: _homeSectionTitle,
          last10Label: '시즌 홈 성적',
          teamLogo: homeTeamLogo,
        ),
        const SizedBox(height: TsSpacing.lg),
        _TeamStatsSectionHost(
          params: params,
          isHome: false,
          title: _awaySectionTitle,
          last10Label: '시즌 원정 성적',
          teamLogo: awayTeamLogo,
        ),
        const SizedBox(height: TsSpacing.xl),
      ],
    );
  }
}

class _H2HDisplayData {
  const _H2HDisplayData({
    required this.recentMeetings,
    required this.avgGoals,
    required this.over25,
    required this.over25Highlight,
    required this.btts,
    required this.mostCommonScores,
    required this.insights,
  });

  final List<H2HMeeting> recentMeetings;
  final String avgGoals;
  final String over25;
  final bool over25Highlight;
  final String btts;
  final List<MostCommonScore> mostCommonScores;
  final List<String> insights;
}

_H2HDisplayData _mapH2HData(
  SoccerPremiumParsed parsed,
  H2HScorePatterns patterns,
) {
  final recentMeetings = parsed.recentMatches
      .take(5)
      .map(_h2hMeetingFromMatch)
      .toList(growable: true);
  while (recentMeetings.length < 5) {
    recentMeetings.add(
      const H2HMeeting(score: '-', result: ScoreBoxResult.draw),
    );
  }

  final hasMatches = parsed.recentMatches.isNotEmpty;
  final avgGoals = parsed.calcAvgTotalGoals;
  final over25Rate = parsed.calcOver25Rate;
  final bttsRate = parsed.calcBttsRate;

  final mostCommon = <MostCommonScore>[];
  for (final entry in patterns.mostCommon.take(3)) {
    final score = entry['score']?.toString();
    final count = _parseInt(entry['count']);
    if (score != null && score.isNotEmpty && count != null && count > 0) {
      mostCommon.add(MostCommonScore(count: count, score: score));
    }
  }
  while (mostCommon.length < 3) {
    mostCommon.add(const MostCommonScore(count: 0, score: '-'));
  }

  final insights = parsed.insights.isNotEmpty ? parsed.insights : const ['-'];

  return _H2HDisplayData(
    recentMeetings: recentMeetings,
    avgGoals: avgGoals,
    over25: hasMatches ? '$over25Rate%' : '-',
    over25Highlight: over25Rate >= 60,
    btts: hasMatches ? '$bttsRate%' : '-',
    mostCommonScores: mostCommon,
    insights: insights,
  );
}

H2HMeeting _h2hMeetingFromMatch(H2HMatch match) {
  final score = match.homeScore >= 0 && match.awayScore >= 0
      ? match.scoreDisplay
      : '-';
  return H2HMeeting(
    score: score,
    result: _scoreBoxResultFromCode(match.result),
  );
}

ScoreBoxResult _scoreBoxResultFromCode(String code) {
  return switch (code.toUpperCase()) {
    'W' => ScoreBoxResult.win,
    'L' => ScoreBoxResult.lose,
    _ => ScoreBoxResult.draw,
  };
}

List<H2HMeeting> _placeholderForm() {
  return List.generate(
    5,
    (_) => const H2HMeeting(score: '-', result: ScoreBoxResult.draw),
  );
}

class _TeamStatsSectionHost extends ConsumerWidget {
  const _TeamStatsSectionHost({
    required this.params,
    required this.isHome,
    required this.title,
    required this.last10Label,
    this.teamLogo,
  });

  final SoccerAnalysisParams params;
  final bool isHome;
  final String title;
  final String last10Label;
  final String? teamLogo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamLogoMap = ref.watch(teamLogoMapProvider);
    final statsAsync = ref.watch(
      isHome ? homeTeamStatsProvider(params) : awayTeamStatsProvider(params),
    );

    return statsAsync.when(
      loading: () => TeamAnalysisSection(
        title: title,
        initialExpanded: false,
        last10Label: last10Label,
        isLoading: true,
        teamLogo: teamLogo,
        teamLogoMap: teamLogoMap,
        wins: 0,
        draws: 0,
        losses: 0,
        recentForm: _placeholderForm(),
        recordWins: '-',
        recordDraws: '-',
        recordLosses: '-',
        winRate: '-',
        goalLineO15: '-',
        goalLineO15Highlight: false,
        goalLineO25: '-',
        goalLineO25Highlight: false,
        goalLineO35: '-',
        marketO25: '-',
        marketO25Highlight: false,
        marketBtts: '-',
        marketBttsHighlight: false,
        marketCs: '-',
        marketFts: '-',
        teamInsights: const ['-'],
      ),
      error: (error, stackTrace) => _buildSection(
        ref,
        TeamStatsParsed.empty,
        hasError: true,
        teamLogoMap: teamLogoMap,
      ),
      data: (raw) {
        final stats = TeamStatsParsed.fromResponse(raw, isHome: isHome);
        if (!stats.hasData) {
          return _buildSection(
            ref,
            TeamStatsParsed.empty,
            hasError: true,
            teamLogoMap: teamLogoMap,
          );
        }
        return _buildSection(
          ref,
          stats,
          hasError: false,
          teamLogoMap: teamLogoMap,
        );
      },
    );
  }

  Widget _buildSection(
    WidgetRef ref,
    TeamStatsParsed stats, {
    required bool hasError,
    required Map<String, String> teamLogoMap,
  }) {
    final display = hasError
        ? _TeamStatsDisplay.empty
        : _TeamStatsDisplay.from(stats, teamLogo: teamLogo);

    return TeamAnalysisSection(
      title: title,
      initialExpanded: false,
      last10Label: last10Label,
      teamLogo: teamLogo,
      teamLogoMap: teamLogoMap,
      wins: display.wins,
      draws: display.draws,
      losses: display.losses,
      recentForm: hasError ? _placeholderForm() : display.recentForm,
      recordWins: display.recordWins,
      recordDraws: display.recordDraws,
      recordLosses: display.recordLosses,
      winRate: display.winRate,
      goalLineO15: display.goalLineO15,
      goalLineO15Highlight: display.goalLineO15Highlight,
      goalLineO25: display.goalLineO25,
      goalLineO25Highlight: display.goalLineO25Highlight,
      goalLineO35: display.goalLineO35,
      goalLineO35Highlight: display.goalLineO35Highlight,
      marketO25: display.marketO25,
      marketO25Highlight: display.marketO25Highlight,
      marketBtts: display.marketBtts,
      marketBttsHighlight: display.marketBttsHighlight,
      marketCs: display.marketCs,
      marketFts: display.marketFts,
      teamInsights: display.teamInsights,
      onRetry: hasError
          ? () => ref.invalidate(
                isHome
                    ? homeTeamStatsProvider(params)
                    : awayTeamStatsProvider(params),
              )
          : null,
    );
  }
}

class _TeamStatsDisplay {
  const _TeamStatsDisplay({
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
    required this.goalLineO35Highlight,
    required this.marketO25,
    required this.marketO25Highlight,
    required this.marketBtts,
    required this.marketBttsHighlight,
    required this.marketCs,
    required this.marketFts,
    required this.teamInsights,
  });

  static const empty = _TeamStatsDisplay(
    wins: 0,
    draws: 0,
    losses: 0,
    recentForm: [],
    recordWins: '-',
    recordDraws: '-',
    recordLosses: '-',
    winRate: '-',
    goalLineO15: '-',
    goalLineO15Highlight: false,
    goalLineO25: '-',
    goalLineO25Highlight: false,
    goalLineO35: '-',
    goalLineO35Highlight: false,
    marketO25: '-',
    marketO25Highlight: false,
    marketBtts: '-',
    marketBttsHighlight: false,
    marketCs: '-',
    marketFts: '-',
    teamInsights: ['-'],
  );

  factory _TeamStatsDisplay.from(TeamStatsParsed stats, {String? teamLogo}) {
    return _TeamStatsDisplay(
      wins: stats.last10Wins,
      draws: stats.last10Draws,
      losses: stats.last10Losses,
      recentForm: _recentFormFromStats(stats, teamLogo),
      recordWins: '${stats.recordWins}',
      recordDraws: '${stats.recordDraws}',
      recordLosses: '${stats.recordLosses}',
      winRate: _formatPercent(stats.recordWinRate),
      goalLineO15: _formatPercent(stats.over15Rate),
      goalLineO15Highlight: _shouldHighlight(stats.over15Rate),
      goalLineO25: _formatPercent(stats.over25Rate),
      goalLineO25Highlight: _shouldHighlight(stats.over25Rate),
      goalLineO35: _formatPercent(stats.over35Rate),
      goalLineO35Highlight: _shouldHighlight(stats.over35Rate),
      marketO25: _formatPercent(stats.over25Rate),
      marketO25Highlight: _shouldHighlight(stats.over25Rate),
      marketBtts: _formatPercent(stats.bttsRate),
      marketBttsHighlight: _shouldHighlight(stats.bttsRate),
      marketCs: _formatPercent(stats.cleanSheetRate),
      marketFts: _formatPercent(stats.scorelessRate),
      teamInsights: stats.teamInsights,
    );
  }

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
}

List<H2HMeeting> _recentFormFromStats(
  TeamStatsParsed stats,
  String? teamLogo,
) {
  final form = <H2HMeeting>[];
  for (var i = 0; i < 5; i++) {
    if (i < stats.recentMatches.length) {
      final match = stats.recentMatches[i];
      form.add(
        H2HMeeting(
          score: match.scoreDisplay,
          result: _scoreBoxResultFromCode(match.result),
          winTeamLogo: teamLogo,
          loseEmblemInitial: _opponentInitial(match),
          opponent: match.opponent,
          opponentKo: match.opponentKo,
          opponentLogo: match.opponentLogo,
        ),
      );
    } else if (i < stats.last5Results.length) {
      form.add(
        H2HMeeting(
          score: '-',
          result: _scoreBoxResultFromCode(stats.last5Results[i]),
          winTeamLogo: teamLogo,
        ),
      );
    } else {
      form.add(H2HMeeting(
        score: '-',
        result: ScoreBoxResult.draw,
        winTeamLogo: teamLogo,
      ));
    }
  }
  return form;
}

String _opponentInitial(TeamRecentMatch match) {
  final name = match.opponentKo.trim().isNotEmpty
      ? match.opponentKo.trim()
      : match.opponent.trim();
  if (name.isEmpty) return '?';
  return name.characters.first;
}

String _formatPercent(int rate) => rate > 0 ? '$rate%' : '-';

bool _shouldHighlight(int rate) => rate >= 60;

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}
