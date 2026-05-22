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
            child: _BaseballStandardContent(parsed: parsed),
          ),
        );
      },
    );
  }
}

class _BaseballStandardContent extends StatelessWidget {
  const _BaseballStandardContent({required this.parsed});

  final BaseballStandardParsed parsed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StartingPitchersSection(
          awayPitcher: parsed.awayPitcher.toPitcherData(),
          homePitcher: parsed.homePitcher.toPitcherData(),
        ),
        if (parsed.pitcherMatchupAnalysis.isNotEmpty) ...[
          const SizedBox(height: TsSpacing.xl),
          PitcherAnalysisSection(paragraphs: parsed.pitcherMatchupAnalysis),
        ],
        if (parsed.h2hMatches.isNotEmpty) ...[
          const SizedBox(height: TsSpacing.xl),
          BaseballH2HSection(matches: parsed.h2hMatches),
        ],
        const SizedBox(height: TsSpacing.xl),
        BaseballOddsSection(
          awayOdds: parsed.awayWinOdds,
          homeOdds: parsed.homeWinOdds,
          awayTeam: parsed.awayTeam,
          homeTeam: parsed.homeTeam,
          overUnderLines: parsed.ouLines,
          homeWinProbRatio: parsed.homeWinProbRatio,
          awayWinProbRatio: parsed.awayWinProbRatio,
        ),
        const SizedBox(height: TsSpacing.xl),
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
