import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/premium/baseball_premium_tab.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/standard/baseball_standard_tab.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/report/match_header.dart';
import 'package:trendsoccer/shared/widgets/report/report_toggle.dart';
import 'package:trendsoccer/shared/widgets/subscribe_sheet.dart';

class BaseballMatchReportPage extends ConsumerStatefulWidget {
  const BaseballMatchReportPage({
    required this.matchId,
    this.initialHeader,
    super.key,
  });

  final String matchId;
  final MatchHeaderData? initialHeader;

  @override
  ConsumerState<BaseballMatchReportPage> createState() =>
      _BaseballMatchReportPageState();
}

class _BaseballMatchReportPageState
    extends ConsumerState<BaseballMatchReportPage> {
  ReportTab _selectedTab = ReportTab.standard;

  int? get _numericMatchId => int.tryParse(widget.matchId);

  int? get _apiMatchId => _numericMatchId;

  /// Route [matchId] is the api_match_id ([BaseballAnalysisCard.matchId]).
  MatchHeaderData _resolveHeader() {
    final matchId = _apiMatchId;
    final base = widget.initialHeader ??
        (matchId != null
            ? MatchHeaderData.placeholder(matchId: matchId)
            : MatchHeaderData.placeholder(matchId: 0));

    if (matchId == null) return base;

    final apiHeader = ref.watch(baseballMatchDetailProvider(matchId)).maybeWhen(
          data: (raw) => MatchHeaderData.fromBaseballStandardParsed(
            parseBaseballStandardDetail(raw),
            matchId: matchId,
          ),
          orElse: () => null,
        );

    return base.mergeWith(apiHeader);
  }

  Widget _buildStandardTab() {
    final matchId = _apiMatchId;
    if (matchId == null) {
      return Padding(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: BaseballStandardTabError(onRetry: () {}),
      );
    }
    return BaseballStandardTab(matchId: matchId);
  }

  Widget _buildPremiumTab() {
    final matchId = _apiMatchId;
    if (matchId == null) {
      return Padding(
        padding: const EdgeInsets.all(TsSpacing.lg),
        child: BaseballPremiumTabError(onRetry: () {}),
      );
    }
    return BaseballPremiumTab(matchId: matchId);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[BASEBALL] Match report page: api_match_id=${widget.matchId}');
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final header = _resolveHeader();

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
              leagueId: header.resolvedLeagueIconId,
              leagueName: header.leagueName,
              leagueLogoUrl: header.leagueLogo,
              matchDate: header.displayDate,
              homeTeam: header.homeTeam,
              awayTeam: header.awayTeam,
              homeLogoUrl: header.homeTeamLogo,
              awayLogoUrl: header.awayTeamLogo,
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
                  : _buildPremiumTab(),
            ),
          ],
        ),
      ),
    );
  }
}
