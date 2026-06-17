import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/services/admob_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/shared/widgets/ads/premium_ad_wrapper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class BaseballMatchesSection extends ConsumerWidget {
  const BaseballMatchesSection({
    required this.dateStr,
    super.key,
  });

  final String dateStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final matchesAsync = ref.watch(baseballAnalysisMatchesProvider);
    final selectedLeague = ref.watch(selectedBaseballLeagueProvider);

    ref.listen(baseballAnalysisMatchesProvider, (previous, next) {
      final wasLoading = previous?.isLoading ?? false;
      if (wasLoading && next.hasError && context.mounted) {
        TsToast.error(context, context.l10n.analysisLoadMatchesFailed);
      }
    });

    return matchesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: _InlineError(
              semantic: semantic,
              onRetry: () => ref.invalidate(baseballAnalysisMatchesProvider),
            ),
          ),
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
              padding: const EdgeInsets.symmetric(vertical: 48),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: PremiumAdWrapper(
              adUnitId: AdmobService.analysisBannerAdUnitId,
            ),
          );
        }

        final cardIndex = showAd && index > 1 ? index - 1 : index;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            cardIndex == 0 ? 0 : 8,
            16,
            cardIndex == itemCount - 1 ? 0 : 8,
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
      winRate: null,
      onAnalyze: () => context.push(
        '/analysis/baseball/match-report/${card.detailMatchId}',
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
