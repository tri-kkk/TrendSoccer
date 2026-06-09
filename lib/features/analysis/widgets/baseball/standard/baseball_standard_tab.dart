import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';
import 'package:trendsoccer/features/analysis/models/parser_labels.dart';
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
        final labels = ParserLabels.from(context.l10n);
        final parsed = parseBaseballStandardDetail(raw, labels: labels);
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
    final labels = ParserLabels.from(context.l10n);
    final analysisAsync = ref.watch(baseballPitcherAnalysisProvider(matchId));
    final homePitcherName = baseballAsianLeagueApiLookupName(
      parsed.homePitcher.name,
      parsed.homePitcher.nameKo,
    );
    final awayPitcherName = baseballAsianLeagueApiLookupName(
      parsed.awayPitcher.name,
      parsed.awayPitcher.nameKo,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StartingPitchersSection(
          matchId: matchId,
          leagueCode: parsed.leagueCode,
          currentSeason: parsed.currentSeason,
          homeTeam: localizedTeamName(
            context,
            parsed.homeTeam,
            parsed.homeTeamKo,
          ),
          awayTeam: localizedTeamName(
            context,
            parsed.awayTeam,
            parsed.awayTeamKo,
          ),
          homePitcherLookupName: baseballAsianLeagueApiLookupName(
            parsed.homePitcher.name,
            parsed.homePitcher.nameKo,
          ),
          awayPitcherLookupName: baseballAsianLeagueApiLookupName(
            parsed.awayPitcher.name,
            parsed.awayPitcher.nameKo,
          ),
          homeTeamLookupName: baseballAsianLeagueApiLookupTeam(
            parsed.homeTeam,
            parsed.homeTeamKo,
          ),
          awayTeamLookupName: baseballAsianLeagueApiLookupTeam(
            parsed.awayTeam,
            parsed.awayTeamKo,
          ),
          homePitcherName: homePitcherName,
          awayPitcherName: awayPitcherName,
          awayPitcher: parsed.awayPitcher.toPitcherData(
            labels: labels,
            teamLogoUrl: parsed.awayLogoUrl,
          ),
          homePitcher: parsed.homePitcher.toPitcherData(
            labels: labels,
            teamLogoUrl: parsed.homeLogoUrl,
          ),
        ),
        const SizedBox(height: TsSpacing.lg),
        analysisAsync.when(
          loading: () => const PitcherAnalysisSection(isLoading: true),
          error: (error, stackTrace) => const PitcherAnalysisSection(),
          data: (response) {
            final analysis = response['analysis'];
            if (analysis is String && analysis.trim().isNotEmpty) {
              return PitcherAnalysisSection(analysisText: analysis);
            }
            return const PitcherAnalysisSection();
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
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: semantic.interactivePrimary),
          const SizedBox(height: TsSpacing.lg),
          Text(
            l10n.analysisMatchInfoLoading,
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
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.analysisMatchInfoLoadFailed,
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: l10n.retry,
            variant: TsButtonVariant.primary,
            size: TsButtonSize.small,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
