import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_combo_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/utils/access_gate.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/premium/combo/combo_parser.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/cards/analysis_card.dart';
import 'package:trendsoccer/shared/widgets/cards/premium_pick_stats_card.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_card.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_dashboard.dart';
import 'package:trendsoccer/shared/widgets/empty/network_error_widget.dart';
import 'package:trendsoccer/shared/widgets/empty/ts_empty_state.dart';
import 'package:trendsoccer/shared/widgets/toggle/sports_toggle.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  SportType _selectedSport = SportType.soccer;
  int _selectedComboDateIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedSport == SportType.baseball) {
        invalidateBaseballComboPicks(ref);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sportParam = GoRouterState.of(context).uri.queryParameters['sport'];
    if (sportParam == 'baseball' && _selectedSport != SportType.baseball) {
      setState(() {
        _selectedSport = SportType.baseball;
        _selectedComboDateIndex = 0;
      });
      invalidateBaseballComboPicks(ref);
    }
  }

  Future<void> _onRefresh() async {
    final date = ref.read(todayDateProvider);
    ref.invalidate(premiumPicksProvider(date));
    ref.invalidate(premiumPickStatsProvider);
    invalidateBaseballComboPicks(ref);

    await Future.wait([
      ref.read(premiumPicksProvider(date).future),
      ref.read(premiumPickStatsProvider.future),
      ref.read(baseballComboPicksProvider.future),
    ]);
  }

  Widget _wrapWithRefreshIndicator({required Widget child}) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: semantic.interactivePrimary,
      backgroundColor: semantic.surfaceBase,
      displacement: 40,
      edgeOffset: 0,
      child: child,
    );
  }

  Widget _buildSoccerSection(BuildContext context) {
    final l10n = context.l10n;
    final date = ref.watch(todayDateProvider);
    final picksAsync = ref.watch(premiumPicksProvider(date));

    return picksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => SizedBox.expand(
        child: Center(
          child: NetworkErrorWidget(
            message: l10n.premiumPickLoadFailed,
            onRetry: () => unawaited(_onRefresh()),
          ),
        ),
      ),
      data: (picks) {
        if (picks.isEmpty) {
          return Center(
            child: TsEmptyState(
              type: TsEmptyStateType.premiumPickEmpty,
              title: l10n.premiumNoHighConfidence,
              subtitle: l10n.emptyPremiumPickSubtitle,
            ),
          );
        }

        return _wrapWithRefreshIndicator(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PremiumPickStatsCard(showCTA: false),
                const SizedBox(height: TsSpacing.lg),
                ...picks.asMap().entries.map((entry) {
                  final card = entry.value;
                  final match = card.match;
                  final leagueId = leagueIdForCard(match.league);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < picks.length - 1 ? TsSpacing.lg : 0,
                    ),
                    child: AnalysisCard(
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
                        null,
                      ),
                      awayTeam: localizedTeamName(
                        context,
                        match.awayTeam.name,
                        null,
                      ),
                      matchTime: match.matchTime,
                      homeLogoUrl: match.homeTeam.logo,
                      awayLogoUrl: match.awayTeam.logo,
                      isPremiumPick: true,
                      pickDirection: pickDirectionFromCard(card),
                      winRate: winRateLabelFromCard(card),
                      onAnalyze: () => context.push(
                        '/analysis/soccer/match-report/${match.matchId}',
                        extra: MatchHeaderData.fromSoccerCard(card),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: TsSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBaseballSection(BuildContext context) {
    final l10n = context.l10n;
    final comboAsync = ref.watch(baseballComboPicksProvider);

    return comboAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => SizedBox.expand(
        child: Center(
          child: NetworkErrorWidget(
            message: l10n.premiumComboLoadFailed,
            onRetry: () => unawaited(_onRefresh()),
          ),
        ),
      ),
      data: (rawData) {
        final dashboard = ComboParser.parseDashboard(
          rawData,
          _selectedComboDateIndex,
          l10n,
        );
        final selectedDate = ComboParser.dateValueAt(_selectedComboDateIndex);
        final comboCards = ComboParser.parseComboCards(
          rawData,
          selectedDate,
          l10n,
        );
        final hasData = comboCards.isNotEmpty;

        return _wrapWithRefreshIndicator(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
            child: Column(
              children: [
                ComboDashboard(
                  dateTitle: dashboard.dateTitle,
                  comboCountText: dashboard.subtitle,
                  dateTabs: dashboard.dateChips,
                  selectedDateIndex: dashboard.selectedDateIndex,
                  onDateSelected: (i) => setState(() => _selectedComboDateIndex = i),
                  comboCount: dashboard.comboCount,
                  accuracy: dashboard.accuracy,
                  avgOdds: dashboard.avgOdds,
                  safeHitRate: dashboard.safeRate,
                  safeHitDetail: dashboard.safeRecord,
                  highOddsHitRate: dashboard.highRate,
                  highOddsHitDetail: dashboard.highRecord,
                ),
                const SizedBox(height: TsSpacing.lg),
                if (hasData)
                  ...comboCards.asMap().entries.map((entry) {
                    final combo = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: entry.key < comboCards.length - 1 ? TsSpacing.md : 0,
                      ),
                      child: ComboCard(
                        leagueId: combo.league.toLowerCase(),
                        comboCount:
                            ComboUiMapper.comboCountFromLabel(combo.comboCount),
                        comboType: ComboUiMapper.typeFromComboType(combo.comboType),
                        status: ComboUiMapper.statusFromType(combo.statusType),
                        matches: combo.matches
                            .map((m) => ComboUiMapper.toMatchRow(context, m))
                            .toList(),
                        aiSections: combo.aiSections,
                        totalOdds: combo.totalOdd.toStringAsFixed(2),
                        confidence: combo.reliability,
                      ),
                    );
                  })
                else
                  const TsEmptyState(type: TsEmptyStateType.defaultState),
                const SizedBox(height: TsSpacing.xl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBenefitRow(TsSemanticColors semantic, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          TsAssets.iconCheckSmall,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            semantic.interactivePrimary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: TsSpacing.md),
        Expanded(
          child: Text(
            text,
            style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final auth = ref.watch(authProvider);

    if (!AccessGate.canViewPremiumContent(planType: auth.planType)) {
      final l10n = context.l10n;
      return Scaffold(
        backgroundColor: semantic.surfaceRaised,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    TsAssets.iconPremium,
                    width: 80,
                    height: 80,
                    colorFilter: ColorFilter.mode(
                      semantic.interactivePrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: TsSpacing.xxl),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.premiumExclusiveShort,
                        style: TsType.displayHero.copyWith(
                          color: semantic.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TsSpacing.sm),
                      Text(
                        l10n.premiumSubscribeBenefitsLine1,
                        style: TsType.bodyLBold.copyWith(
                          color: semantic.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TsSpacing.sm),
                      Text(
                        l10n.premiumSubscribeAfter,
                        style: TsType.bodyLBold.copyWith(
                          color: semantic.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: TsSpacing.xxl),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(TsSpacing.lg),
                    decoration: BoxDecoration(
                      color: semantic.surfaceBase,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.premiumBenefitsTitle,
                          style: TsType.bodyLRegular.copyWith(
                            color: semantic.interactivePrimary,
                          ),
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        _buildBenefitRow(semantic, l10n.premiumBenefit24h),
                        const SizedBox(height: TsSpacing.lg),
                        _buildBenefitRow(
                          semantic,
                          l10n.premiumBenefitPremiumPick,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        _buildBenefitRow(
                          semantic,
                          l10n.premiumBenefitBaseballAi,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: TsButton(
                            label: l10n.premiumSubscribeNow,
                            variant: TsButtonVariant.primary,
                            onPressed: () => navigateToSubscribe(context, ref),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: semantic.surfaceRaised,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(TsSpacing.lg, TsSpacing.lg, TsSpacing.lg, 0),
            child: SportsToggle(
              selectedSport: _selectedSport,
              onChanged: (sport) {
                setState(() {
                  _selectedSport = sport;
                  _selectedComboDateIndex = 0;
                });
                if (sport == SportType.baseball) {
                  invalidateBaseballComboPicks(ref);
                }
              },
            ),
          ),
          // Matches [AnalysisPage]: SizedBox below SportsToggle before first body block.
          const SizedBox(height: TsSpacing.lg),
          if (_selectedSport == SportType.soccer)
            Expanded(child: _buildSoccerSection(context))
          else
            Expanded(child: _buildBaseballSection(context)),
        ],
      ),
    );
  }
}
