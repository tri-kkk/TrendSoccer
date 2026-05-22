import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/baseball_match_report_data.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/premium/baseball_ai_tab.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/baseball_standard_tab.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/report/match_header.dart';
import 'package:trendsoccer/shared/widgets/report/report_toggle.dart';
import 'package:trendsoccer/shared/widgets/subscribe_sheet.dart';

class BaseballMatchReportPage extends ConsumerStatefulWidget {
  const BaseballMatchReportPage({
    required this.matchId,
    super.key,
  });

  final String matchId;

  @override
  ConsumerState<BaseballMatchReportPage> createState() =>
      _BaseballMatchReportPageState();
}

class _BaseballMatchReportPageState
    extends ConsumerState<BaseballMatchReportPage> {
  ReportTab _selectedTab = ReportTab.standard;

  int? get _numericMatchId => int.tryParse(widget.matchId);

  BaseballMatchReportData get _headerFallbackSource => baseballMatchReportDummy;

  Widget _buildStandardTab() {
    final matchId = _numericMatchId;
    if (matchId == null) {
      return Padding(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: BaseballStandardTabError(onRetry: () {}),
      );
    }
    return BaseballStandardTab(matchId: matchId);
  }

  Widget _buildAiTab() {
    final matchId = _numericMatchId;
    if (matchId == null) {
      return Padding(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: BaseballAiTabError(onRetry: () {}),
      );
    }
    return BaseballAiTab(matchId: matchId);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final headerFallback =
        baseballStandardHeaderFallback(_headerFallbackSource);

    final matchId = _numericMatchId;
    final headerParsed = matchId != null
        ? ref.watch(baseballMatchDetailProvider(matchId)).maybeWhen(
              data: (raw) => parseBaseballStandardDetail(raw),
              orElse: () => headerFallback,
            )
        : headerFallback;

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
                    showSubscribeSheet(context, SportType.baseball);
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
                  : _buildAiTab(),
            ),
          ],
        ),
      ),
    );
  }
}
