import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/services/admob_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/shared/widgets/ads/premium_ad_wrapper.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/empty/network_error_widget.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';

class BaseballMatchesSection extends ConsumerWidget {
  const BaseballMatchesSection({
    required this.dateStr,
    super.key,
  });

  final String dateStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(baseballAnalysisMatchesProvider);
    final selectedLeague = ref.watch(selectedBaseballLeagueProvider);

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
          onRetry: () => ref.invalidate(baseballAnalysisMatchesProvider),
        ),
      ),
      data: (matches) {
        final filtered = filterBaseballAnalysisMatches(
          matches: matches,
          dateStr: dateStr,
          selectedLeague: selectedLeague,
        );

        if (filtered.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TsSpacing.xxxl),
              child: Center(
                child: TsEmptyState(
                  title: context.l10n.analysisNoBaseballScheduled,
                ),
              ),
            ),
          );
        }

        return _buildMatchesSliver(
          ref: ref,
          itemCount: filtered.length,
          cardBuilder: (index) =>
              _BaseballAnalysisCardItem(card: filtered[index]),
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

class _BaseballAnalysisCardItem extends StatelessWidget {
  const _BaseballAnalysisCardItem({required this.card});

  final BaseballAnalysisCard card;

  @override
  Widget build(BuildContext context) {
    return AnalysisCard(
      leagueId: baseballLeagueIconId(card.league),
      leagueName: card.league,
      date: formatBaseballCardDate(card),
      homeTeam: localizedTeamName(context, card.homeTeam, card.homeTeamKo),
      awayTeam: localizedTeamName(context, card.awayTeam, card.awayTeamKo),
      matchTime: formatBaseballMatchTimeKst(card),
      homeLogoUrl: card.homeTeamLogo,
      awayLogoUrl: card.awayTeamLogo,
      isPremiumPick: false,
      pickDirection: null,
      onAnalyze: () => context.push(
        '/analysis/baseball/match-report/${card.detailMatchId}',
        extra: MatchHeaderData.fromBaseballCard(card),
      ),
    );
  }
}
