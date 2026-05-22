import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class SoccerMatchesSection extends ConsumerWidget {
  const SoccerMatchesSection({
    this.dateStr,
    this.scrollable = false,
    super.key,
  });

  final String? dateStr;
  final bool scrollable;

  static const _nestedScrollPhysics = ClampingScrollPhysics();

  Widget _buildNestedScrollView(
    BuildContext context, {
    required List<Widget> slivers,
  }) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: PageStorageKey<String>(
            'soccer-analysis-${dateStr ?? 'all'}',
          ),
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
    final selectedLeague = ref.watch(selectedLeagueProvider);
    final matchesAsync = dateStr == null
        ? ref.watch(filteredSoccerMatchesProvider)
        : ref.watch(analysisSoccerMatchesProvider);

    ref.listen(analysisSoccerMatchesProvider, (previous, next) {
      if (dateStr == null) return;
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, '경기 목록을 불러오지 못했습니다.');
      }
    });

    ref.listen(filteredSoccerMatchesProvider, (previous, next) {
      if (dateStr != null) return;
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
              onRetry: () => ref.invalidate(analysisSoccerMatchesProvider),
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
        final filtered = dateStr == null
            ? matches
            : filterSoccerAnalysisMatches(
                matches,
                dateStr!,
                selectedLeague,
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
                      title: '경기가 없습니다',
                      subtitle: '오늘 예정된 경기가 없거나 필터 조건에 맞는 경기가 없습니다.',
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
                title: '경기가 없습니다',
                subtitle: '오늘 예정된 경기가 없거나 필터 조건에 맞는 경기가 없습니다.',
              ),
            ),
          );
        }

        final cards = [
          for (var i = 0; i < filtered.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _SoccerAnalysisCardItem(card: filtered[i]),
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

class _SoccerAnalysisCardItem extends ConsumerWidget {
  const _SoccerAnalysisCardItem({required this.card});

  final SoccerAnalysisCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = card.match;
    final leagueId = leagueIdForCard(match.league);
    final planType = ref.watch(authProvider).planType;

    return AnalysisCard(
      leagueId: leagueId,
      leagueName: match.league.name,
      leagueLogoUrl: match.league.icon,
      date: formatSoccerCardDate(match.matchDate),
      homeTeam: match.homeTeam.name,
      awayTeam: match.awayTeam.name,
      matchTime: match.matchTime,
      homeLogoUrl: match.homeTeam.logo,
      awayLogoUrl: match.awayTeam.logo,
      matchTimestamp: match.matchTimestamp,
      planType: planType,
      isPremiumPick: false,
      pickDirection: null,
      winRate: null,
      onAnalyze: () => context.push(
        '/analysis/soccer/match-report/${match.matchId}',
        extra: MatchHeaderData.fromSoccerCard(card),
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
