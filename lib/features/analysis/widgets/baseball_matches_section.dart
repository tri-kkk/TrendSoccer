import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class BaseballMatchesSection extends ConsumerWidget {
  const BaseballMatchesSection({
    required this.dateStr,
    this.scrollable = false,
    super.key,
  });

  final String dateStr;
  final bool scrollable;

  static const _nestedScrollPhysics = ClampingScrollPhysics();

  Widget _buildNestedScrollView(
    BuildContext context, {
    required List<Widget> slivers,
  }) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: PageStorageKey<String>('baseball-analysis-$dateStr'),
          physics: _nestedScrollPhysics,
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            ...slivers,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final matchesAsync = ref.watch(baseballAnalysisMatchesProvider);
    final selectedLeague = ref.watch(selectedBaseballLeagueProvider);

    ref.listen(baseballAnalysisMatchesProvider, (previous, next) {
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, '경기 목록을 불러오지 못했습니다.');
      }
    });

    return matchesAsync.when(
      loading: () {
        const loading = Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        );
        if (scrollable) {
          return _buildNestedScrollView(
            context,
            slivers: const [
              SliverFillRemaining(
                hasScrollBody: false,
                child: loading,
              ),
            ],
          );
        }
        return loading;
      },
      error: (error, stackTrace) {
        final errorWidget = Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: _InlineError(
              semantic: semantic,
              onRetry: () => ref.invalidate(baseballAnalysisMatchesProvider),
            ),
          ),
        );
        if (scrollable) {
          return _buildNestedScrollView(
            context,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: errorWidget,
              ),
            ],
          );
        }
        return errorWidget;
      },
      data: (matches) {
        final filtered = filterBaseballAnalysisMatches(
          matches: matches,
          dateStr: dateStr,
          selectedLeague: selectedLeague,
        );

        if (filtered.isEmpty) {
          if (scrollable) {
            return _buildNestedScrollView(
              context,
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: TsEmptyState(
                      title: '예정된 야구 경기가 없습니다.',
                    ),
                  ),
                ),
              ],
            );
          }
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: const Center(
              child: TsEmptyState(
                title: '예정된 야구 경기가 없습니다.',
              ),
            ),
          );
        }

        final cards = [
          for (var i = 0; i < filtered.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _BaseballAnalysisCardItem(card: filtered[i]),
          ],
        ];

        if (scrollable) {
          return _buildNestedScrollView(
            context,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(cards),
                ),
              ),
            ],
          );
        }

        return Column(children: cards);
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
        extra: MatchHeaderData.fromBaseballCard(card),
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
