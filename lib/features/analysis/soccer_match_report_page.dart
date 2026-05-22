import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/soccer_analysis_parser.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/premium/soccer_premium_tab.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/soccer_standard_tab.dart';
import 'package:trendsoccer/shared/widgets/appbar/ts_app_bar.dart';
import 'package:trendsoccer/shared/widgets/report/match_header.dart';
import 'package:trendsoccer/shared/widgets/report/report_toggle.dart';
import 'package:trendsoccer/shared/widgets/subscribe_sheet.dart';

class SoccerMatchReportPage extends ConsumerStatefulWidget {
  const SoccerMatchReportPage({
    required this.matchId,
    this.initialHeader,
    this.matchTimestampUtc,
    super.key,
  });

  final String matchId;
  final MatchHeaderData? initialHeader;
  final DateTime? matchTimestampUtc;

  @override
  ConsumerState<SoccerMatchReportPage> createState() =>
      _SoccerMatchReportPageState();
}

class _SoccerMatchReportPageState extends ConsumerState<SoccerMatchReportPage> {
  ReportTab _selectedTab = ReportTab.standard;

  int? get _numericMatchId => int.tryParse(widget.matchId);

  MatchHeaderData _resolveHeader() {
    final matchId = _numericMatchId;
    return widget.initialHeader ??
        (matchId != null
            ? MatchHeaderData.placeholder(matchId: matchId)
            : MatchHeaderData.placeholder(matchId: 0));
  }

  SoccerAnalysisParams? _buildParams(MatchHeaderData header) {
    if (!header.hasAnalysisMetadata) return null;
    return SoccerAnalysisParams.fromHeader(header);
  }

  Widget _buildMissingHeaderError() {
    return const KeyedSubtree(
      key: ValueKey<Object>('soccer_report_missing_header'),
      child: Padding(
        padding: EdgeInsets.all(TsSpacing.lg),
        child: _MissingHeaderState(),
      ),
    );
  }

  Widget _buildPremiumTab(SoccerAnalysisParams params) {
    return SoccerPremiumTab(params: params);
  }

  Widget _buildStandardTab(SoccerAnalysisParams params, MatchHeaderData header) {
    final predictionAsync = ref.watch(soccerPredictionProvider(params));
    final planType = ref.watch(authProvider).planType;
    final matchTimestamp =
        header.matchTimestamp ?? widget.matchTimestampUtc;

    return predictionAsync.when(
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
            onRetry: () => ref.invalidate(soccerPredictionProvider(params)),
          ),
        ),
      ),
      data: (raw) {
        final parsed = parseSoccerStandardAnalysis(
          raw,
          fallbackMatchTimestamp: matchTimestamp,
          headerFallback: header,
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
    final header = _resolveHeader();
    final params = _buildParams(header);

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
              child: params == null
                  ? _buildMissingHeaderError()
                  : _selectedTab == ReportTab.standard
                      ? _buildStandardTab(params, header)
                      : _buildPremiumTab(params),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingHeaderState extends StatelessWidget {
  const _MissingHeaderState();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '경기 정보가 없습니다',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            '분석 페이지에서 경기를 선택해 주세요.',
            style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
