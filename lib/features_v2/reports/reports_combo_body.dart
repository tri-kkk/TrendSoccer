import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/baseball_combo_parsed.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_combo_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_summary_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/reports/reports_combo_logic.dart';
import 'package:trendsoccer/features_v2/reports/reports_header_scope.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class ReportsComboBody extends ConsumerStatefulWidget {
  const ReportsComboBody({super.key});

  @override
  ConsumerState<ReportsComboBody> createState() => _ReportsComboBodyState();
}

class _ReportsComboBodyState extends ConsumerState<ReportsComboBody> {
  final ScrollController _scrollController = ScrollController();
  DateTime? _trackedDate;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListToTopIfDateChanged(DateTime selectedDate) {
    if (_trackedDate != null && _trackedDate != selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
    _trackedDate = selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final headerScope = ReportsHeaderScope.of(context);
    final selectedLeagueId = headerScope.selectedLeagueId;
    final selectedDate = headerScope.selectedDate;
    _scrollListToTopIfDateChanged(selectedDate);
    final selectedDateKey = reportsComboDateKey(selectedDate);
    final hasFullAccess = ref.watch(authProvider).hasFullAccess;
    final combosAsync = ref.watch(baseballComboPicksProvider);

    Future<void> onRefresh() async {
      ref.invalidate(baseballComboPicksProvider);
      await ref.read(baseballComboPicksProvider.future);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: combosAsync.when(
        loading: () => _loadingList(_scrollController),
        error: (_, _) => _centeredEmptyList(
          TsEmptyState(
            type: TsEmptyType.failure,
            title: l10n.premiumComboLoadFailed,
            description: l10n.analysisLoadFailed,
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(baseballComboPicksProvider),
          ),
        ),
        data: (raw) {
          final combos = parseBaseballComboPicks(raw);
          final byDate =
              filterReportsComboList(combos, selectedDateKey, null);
          if (byDate.isEmpty) {
            return _centeredEmptyList(
              TsEmptyState(
                title: l10n.reportsComboEmptyTitle,
                description: l10n.reportsComboEmptyBody,
              ),
            );
          }

          final filtered = filterReportsComboList(
            combos,
            selectedDateKey,
            selectedLeagueId,
          );
          if (filtered.isEmpty) {
            return _centeredEmptyList(
              TsEmptyState(
                type: TsEmptyType.withAction,
                title: l10n.reportsComboNoLeagueTitle,
                description: l10n.reportsComboNoLeagueBody,
                actionLabel: l10n.reportsComboViewAll,
                onAction: headerScope.clearLeagueSelection,
              ),
            );
          }

          return ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              TsSpacing.lg,
              0,
              TsSpacing.lg,
              TsSpacing.xl,
            ),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.md),
            itemBuilder: (context, index) {
              final combo = filtered[index];
              return _ReportsComboCard(
                combo: combo,
                locked: !hasFullAccess,
                onTap: _reportsComboCardOnTap(context, ref, combo),
              );
            },
          );
        },
      ),
    );
  }
}

VoidCallback? _reportsComboCardOnTap(
  BuildContext context,
  WidgetRef ref,
  BaseballComboParsed combo,
) {
  if (combo.id == null) return null;

  final auth = ref.read(authProvider);
  if (auth.hasFullAccess) {
    return () => context.push(
          '/reports/combo/${combo.id}',
          extra: combo,
        );
  }
  if (auth.isGuest) {
    return () => context.push('/login');
  }
  return () => context.go('/menu/subscribe');
}

class _ReportsComboCard extends StatelessWidget {
  const _ReportsComboCard({
    required this.combo,
    required this.locked,
    this.onTap,
  });

  final BaseballComboParsed combo;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leagueCode = combo.league ?? '';
    final card = TsComboSummaryCard(
      leagueIcon: TsLeagueIcon(
        baseballLeagueIconId(leagueCode),
        size: TsIconSize.md,
      ),
      leagueLabel: reportsComboLeagueLabel(context, combo.league),
      typeBadgeLabel: reportsComboTypeBadgeLabel(l10n, combo),
      matchups: [
        for (final leg in combo.legs) reportsComboMatchup(context, leg),
      ],
      totalIndexLabel: reportsComboTotalIndexLabel(combo.totalOdds),
      confidenceLabel: reportsComboConfidenceLabel(combo.avgConfidence),
      locked: locked,
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

Widget _loadingList(ScrollController scrollController) {
  return ListView.separated(
    controller: scrollController,
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(
      TsSpacing.lg,
      0,
      TsSpacing.lg,
      TsSpacing.xl,
    ),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: TsSpacing.md),
    itemBuilder: (_, _) => const TsSkeletonBlock(TsSkeletonType.block),
  );
}

Widget _centeredEmptyList(Widget empty) {
  return CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
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
