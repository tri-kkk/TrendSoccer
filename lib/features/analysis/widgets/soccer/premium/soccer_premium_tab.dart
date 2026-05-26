import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/soccer_premium_parser.dart';
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

class _PremiumContent extends StatelessWidget {
  const _PremiumContent({
    required this.parsed,
    this.homeTeamLogo,
    this.awayTeamLogo,
  });

  final SoccerPremiumParsed parsed;
  final String? homeTeamLogo;
  final String? awayTeamLogo;

  static const _h2hSectionTitle = 'H2H';
  static const _homeSectionTitle = '홈';
  static const _awaySectionTitle = '원정';

  @override
  Widget build(BuildContext context) {
    final overall = parsed.overall ?? H2HOverall.empty;
    final patterns = parsed.scorePatterns ?? H2HScorePatterns.empty;
    final h2hData = _mapH2HData(parsed, overall, patterns);

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
        // TODO: Wire to team-specific stats API — need endpoint from backend developer
        TeamAnalysisSection(
          title: _homeSectionTitle,
          initialExpanded: false,
          last10Label: '홈 성적 (최근 10경기)',
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
          goalLineO35Highlight: false,
          marketO25: '-',
          marketO25Highlight: false,
          marketBtts: '-',
          marketBttsHighlight: false,
          marketCs: '-',
          marketFts: '-',
          teamInsights: const ['-'],
        ),
        const SizedBox(height: TsSpacing.lg),
        // TODO: Wire to team-specific stats API — need endpoint from backend developer
        TeamAnalysisSection(
          title: _awaySectionTitle,
          initialExpanded: false,
          last10Label: '원정 성적 (최근 10경기)',
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
          goalLineO35Highlight: false,
          marketO25: '-',
          marketO25Highlight: false,
          marketBtts: '-',
          marketBttsHighlight: false,
          marketCs: '-',
          marketFts: '-',
          teamInsights: const ['-'],
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
  H2HOverall overall,
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

  final avgGoalsSum = patterns.avgHomeGoals + patterns.avgAwayGoals;
  final avgGoals =
      avgGoalsSum > 0 ? avgGoalsSum.toStringAsFixed(1) : '-';

  final over25Rate = patterns.over25Rate;
  final bttsRate = patterns.bttsRate;

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
    over25: over25Rate > 0 ? '$over25Rate%' : '-',
    over25Highlight: over25Rate > 50,
    btts: bttsRate > 0 ? '$bttsRate%' : '-',
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

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}
