import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/reports/reports_analysis_kickoff.dart';
import 'package:trendsoccer/features_v2/reports/reports_analysis_logic.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_scope.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

mixin _ReportsAnalysisRollForward<T extends StatefulWidget> on State<T> {
  Timer? _rollTimer;

  @override
  void initState() {
    super.initState();
    _rollTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    super.dispose();
  }
}

class ReportsSoccerAnalysisBody extends ConsumerStatefulWidget {
  const ReportsSoccerAnalysisBody({super.key});

  @override
  ConsumerState<ReportsSoccerAnalysisBody> createState() =>
      _ReportsSoccerAnalysisBodyState();
}

class _ReportsSoccerAnalysisBodyState extends ConsumerState<ReportsSoccerAnalysisBody>
    with _ReportsAnalysisRollForward {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final headerScope = ReportsHeaderScope.of(context);
    final selectedLeagueId = headerScope.selectedLeagueId;
    final matchesAsync = ref.watch(analysisSoccerMatchesProvider);

    return matchesAsync.when(
      loading: () => _loadingList(),
      error: (_, _) => _centeredEmptyList(
        TsEmptyState(
          type: TsEmptyType.failure,
          title: l10n.analysisLoadMatchesFailed,
          description: l10n.analysisLoadFailed,
          actionLabel: l10n.retry,
          onAction: () {
            clearSoccerAnalysisEmptyCache();
            ref.invalidate(analysisSoccerMatchesProvider);
          },
        ),
      ),
      data: (matches) {
        final unfiltered = filterReportsSoccerAnalysisList(matches, null);
        if (unfiltered.isEmpty) {
          return _centeredEmptyList(
            TsEmptyState(
              title: l10n.analysisNoMatches,
              description: '',
            ),
          );
        }

        final filtered =
            filterReportsSoccerAnalysisList(matches, selectedLeagueId);
        if (filtered.isEmpty) {
          return _centeredEmptyList(
            TsEmptyState(
              type: TsEmptyType.withAction,
              title: l10n.reportsAnalysisNoLeagueTitle,
              description: l10n.reportsAnalysisNoLeagueBody,
              actionLabel: l10n.reportsAnalysisViewAll,
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
              hasAnalysis: false,
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

class ReportsBaseballAnalysisBody extends ConsumerStatefulWidget {
  const ReportsBaseballAnalysisBody({super.key});

  @override
  ConsumerState<ReportsBaseballAnalysisBody> createState() =>
      _ReportsBaseballAnalysisBodyState();
}

class _ReportsBaseballAnalysisBodyState
    extends ConsumerState<ReportsBaseballAnalysisBody>
    with _ReportsAnalysisRollForward {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final headerScope = ReportsHeaderScope.of(context);
    final selectedLeagueId = headerScope.selectedLeagueId;
    final matchesAsync = ref.watch(baseballAnalysisMatchesProvider);

    return matchesAsync.when(
      loading: () => _loadingList(),
      error: (_, _) => _centeredEmptyList(
        TsEmptyState(
          type: TsEmptyType.failure,
          title: l10n.analysisLoadMatchesFailed,
          description: l10n.analysisLoadFailed,
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(baseballAnalysisMatchesProvider),
        ),
      ),
      data: (matches) {
        final unfiltered = filterReportsBaseballAnalysisList(matches, null);
        if (unfiltered.isEmpty) {
          return _centeredEmptyList(
            TsEmptyState(
              title: l10n.analysisNoBaseballScheduled,
              description: '',
            ),
          );
        }

        final filtered =
            filterReportsBaseballAnalysisList(matches, selectedLeagueId);
        if (filtered.isEmpty) {
          return _centeredEmptyList(
            TsEmptyState(
              type: TsEmptyType.withAction,
              title: l10n.reportsAnalysisNoLeagueTitle,
              description: l10n.reportsAnalysisNoLeagueBody,
              actionLabel: l10n.reportsAnalysisViewAll,
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
            final kickoffLocal = card.matchTimestamp.toLocal();
            final leagueCode = card.league;
            final leagueId = baseballLeagueIconId(leagueCode);
            return TsMatchCard(
              leagueId: leagueId,
              leagueLabel: TsAssets.leagueDisplayName(leagueCode),
              kickoffLabel: reportsAnalysisKickoffLabel(locale, kickoffLocal),
              homeTeam: localizedTeamName(
                context,
                card.homeTeam,
                card.homeTeamKo,
              ),
              awayTeam: localizedTeamName(
                context,
                card.awayTeam,
                card.awayTeamKo,
              ),
              homeEmblemUrl: card.homeTeamLogo,
              awayEmblemUrl: card.awayTeamLogo,
              hasAnalysis: false,
              onTap: () => context.push(
                '/matches/baseball/${card.matchId}',
                extra: MatchHeaderData.fromBaseballCard(card),
              ),
            );
          },
        );
      },
    );
  }
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
