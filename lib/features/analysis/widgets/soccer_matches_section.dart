import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/features/analysis/analysis_layout_dummy.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
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

class SoccerMatchesSection extends ConsumerWidget {
  const SoccerMatchesSection({
    required this.dateStr,
    super.key,
  });

  final String dateStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final selectedLeague = ref.watch(selectedLeagueProvider);
    final matchesAsync = ref.watch(analysisSoccerMatchesProvider);

    ref.listen(analysisSoccerMatchesProvider, (previous, next) {
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
              onRetry: () {
                clearSoccerAnalysisEmptyCache();
                ref.invalidate(analysisSoccerMatchesProvider);
              },
            ),
          ),
        ),
      ),
      data: (matches) {
        final filtered = filterSoccerAnalysisMatches(
          matches,
          dateStr,
          selectedLeague,
        );

        if (filtered.isEmpty) {
          if (AnalysisLayoutDummy.enabled) {
            final dummyMatches =
                AnalysisLayoutDummy.getSoccerMatches(dateStr);
            if (dummyMatches.isNotEmpty) {
              return _buildMatchesSliver(
                ref: ref,
                itemCount: dummyMatches.length,
                cardBuilder: (index) =>
                    _LayoutDummySoccerCard(data: dummyMatches[index]),
              );
            }
          }

          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
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

class _LayoutDummySoccerCard extends StatelessWidget {
  const _LayoutDummySoccerCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final matchDate = data['matchDate']?.toString() ?? '';

    return AnalysisCard(
      leagueId: data['leagueCode']?.toString() ?? '',
      leagueName: localizedLeagueName(
        context,
        data['leagueName']?.toString(),
        data['leagueNameKo']?.toString() ?? data['leagueName']?.toString() ?? '',
      ),
      date: matchDate,
      homeTeam: localizedTeamName(
        context,
        data['homeTeam']?.toString() ?? '',
        data['homeTeamKo']?.toString(),
      ),
      awayTeam: localizedTeamName(
        context,
        data['awayTeam']?.toString() ?? '',
        data['awayTeamKo']?.toString(),
      ),
      matchTime: data['matchTime']?.toString() ?? '',
      alwaysActiveAnalyzeButton: true,
      isPremiumPick: false,
      pickDirection: null,
      winRate: null,
      onAnalyze: () {},
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
