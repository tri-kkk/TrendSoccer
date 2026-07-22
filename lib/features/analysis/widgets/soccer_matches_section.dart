import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/services/admob_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/shared/widgets/ads/premium_ad_wrapper.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/empty/network_error_widget.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';

class SoccerMatchesSection extends ConsumerWidget {
  const SoccerMatchesSection({
    required this.dateStr,
    super.key,
  });

  final String dateStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLeague = ref.watch(selectedLeagueProvider);
    final matchesAsync = ref.watch(analysisSoccerMatchesProvider);

    return matchesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: TsSpacing.xxxl),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: NetworkErrorWidget(
          message: context.l10n.analysisLoadMatchesFailed,
          onRetry: () {
            clearSoccerAnalysisEmptyCache();
            ref.invalidate(analysisSoccerMatchesProvider);
          },
        ),
      ),
      data: (matches) {
        final filtered = filterSoccerAnalysisMatches(
          matches,
          dateStr,
          selectedLeague,
        );

        if (filtered.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TsSpacing.xxxl),
              child: Center(
                child: TsEmptyState(
                  title: context.l10n.analysisNoMatches,
                  subtitle: context.l10n.analysisNoMatchesFilterHint,
                ),
              ),
            ),
          );
        }

        return _buildMatchesSliver(
          ref: ref,
          itemCount: filtered.length,
          cardBuilder: (index) =>
              _SoccerAnalysisCardItem(card: filtered[index]),
        );
      },
    );
  }
}

Widget _buildMatchesSliver({
  required WidgetRef ref,
  required int itemCount,
  required Widget Function(int index) cardBuilder,
}) {
  final showAd = !ref.watch(authProvider).hasFullAccess;
  final sliverItemCount = itemCount + (showAd ? 1 : 0);

  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        if (showAd && index == 1) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(TsSpacing.lg, TsSpacing.sm, TsSpacing.lg, TsSpacing.sm),
            child: PremiumAdWrapper(
              adUnitId: AdmobService.analysisBannerAdUnitId,
            ),
          );
        }

        final cardIndex = showAd && index > 1 ? index - 1 : index;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            TsSpacing.lg,
            cardIndex == 0 ? 0 : TsSpacing.sm,
            TsSpacing.lg,
            cardIndex == itemCount - 1 ? 0 : TsSpacing.sm,
          ),
          child: cardBuilder(cardIndex),
        );
      },
      childCount: sliverItemCount,
    ),
  );
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
      onAnalyze: () => context.push(
        '/analysis/soccer/match-report/${match.matchId}',
        extra: MatchHeaderData.fromSoccerCard(card),
      ),
    );
  }
}
