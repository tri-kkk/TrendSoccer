import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class BaseballMatchesSection extends ConsumerWidget {
  const BaseballMatchesSection({super.key});

  static Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.4,
      child: const Center(
        child: TsEmptyState(
          title: '예정된 야구 경기가 없습니다.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final matchesAsync = ref.watch(filteredBaseballAnalysisProvider);

    ref.listen(filteredBaseballAnalysisProvider, (previous, next) {
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
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: _InlineError(
            semantic: semantic,
            onRetry: () => ref.invalidate(baseballAnalysisMatchesProvider),
          ),
        ),
      ),
      data: (matches) {
        if (matches.isEmpty) {
          return _buildEmptyState(context);
        }
        return Column(
          children: [
            for (var i = 0; i < matches.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _BaseballAnalysisCardItem(card: matches[i]),
            ],
          ],
        );
      },
    );
  }
}

class _BaseballAnalysisCardItem extends StatelessWidget {
  const _BaseballAnalysisCardItem({required this.card});

  final BaseballAnalysisCard card;

  @override
  Widget build(BuildContext context) {
    return AnalysisCard(
      leagueId: baseballLeagueIconId(card.league),
      leagueName: card.league,
      date: formatBaseballCardDate(card),
      homeTeam: card.homeDisplayTeam,
      awayTeam: card.awayDisplayTeam,
      matchTime: formatBaseballMatchTimeKst(card),
      homeLogoUrl: card.homeTeamLogo,
      awayLogoUrl: card.awayTeamLogo,
      isPremiumPick: false,
      pickDirection: null,
      winRate: null,
      onAnalyze: () => context.push(
        '/analysis/baseball/match-report/${card.matchId}',
        extra: card.matchTimestamp,
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
    return Column(
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
    );
  }
}
