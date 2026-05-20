import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/soccer_analysis_parser.dart';
import 'package:trendsoccer/features/analysis/models/soccer_match_report_data.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/premium/soccer_premium_tab.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/soccer_standard_tab.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/report/match_header.dart';
import 'package:trendsoccer/shared/widgets/report/report_toggle.dart';
import 'package:trendsoccer/shared/widgets/subscribe_sheet.dart';

class SoccerMatchReportPage extends ConsumerStatefulWidget {
  const SoccerMatchReportPage({
    required this.matchId,
    this.matchTimestampUtc,
    super.key,
  });

  final String matchId;
  final DateTime? matchTimestampUtc;

  @override
  ConsumerState<SoccerMatchReportPage> createState() =>
      _SoccerMatchReportPageState();
}

class _SoccerMatchReportPageState extends ConsumerState<SoccerMatchReportPage> {
  ReportTab _selectedTab = ReportTab.standard;

  int? get _numericMatchId => int.tryParse(widget.matchId);

  SoccerMatchReportData get _headerFallback => soccerMatchReportDummy;

  Widget _buildPremiumTab() {
    final matchId = _numericMatchId;
    if (matchId == null) {
      return KeyedSubtree(
        key: const ValueKey<Object>('soccer_report_premium_invalid'),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: SoccerStandardTabError(onRetry: () {}),
        ),
      );
    }
    return SoccerPremiumTab(matchId: matchId);
  }

  Widget _buildStandardTab() {
    final matchId = _numericMatchId;
    if (matchId == null) {
      return SoccerStandardTabError(onRetry: () {});
    }

    final analysisAsync = ref.watch(soccerAnalysisProvider(matchId));
    final planType = ref.watch(authProvider).planType;

    return analysisAsync.when(
      loading: () => const KeyedSubtree(
        key: ValueKey<Object>('soccer_report_standard_loading'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: SoccerStandardTabLoading(),
        ),
      ),
      error: (error, stackTrace) => KeyedSubtree(
        key: const ValueKey<Object>('soccer_report_standard_error'),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: SoccerStandardTabError(
            onRetry: () => ref.invalidate(soccerAnalysisProvider(matchId)),
          ),
        ),
      ),
      data: (raw) {
        final parsed = parseSoccerStandardAnalysis(
          raw,
          fallbackMatchTimestamp: widget.matchTimestampUtc,
        );
        return KeyedSubtree(
          key: const ValueKey<Object>('soccer_report_standard'),
          child: Padding(
            padding: const EdgeInsets.all(TsSpacing.lg),
            child: SoccerStandardTabHost(
              parsed: parsed,
              planType: planType,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final headerFallback = _headerFallback;

    final matchId = _numericMatchId;
    final headerParsed = matchId != null
        ? ref.watch(soccerAnalysisProvider(matchId)).maybeWhen(
              data: (raw) => parseSoccerStandardAnalysis(
                raw,
                fallbackMatchTimestamp: widget.matchTimestampUtc,
              ),
              orElse: () => fallbackFromDummy(headerFallback),
            )
        : fallbackFromDummy(headerFallback);

    return Scaffold(
      backgroundColor: semantic.surfaceBase,
      appBar: TsAppBar.preferred(
        context,
        location: TsAppBarLocation.backTitle,
        title: '매치 리포트',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: TsSpacing.lg + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          children: [
            MatchHeader(
              leagueId: headerParsed.leagueId,
              matchDate: headerParsed.matchDateDisplay,
              homeTeam: headerParsed.homeTeam,
              awayTeam: headerParsed.awayTeam,
              homeLogoUrl: headerParsed.homeLogoUrl,
              awayLogoUrl: headerParsed.awayLogoUrl,
              selectedTab: _selectedTab,
              onTabChanged: (tab) {
                if (tab == ReportTab.premium) {
                  if (!ref.read(authProvider).hasFullAccess) {
                    showSubscribeSheet(context, SportType.soccer);
                    return;
                  }
                }
                setState(() => _selectedTab = tab);
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _selectedTab == ReportTab.standard
                  ? _buildStandardTab()
                  : _buildPremiumTab(),
            ),
          ],
        ),
      ),
    );
  }
}
