import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/access_gate.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/features/analysis/models/soccer_analysis_parser.dart';
import 'package:trendsoccer/features/analysis/widgets/soccer/standard/standard_sections.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';
import 'package:trendsoccer/shared/widgets/report/blurable_section.dart';

class SoccerStandardTab extends StatelessWidget {
  const SoccerStandardTab({
    required this.parsed,
    required this.planType,
    super.key,
  });

  final SoccerStandardAnalysisParsed parsed;
  final PlanType planType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matchTimestamp = parsed.matchTimestampUtc;
    final canView = matchTimestamp == null
        ? true
        : AccessGate.canViewStandardAnalysis(
            matchTimestamp: matchTimestamp,
            planType: planType,
          );

    final lockMessage = matchTimestamp == null
        ? null
        : _buildLockOverlayMessage(
            context: context,
            matchTimestamp: matchTimestamp,
            planType: planType,
          );

    Widget gatedSection({
      required String title,
      required Widget content,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TsType.headingH2.copyWith(
              color: Theme.of(context).extension<TsSemanticColors>()!.textPrimary,
            ),
          ),
          const SizedBox(height: TsSpacing.sm),
          BlurableSection(
            isBlurred: !canView,
            blurMessage: lockMessage,
            child: content,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gatedSection(
          title: l10n.soccerAnalysisResult,
          content: AnalysisResultSection(
            prediction: parsed.prediction,
            winProbability: parsed.winProbability,
            powerDiff: parsed.powerDiff,
            gradeBadgeType: parsed.gradeBadge,
            analysisMatchCount: parsed.analysisMatchCount,
            patternMatchCount: parsed.patternMatchCount,
            showTitle: false,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
        gatedSection(
          title: l10n.soccerAnalysisReasoning,
          content: ReasoningSection(
            items: parsed.reasoningItems,
            showTitle: false,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
        OddsSection(
          homeOdds: parsed.homeOdds,
          drawOdds: parsed.drawOdds,
          awayOdds: parsed.awayOdds,
        ),
        const SizedBox(height: TsSpacing.xl),
        gatedSection(
          title: l10n.soccerPowerIndex,
          content: PowerIndexSection(
            homeRatio: parsed.homePowerRatio,
            homePowerDisplay: parsed.homePowerDisplay,
            awayPowerDisplay: parsed.awayPowerDisplay,
            showTitle: false,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
        gatedSection(
          title: l10n.soccerFinalProbability,
          content: FinalProbabilitySection(
            homeProb: parsed.homeProb,
            drawProb: parsed.drawProb,
            awayProb: parsed.awayProb,
            showTitle: false,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
        gatedSection(
          title: l10n.soccerStatTeamStats,
          content: TeamStatisticsSection(
            stats: parsed.teamStats,
            showTitle: false,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
        gatedSection(
          title: l10n.soccerMethod3,
          content: ThreeMethodAnalysisSection(
            methods: parsed.threeMethods,
            showTitle: false,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
      ],
    );
  }

  String? _buildLockOverlayMessage({
    required BuildContext context,
    required DateTime matchTimestamp,
    required PlanType planType,
  }) {
    final l10n = context.l10n;
    final message = AccessGate.lockMessage(
      matchTimestamp: matchTimestamp,
      planType: planType,
      l10n: l10n,
    );
    if (message == null) return null;

    final until = AccessGate.timeUntilUnlock(
      matchTimestamp: matchTimestamp,
      planType: planType,
    );
    if (until == null || until <= Duration.zero) return message;
    return '$message\n${AccessGate.formatTimeUntilUnlock(until, l10n: l10n)}';
  }
}

class SoccerStandardTabLoading extends StatelessWidget {
  const SoccerStandardTabLoading({super.key});

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
            l10n.analysisAiAnalyzing,
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            l10n.analysisAiWaitHint,
            style: TsType.bodyMRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class SoccerStandardTabError extends StatelessWidget {
  const SoccerStandardTabError({
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
            l10n.analysisLoadFailed,
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

/// Displays markdown analysis from POST `/api/analysis`.
class SoccerStandardMarkdownTab extends StatelessWidget {
  const SoccerStandardMarkdownTab({
    required this.markdown,
    required this.planType,
    this.matchTimestampUtc,
    super.key,
  });

  final String markdown;
  final PlanType planType;
  final DateTime? matchTimestampUtc;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final matchTimestamp = matchTimestampUtc;
    final canView = matchTimestamp == null
        ? true
        : AccessGate.canViewStandardAnalysis(
            matchTimestamp: matchTimestamp,
            planType: planType,
          );

    final lockMessage = matchTimestamp == null
        ? null
        : _buildLockOverlayMessage(
            context: context,
            matchTimestamp: matchTimestamp,
            planType: planType,
          );

    final l10n = context.l10n;
    final content = markdown.isEmpty
        ? Text(
            l10n.analysisNoResult,
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          )
        : SelectableText(
            markdown,
            style: TsType.bodyMRegular.copyWith(
              color: semantic.textPrimary,
              height: 1.6,
            ),
          );

    // TODO: Parse markdown into structured sections
    return BlurableSection(
      isBlurred: !canView,
      blurMessage: lockMessage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TsSpacing.lg),
        decoration: BoxDecoration(
          color: semantic.surfaceBase,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    );
  }

  String? _buildLockOverlayMessage({
    required BuildContext context,
    required DateTime matchTimestamp,
    required PlanType planType,
  }) {
    final l10n = context.l10n;
    final message = AccessGate.lockMessage(
      matchTimestamp: matchTimestamp,
      planType: planType,
      l10n: l10n,
    );
    if (message == null) return null;

    final until = AccessGate.timeUntilUnlock(
      matchTimestamp: matchTimestamp,
      planType: planType,
    );
    if (until == null || until <= Duration.zero) return message;
    return '$message\n${AccessGate.formatTimeUntilUnlock(until, l10n: l10n)}';
  }
}

/// Refreshes lock countdown text periodically while the markdown tab is visible.
class SoccerStandardMarkdownTabHost extends StatefulWidget {
  const SoccerStandardMarkdownTabHost({
    required this.markdown,
    required this.planType,
    this.matchTimestampUtc,
    super.key,
  });

  final String markdown;
  final PlanType planType;
  final DateTime? matchTimestampUtc;

  @override
  State<SoccerStandardMarkdownTabHost> createState() =>
      _SoccerStandardMarkdownTabHostState();
}

class _SoccerStandardMarkdownTabHostState
    extends State<SoccerStandardMarkdownTabHost> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoccerStandardMarkdownTab(
      markdown: widget.markdown,
      planType: widget.planType,
      matchTimestampUtc: widget.matchTimestampUtc,
    );
  }
}

/// Refreshes lock countdown text periodically while the tab is visible.
class SoccerStandardTabHost extends StatefulWidget {
  const SoccerStandardTabHost({
    required this.parsed,
    required this.planType,
    super.key,
  });

  final SoccerStandardAnalysisParsed parsed;
  final PlanType planType;

  @override
  State<SoccerStandardTabHost> createState() => _SoccerStandardTabHostState();
}

class _SoccerStandardTabHostState extends State<SoccerStandardTabHost> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoccerStandardTab(
      parsed: widget.parsed,
      planType: widget.planType,
    );
  }
}
