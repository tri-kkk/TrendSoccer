import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/baseball_combo_parsed.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_combo_provider.dart';
import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/features_v2/reports/combo_detail_logic.dart';
import 'package:trendsoccer/features_v2/reports/reports_combo_logic.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class ComboDetailScreen extends ConsumerStatefulWidget {
  const ComboDetailScreen({required this.comboId, super.key});

  final String comboId;

  @override
  ConsumerState<ComboDetailScreen> createState() => _ComboDetailScreenState();
}

class _ComboDetailScreenState extends ConsumerState<ComboDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    ref.watch(languageProvider);

    if (!auth.hasFullAccess) {
      return _shell(
        context,
        l10n,
        body: _lockedEmptyState(context, l10n, auth),
      );
    }

    final routeExtra = GoRouterState.of(context).extra;
    final routeExtraCombo = routeExtra is BaseballComboParsed &&
            reportsComboDetailIdMatches(routeExtra.id, widget.comboId)
        ? routeExtra
        : null;

    final combosAsync = ref.watch(baseballComboPicksProvider);
    if (combosAsync.hasValue) {
      final combo = reportsComboDetailFindInCache(
            combosAsync.value!,
            widget.comboId,
          ) ??
          routeExtraCombo;
      if (combo != null) {
        return _shell(
          context,
          l10n,
          body: _detailBody(context, l10n, combo),
        );
      }

      return _shell(
        context,
        l10n,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: TsEmptyState(
              title: l10n.comboNotFound,
              description: '',
            ),
          ),
        ),
      );
    }

    return combosAsync.when(
      loading: () => _shell(
        context,
        l10n,
        body: const Center(child: TsSkeletonBlock(TsSkeletonType.block)),
      ),
      error: (_, _) => _shell(
        context,
        l10n,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: TsEmptyState(
              type: TsEmptyType.failure,
              title: l10n.premiumComboLoadFailed,
              description: l10n.analysisLoadFailed,
              actionLabel: l10n.retry,
              onAction: () => ref.invalidate(baseballComboPicksProvider),
            ),
          ),
        ),
      ),
      data: (raw) {
        final combo = reportsComboDetailFindInCache(raw, widget.comboId) ??
            routeExtraCombo;
        if (combo == null) {
          return _shell(
            context,
            l10n,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
                child: TsEmptyState(
                  title: l10n.comboNotFound,
                  description: '',
                ),
              ),
            ),
          );
        }

        return _shell(
          context,
          l10n,
          body: _detailBody(context, l10n, combo),
        );
      },
    );
  }

  Widget _lockedEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    SupabaseAuthProvider auth,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        child: TsEmptyState(
          type: TsEmptyType.withAction,
          title: l10n.reportsComboLockedTitle,
          description: l10n.reportsComboLockedBody,
          actionLabel:
              auth.isGuest ? l10n.authLogIn : l10n.subscribeNow,
          onAction: () {
            if (auth.isGuest) {
              context.push('/login');
            } else {
              context.push('/menu/subscribe');
            }
          },
        ),
      ),
    );
  }

  Widget _shell(
    BuildContext context,
    AppLocalizations l10n, {
    required Widget body,
  }) {
    return Scaffold(
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: l10n.reportsComboDetailTitle,
        onBack: () => context.pop(),
      ),
      body: body,
    );
  }

  Widget _detailBody(
    BuildContext context,
    AppLocalizations l10n,
    BaseballComboParsed combo,
  ) {
    final aiReport = reportsComboDetailAiReportData(context, l10n, combo);
    final leagueCode = combo.league ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        TsSpacing.lg,
        0,
        TsSpacing.lg,
        TsSpacing.xl,
      ),
      child: TsComboCard(
        leagueIcon: TsLeagueIcon(
          baseballLeagueIconId(leagueCode),
          size: TsIconSize.md,
        ),
        leagueLabel: reportsComboLeagueLabel(context, combo.league),
        typeBadgeLabel: reportsComboTypeBadgeLabel(l10n, combo),
        legs: reportsComboDetailLegs(context, l10n, combo),
        totalIndexLabel: reportsComboTotalIndexLabel(combo.totalOdds),
        confidenceLabel: reportsComboConfidenceLabel(combo.avgConfidence),
        result: reportsComboDetailOutcome(combo.legs),
        aiReport: aiReport,
      ),
    );
  }
}
