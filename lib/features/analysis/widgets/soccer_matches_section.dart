import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class SoccerMatchesSection extends ConsumerWidget {
  const SoccerMatchesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final date = ref.watch(todayDateProvider);
    final matchesAsync = ref.watch(filteredSoccerMatchesProvider);

    ref.listen(filteredSoccerMatchesProvider, (previous, next) {
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, '경기 목록을 불러오지 못했습니다.');
      }
    });

    return matchesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => _InlineError(
        semantic: semantic,
        onRetry: () => ref.invalidate(soccerMatchesProvider(date)),
      ),
      data: (matches) {
        if (matches.isEmpty) {
          return const TsEmptyState(
            title: '경기가 없습니다',
            subtitle: '오늘 예정된 경기가 없거나 필터 조건에 맞는 경기가 없습니다.',
          );
        }
        return Column(
          children: [
            for (var i = 0; i < matches.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _SoccerAnalysisCardItem(card: matches[i]),
            ],
          ],
        );
      },
    );
  }
}

class _SoccerAnalysisCardItem extends StatelessWidget {
  const _SoccerAnalysisCardItem({required this.card});

  final SoccerAnalysisCard card;

  @override
  Widget build(BuildContext context) {
    final match = card.match;
    final leagueId = leagueIdForCard(match.league);

    return AnalysisCard(
      leagueId: leagueId,
      leagueName: match.league.name,
      date: formatSoccerCardDate(match.matchDate),
      homeTeam: match.homeTeam.name,
      awayTeam: match.awayTeam.name,
      matchTime: match.matchTime,
      homeLogoUrl: match.homeTeam.logo,
      awayLogoUrl: match.awayTeam.logo,
      isPremiumPick: false,
      pickDirection: null,
      winRate: null,
      onAnalyze: () => context.push(
        '/analysis/soccer/match-report/${match.matchId}',
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.semantic,
    required this.onRetry,
  });

  final TsSemanticColors semantic;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '경기 목록을 불러오지 못했습니다.',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
