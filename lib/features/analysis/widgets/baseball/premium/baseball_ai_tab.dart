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
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/features/analysis/models/baseball_ai_parser.dart';
import 'package:trendsoccer/features/analysis/models/parser_labels.dart';
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
        final parsed = parseBaseballAiAnalysis(
          raw,
          labels: ParserLabels.from(context.l10n),
        );
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
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.reportTabAiAnalysis,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.sm),
        Text(
          l10n.baseballAiPremiumHint,
          style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TsSpacing.xl),
        TsButton(
          label: l10n.premiumSubscribeNow,
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
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: semantic.interactivePrimary),
          const SizedBox(height: TsSpacing.lg),
          Text(
            l10n.baseballAiTabLoading,
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            l10n.baseballAiTabLoadingHint,
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
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.baseballAiTabLoadFailed,
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.lg),
          TsButton(
            label: l10n.retry,
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
    final l10n = context.l10n;
    final recommendLabel = l10n.labelRecommend;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AiWinProbabilitySection(parsed: parsed),
        const SizedBox(height: TsSpacing.xl),
        OverUnderSection(
          baseLine: ou.lineDisplay,
          overOdds: favoredOver ? recommendLabel : '-',
          underOdds: ou.favorsUnder ? recommendLabel : '-',
          isFavoredUnder: ou.favorsUnder,
        ),
        if (ou.analysis != null && ou.analysis!.trim().isNotEmpty) ...[
          const SizedBox(height: TsSpacing.sm),
          _AnalysisTextBox(text: ou.analysis!.trim()),
        ],
        const SizedBox(height: TsSpacing.xl),
        HomeAwayRecordSection(
          awayRecord: parsed.awayLast10Record.formattedWith(
            ParserLabels.from(context.l10n),
          ),
          homeRecord: parsed.homeLast10Record.formattedWith(
            ParserLabels.from(context.l10n),
          ),
          awayTeam: localizedTeamName(
            context,
            parsed.awayTeam,
            parsed.awayTeamKo,
          ),
          homeTeam: localizedTeamName(
            context,
            parsed.homeTeam,
            parsed.homeTeamKo,
          ),
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
    final l10n = context.l10n;
    final winProb = parsed.winProbability;
    final awayLabel = localizedTeamName(
      context,
      parsed.awayTeam,
      parsed.awayTeamKo,
    );
    final homeLabel = localizedTeamName(
      context,
      parsed.homeTeam,
      parsed.homeTeamKo,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.baseballWinProbability,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
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
                    bottomLabel: awayLabel,
                  ),
                  RatioSegment(
                    flex: winProb.homeRatio,
                    color: semantic.interactivePrimary,
                    label: winProb.homeDisplay,
                    bottomLabel: homeLabel,
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
        color: semantic.surfaceBase,
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
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.baseballAiSummary,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.lg),
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
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
