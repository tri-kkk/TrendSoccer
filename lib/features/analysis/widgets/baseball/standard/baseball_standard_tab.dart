import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/standard_sections.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class BaseballStandardTab extends ConsumerWidget {
  const BaseballStandardTab({
    required this.matchId,
    super.key,
  });

  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(baseballMatchDetailProvider(matchId));

    return detailAsync.when(
      loading: () => const KeyedSubtree(
        key: ValueKey<Object>('baseball_report_standard_loading'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: BaseballStandardTabLoading(),
        ),
      ),
      error: (error, stackTrace) => KeyedSubtree(
        key: const ValueKey<Object>('baseball_report_standard_error'),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: BaseballStandardTabError(
            onRetry: () => ref.invalidate(baseballMatchDetailProvider(matchId)),
          ),
        ),
      ),
      data: (raw) {
        final parsed = parseBaseballStandardDetail(raw);
        return KeyedSubtree(
          key: const ValueKey<Object>('baseball_report_standard'),
          child: Padding(
            padding: const EdgeInsets.all(TsSpacing.lg),
            child: _BaseballStandardContent(
              matchId: matchId,
              parsed: parsed,
            ),
          ),
        );
      },
    );
  }
}

String _pitcherApiName(BaseballStandardPitcher pitcher) {
  final ko = pitcher.nameKo?.trim();
  if (ko != null && ko.isNotEmpty) return ko;
  final name = pitcher.name.trim();
  return name.isEmpty ? '-' : name;
}

Widget _buildH2HSection(WidgetRef ref, BaseballStandardParsed parsed) {
  final homeTeamId = parsed.homeTeamId;
  final awayTeamId = parsed.awayTeamId;

  if (homeTeamId == null || awayTeamId == null) {
    return const BaseballH2HSection(matches: []);
  }

  final h2hAsync = ref.watch(
    baseballH2HProvider(
      (homeTeamId: homeTeamId, awayTeamId: awayTeamId),
    ),
  );

  return h2hAsync.when(
    loading: () => const BaseballH2HSection(isLoading: true, matches: []),
    error: (error, stackTrace) => const BaseballH2HSection(matches: []),
    data: (response) => BaseballH2HSection(
      matches: parseBaseballH2HResponse(response),
    ),
  );
}

class _BaseballStandardContent extends ConsumerWidget {
  const _BaseballStandardContent({
    required this.matchId,
    required this.parsed,
  });

  final int matchId;
  final BaseballStandardParsed parsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(baseballPitcherAnalysisProvider(matchId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StartingPitchersSection(
          leagueCode: parsed.leagueCode,
          currentSeason: parsed.currentSeason,
          homeTeam: parsed.homeTeam,
          awayTeam: parsed.awayTeam,
          homePitcherName: _pitcherApiName(parsed.homePitcher),
          awayPitcherName: _pitcherApiName(parsed.awayPitcher),
          awayPitcher: parsed.awayPitcher.toPitcherData(
            teamLogoUrl: parsed.awayLogoUrl,
          ),
          homePitcher: parsed.homePitcher.toPitcherData(
            teamLogoUrl: parsed.homeLogoUrl,
          ),
        ),
        const SizedBox(height: TsSpacing.lg),
        analysisAsync.when(
          loading: () => const PitcherAnalysisSection(isLoading: true),
          error: (error, stackTrace) => const PitcherAnalysisSection(),
          data: (response) {
            final analysis = response['analysis'];
            if (analysis is! String || analysis.trim().isEmpty) {
              return const PitcherAnalysisSection();
            }
            return PitcherAnalysisSection(analysisText: analysis);
          },
        ),
        const SizedBox(height: TsSpacing.lg),
        _buildH2HSection(ref, parsed),
        const SizedBox(height: TsSpacing.lg),
        BaseballOddsSection(
          awayOdds: parsed.awayWinOdds,
          homeOdds: parsed.homeWinOdds,
          overUnderLines: parsed.ouLines,
        ),
        const SizedBox(height: TsSpacing.lg),
      ],
    );
  }
}

class BaseballStandardTabLoading extends StatelessWidget {
  const BaseballStandardTabLoading({super.key});

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
            '경기 정보 로딩 중...',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BaseballStandardTabError extends StatelessWidget {
  const BaseballStandardTabError({
    required this.onRetry,
    super.key,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '경기 정보를 불러오지 못했습니다.',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: '다시 시도',
            variant: TsButtonVariant.primary,
            size: TsButtonSize.small,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
