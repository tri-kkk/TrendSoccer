import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/access_gate.dart';
import 'package:trendsoccer/features/analysis/models/soccer_premium_parser.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/premium/premium_sections.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/soccer_standard_tab.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/premium/section_title.dart';

class SoccerPremiumTab extends ConsumerWidget {
  const SoccerPremiumTab({
    required this.matchId,
    super.key,
  });

  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planType = ref.watch(authProvider).planType;
    final canView = AccessGate.canViewPremiumContent(planType: planType);

    if (!canView) {
      return const KeyedSubtree(
        key: ValueKey<Object>('soccer_report_premium_locked'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: _PremiumLockedState(),
        ),
      );
    }

    final premiumAsync = ref.watch(soccerPremiumProvider(matchId));

    return premiumAsync.when(
      loading: () => const KeyedSubtree(
        key: ValueKey<Object>('soccer_report_premium_loading'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: _PremiumTabLoading(),
        ),
      ),
      error: (error, stackTrace) => KeyedSubtree(
        key: const ValueKey<Object>('soccer_report_premium_error'),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: SoccerStandardTabError(
            onRetry: () => ref.invalidate(soccerPremiumProvider(matchId)),
          ),
        ),
      ),
      data: (raw) {
        final parsed = SoccerPremiumParsed.fromMap(raw);
        return KeyedSubtree(
          key: const ValueKey<Object>('soccer_report_premium'),
          child: Padding(
            padding: const EdgeInsets.all(TsSpacing.lg),
            child: _PremiumContent(parsed: parsed),
          ),
        );
      },
    );
  }
}

class _PremiumLockedState extends ConsumerWidget {
  const _PremiumLockedState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '프리미엄 전용 분석',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.sm),
        Text(
          'H2H 심층 분석과 팀 인사이트는 프리미엄 구독 후 이용할 수 있습니다.',
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.xl),
        TsButton(
          label: '지금 구독하기',
          variant: TsButtonVariant.primary,
          onPressed: () => navigateToSubscribe(context, ref),
        ),
      ],
    );
  }
}

class _PremiumTabLoading extends StatelessWidget {
  const _PremiumTabLoading();

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: semantic.interactivePrimary),
          const SizedBox(height: TsSpacing.lg),
          Text(
            '프리미엄 분석 로딩 중...',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PremiumContent extends StatelessWidget {
  const _PremiumContent({required this.parsed});

  final SoccerPremiumParsed parsed;

  @override
  Widget build(BuildContext context) {
    final stats = parsed.h2hStats;
    final home = parsed.homeAnalysis;
    final away = parsed.awayAnalysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (parsed.h2h.isNotEmpty) ...[
          _H2HRecordsSection(records: parsed.h2h),
          const SizedBox(height: 16),
        ],
        H2HSection(
          totalMatches: stats.totalMatches,
          homeWins: stats.homeWins,
          draws: stats.draws,
          awayWins: stats.awayWins,
          recentMeetings: parsed.recentMeetings,
          avgGoals: stats.avgGoals,
          over25: stats.over25,
          over25Highlight: stats.over25Highlight,
          btts: stats.btts,
          mostCommonScores: parsed.mostCommonScoresForSection,
          insights: parsed.h2hInsights,
        ),
        const SizedBox(height: 16),
        TeamAnalysisSection(
          title: home.title,
          last10Label: home.last10Label,
          wins: home.wins10,
          draws: home.draws10,
          losses: home.losses10,
          recentForm: home.recentForm,
          recordWins: home.recordWins,
          recordDraws: home.recordDraws,
          recordLosses: home.recordLosses,
          winRate: home.winRate,
          goalLineO15: home.goalLineO15,
          goalLineO15Highlight: home.goalLineO15Highlight,
          goalLineO25: home.goalLineO25,
          goalLineO25Highlight: home.goalLineO25Highlight,
          goalLineO35: home.goalLineO35,
          goalLineO35Highlight: home.goalLineO35Highlight,
          marketO25: home.marketO25,
          marketO25Highlight: home.marketO25Highlight,
          marketBtts: home.marketBtts,
          marketBttsHighlight: home.marketBttsHighlight,
          marketCs: home.marketCs,
          marketFts: home.marketFts,
          teamInsights: home.teamInsights,
        ),
        const SizedBox(height: 16),
        TeamAnalysisSection(
          title: away.title,
          last10Label: away.last10Label,
          wins: away.wins10,
          draws: away.draws10,
          losses: away.losses10,
          recentForm: away.recentForm,
          recordWins: away.recordWins,
          recordDraws: away.recordDraws,
          recordLosses: away.recordLosses,
          winRate: away.winRate,
          goalLineO15: away.goalLineO15,
          goalLineO15Highlight: away.goalLineO15Highlight,
          goalLineO25: away.goalLineO25,
          goalLineO25Highlight: away.goalLineO25Highlight,
          goalLineO35: away.goalLineO35,
          goalLineO35Highlight: away.goalLineO35Highlight,
          marketO25: away.marketO25,
          marketO25Highlight: away.marketO25Highlight,
          marketBtts: away.marketBtts,
          marketBttsHighlight: away.marketBttsHighlight,
          marketCs: away.marketCs,
          marketFts: away.marketFts,
          teamInsights: away.teamInsights,
        ),
        const SizedBox(height: TsSpacing.xl),
      ],
    );
  }
}

class _H2HRecordsSection extends StatefulWidget {
  const _H2HRecordsSection({required this.records});

  final List<H2HMatchRecord> records;

  @override
  State<_H2HRecordsSection> createState() => _H2HRecordsSectionState();
}

class _H2HRecordsSectionState extends State<_H2HRecordsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CardSectionTitle(
            title: '맞대결 기록',
            isExpanded: _isExpanded,
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: semantic.surfaceOverlay,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < widget.records.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _H2HRecordRow(record: widget.records[i], semantic: semantic),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _H2HRecordRow extends StatelessWidget {
  const _H2HRecordRow({
    required this.record,
    required this.semantic,
  });

  final H2HMatchRecord record;
  final TsSemanticColors semantic;

  @override
  Widget build(BuildContext context) {
    final dateLabel = record.date.isEmpty ? '-' : record.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          dateLabel,
          style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                record.homeTeam,
                style: TsType.bodyMRegular.copyWith(color: semantic.textPrimary),
              ),
            ),
            Text(
              record.scoreDisplay,
              style: TsType.bodyMBold.copyWith(color: semantic.interactivePrimary),
            ),
            Expanded(
              child: Text(
                record.awayTeam,
                textAlign: TextAlign.end,
                style: TsType.bodyMRegular.copyWith(color: semantic.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
