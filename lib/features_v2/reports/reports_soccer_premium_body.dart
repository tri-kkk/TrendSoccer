import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/pick_direction.dart';
import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/reports/reports_analysis_kickoff.dart';
import 'package:trendsoccer/features_v2/reports/reports_analysis_logic.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_scope.dart';
import 'package:trendsoccer/features_v2/reports/reports_premium_logic.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class ReportsSoccerPremiumBody extends ConsumerWidget {
  const ReportsSoccerPremiumBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final headerScope = ReportsHeaderScope.of(context);
    final selectedLeagueId = headerScope.selectedLeagueId;
    final hasFullAccess = ref.watch(authProvider).hasFullAccess;
    final date = ref.watch(todayDateProvider);
    final picksAsync = ref.watch(premiumPicksProvider(date));

    return picksAsync.when(
      loading: () => _loadingList(),
      error: (_, _) => _centeredEmptyList(
        TsEmptyState(
          type: TsEmptyType.failure,
          title: l10n.analysisLoadMatchesFailed,
          description: l10n.analysisLoadFailed,
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(premiumPicksProvider(date)),
        ),
      ),
      data: (picks) {
        if (picks.isEmpty) {
          return _centeredEmptyList(
            TsEmptyState(
              title: l10n.reportsPremiumEmptyTitle,
              description: l10n.reportsPremiumEmptyBody,
            ),
          );
        }

        final filtered =
            filterReportsPremiumPicksList(picks, selectedLeagueId);
        if (filtered.isEmpty) {
          return _centeredEmptyList(
            TsEmptyState(
              type: TsEmptyType.withAction,
              title: l10n.reportsPremiumNoLeagueTitle,
              description: l10n.reportsPremiumNoLeagueBody,
              actionLabel: l10n.reportsPremiumViewAll,
              onAction: headerScope.clearLeagueSelection,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            TsSpacing.lg,
            0,
            TsSpacing.lg,
            TsSpacing.xl,
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.sm),
          itemBuilder: (context, index) {
            final card = filtered[index];
            final match = card.match;
            final kickoffLocal =
                soccerAnalysisKickoffLocal(card) ?? DateTime.now();
            final leagueId = leagueIdForCard(match.league);
            final pickLabel = _premiumPickLabel(context, card);
            return TsMatchCard(
              leagueId: leagueId,
              leagueLabel: localizedLeagueName(
                context,
                match.league.nameEn,
                match.league.name,
              ),
              kickoffLabel: reportsAnalysisKickoffLabel(locale, kickoffLocal),
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
              homeEmblemUrl: match.homeTeam.logo,
              awayEmblemUrl: match.awayTeam.logo,
              density: TsMatchCardDensity.list,
              hasAnalysis: false,
              pickLabel: pickLabel,
              probabilityLabel: winRateLabelFromCard(card),
              locked: !hasFullAccess,
              onTap: () => context.push(
                '/matches/soccer/${match.matchId}',
                extra: MatchHeaderData.fromSoccerCard(card),
              ),
            );
          },
        );
      },
    );
  }
}

String? _premiumPickLabel(BuildContext context, SoccerAnalysisCard card) {
  final direction = pickDirectionFromCard(card);
  if (direction == null) return null;
  final l10n = AppLocalizations.of(context)!;
  return switch (direction) {
    PickDirection.home => l10n.pickDirectionHome,
    PickDirection.draw => l10n.pickDirectionDraw,
    PickDirection.away => l10n.pickDirectionAway,
  };
}

Widget _loadingList() {
  return ListView.separated(
    padding: const EdgeInsets.fromLTRB(
      TsSpacing.lg,
      0,
      TsSpacing.lg,
      TsSpacing.xl,
    ),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.sm),
    itemBuilder: (_, _) => const TsSkeletonBlock(TsSkeletonType.block),
  );
}

Widget _centeredEmptyList(Widget empty) {
  return CustomScrollView(
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: empty,
          ),
        ),
      ),
    ],
  );
}
