import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
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
        TsToast.error(context, context.l10n.analysisLoadMatchesFailed);
      }
    });

    ref.listen(filteredSoccerMatchesProvider, (previous, next) {
      if (dateStr != null) return;
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, context.l10n.analysisLoadMatchesFailed);
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
              onRetry: () {
                clearSoccerAnalysisEmptyCache();
                ref.invalidate(analysisSoccerMatchesProvider);
              },
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
          final emptyState = TsEmptyState(
            title: context.l10n.analysisNoMatches,
            subtitle: context.l10n.analysisNoMatchesFilterHint,
          );
          if (scrollable) {
            return _buildNestedScrollView(
              context,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: emptyState),
                ),
              ],
            );
          }
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: Center(child: emptyState),
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

    return AnalysisCard(
      leagueId: leagueId,
      leagueName: localizedLeagueName(
        context,
        match.league.nameEn,
        match.league.name,
      ),
      leagueLogoUrl: match.league.icon,
      date: formatSoccerCardDate(match.matchDate),
      homeTeam: localizedTeamName(
        context,
        match.homeTeam.name,
        match.homeTeam.nameKo,
      ),
      awayTeam: localizedTeamName(
        context,
        match.awayTeam.name,
        match.awayTeam.nameKo,
      ),
      matchTime: match.matchTime,
      homeLogoUrl: match.homeTeam.logo,
      awayLogoUrl: match.awayTeam.logo,
      alwaysActiveAnalyzeButton: true,
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
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.analysisLoadMatchesFailed,
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TsButton(
          label: l10n.retry,
          variant: TsButtonVariant.primary,
          size: TsButtonSize.small,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
