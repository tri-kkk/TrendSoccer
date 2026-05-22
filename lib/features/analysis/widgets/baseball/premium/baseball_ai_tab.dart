import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/access_gate.dart';
import 'package:trendsoccer/features/analysis/models/baseball_ai_parser.dart';
import 'package:trendsoccer/features/analysis/widgets/baseball/premium/premium_sections.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/report/ratio_bar.dart';

class BaseballAiTab extends ConsumerWidget {
  const BaseballAiTab({
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
        key: ValueKey<Object>('baseball_report_ai_locked'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: _AiLockedState(),
        ),
      );
    }

    final aiAsync = ref.watch(baseballAiAnalysisProvider(matchId));

    return aiAsync.when(
      loading: () => const KeyedSubtree(
        key: ValueKey<Object>('baseball_report_ai_loading'),
        child: Padding(
          padding: EdgeInsets.all(TsSpacing.lg),
          child: BaseballAiTabLoading(),
        ),
      ),
      error: (error, stackTrace) => KeyedSubtree(
        key: ValueKey<Object>('baseball_report_ai_error'),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: BaseballAiTabError(
            onRetry: () => ref.invalidate(baseballAiAnalysisProvider(matchId)),
          ),
        ),
      ),
      data: (raw) {
        final parsed = parseBaseballAiAnalysis(raw);
        return KeyedSubtree(
          key: const ValueKey<Object>('baseball_report_ai'),
          child: Padding(
            padding: const EdgeInsets.all(TsSpacing.lg),
            child: _AiAnalysisContent(parsed: parsed),
          ),
        );
      },
    );
  }
}

class _AiLockedState extends ConsumerWidget {
  const _AiLockedState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'AI 분석',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.sm),
        Text(
          'AI 기반 심층 분석은 프리미엄 구독 후 이용할 수 있습니다.',
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

class BaseballAiTabLoading extends StatelessWidget {
  const BaseballAiTabLoading({super.key});

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
            'AI 분석 로딩 중...',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            '최초 분석 시 10–15초 정도 소요될 수 있습니다.',
            style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BaseballAiTabError extends StatelessWidget {
  const BaseballAiTabError({
    required this.onRetry,
    super.key,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AI 분석을 불러오지 못했습니다.',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: '다시 시도',
            variant: TsButtonVariant.primary,
            size: TsButtonSize.small,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _AiAnalysisContent extends StatelessWidget {
  const _AiAnalysisContent({required this.parsed});

  final BaseballAiAnalysisParsed parsed;

  @override
  Widget build(BuildContext context) {
    final ou = parsed.overUnder;
    final favoredOver = ou.favorsOver || (!ou.favorsUnder && ou.prediction != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AiWinProbabilitySection(parsed: parsed),
        const SizedBox(height: TsSpacing.xl),
        OverUnderSection(
          baseLine: ou.lineDisplay,
          overOdds: favoredOver ? '추천' : '-',
          underOdds: ou.favorsUnder ? '추천' : '-',
          isFavoredUnder: ou.favorsUnder,
        ),
        if (ou.analysis != null && ou.analysis!.trim().isNotEmpty) ...[
          const SizedBox(height: TsSpacing.sm),
          _AnalysisTextBox(text: ou.analysis!.trim()),
        ],
        const SizedBox(height: TsSpacing.xl),
        HomeAwayRecordSection(
          awayRecord: parsed.awayLast10Record.formatted,
          homeRecord: parsed.homeLast10Record.formatted,
          awayTeam: parsed.awayTeam,
          homeTeam: parsed.homeTeam,
        ),
        const SizedBox(height: TsSpacing.xl),
        WinRateSection(
          awayWinRate: parsed.awayLast10WinRateDisplay,
          homeWinRate: parsed.homeLast10WinRateDisplay,
          confidence: parsed.confidence,
        ),
        if (parsed.last10TeamProduction.isNotEmpty) ...[
          const SizedBox(height: TsSpacing.xl),
          TeamProductionSection(items: parsed.last10TeamProduction),
        ],
        if (parsed.seasonTeamStats.length >= 4) ...[
          const SizedBox(height: TsSpacing.xl),
          SeasonTeamStatsSection(items: parsed.seasonTeamStats),
        ],
        if (parsed.aiSummary != null &&
            parsed.aiSummary!.trim().isNotEmpty &&
            parsed.aiSummary!.trim() != parsed.winProbabilityDescription.trim()) ...[
          const SizedBox(height: TsSpacing.xl),
          _AiSummarySection(summary: parsed.aiSummary!.trim()),
        ],
        const SizedBox(height: TsSpacing.xl),
      ],
    );
  }
}

class _AiWinProbabilitySection extends StatelessWidget {
  const _AiWinProbabilitySection({required this.parsed});

  final BaseballAiAnalysisParsed parsed;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final winProb = parsed.winProbability;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '승리 확률',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RatioBar(
                segments: [
                  RatioSegment(
                    flex: winProb.awayRatio,
                    color: TsColors.systemError500,
                    label: winProb.awayDisplay,
                    bottomLabel: parsed.awayTeam,
                  ),
                  RatioSegment(
                    flex: winProb.homeRatio,
                    color: semantic.interactivePrimary,
                    label: winProb.homeDisplay,
                    bottomLabel: parsed.homeTeam,
                  ),
                ],
                height: 32,
              ),
              const SizedBox(height: TsSpacing.lg),
              Text(
                parsed.winProbabilityDescription,
                style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalysisTextBox extends StatelessWidget {
  const _AnalysisTextBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
      ),
    );
  }
}

class _AiSummarySection extends StatelessWidget {
  const _AiSummarySection({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI 분석 요약',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            summary,
            style: TsType.bodyMRegular.copyWith(color: semantic.textSecondary),
          ),
        ),
      ],
    );
  }
}
