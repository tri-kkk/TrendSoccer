import 'dart:async';

import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/access_gate.dart';
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
            matchTimestamp: matchTimestamp,
            planType: planType,
          );

    Widget gated(Widget child) {
      return BlurableSection(
        isBlurred: !canView,
        blurMessage: lockMessage,
        child: child,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gated(
          AnalysisResultSection(
            prediction: parsed.prediction,
            winProbability: parsed.winProbability,
            powerDiff: parsed.powerDiff,
            analyzedMatches: parsed.analyzedMatches,
            patternStats: parsed.patternStats,
            gradeBadgeType: parsed.gradeBadge,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
        gated(ReasoningSection(items: parsed.reasoningItems)),
        const SizedBox(height: TsSpacing.xl),
        OddsSection(
          homeOdds: parsed.homeOdds,
          drawOdds: parsed.drawOdds,
          awayOdds: parsed.awayOdds,
        ),
        const SizedBox(height: TsSpacing.xl),
        gated(PowerIndexSection(homeRatio: parsed.homePowerRatio)),
        const SizedBox(height: TsSpacing.xl),
        gated(
          FinalProbabilitySection(
            homeProb: parsed.homeProb,
            drawProb: parsed.drawProb,
            awayProb: parsed.awayProb,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
        gated(TeamStatisticsSection(stats: parsed.teamStats)),
        const SizedBox(height: TsSpacing.xl),
        gated(
          ThreeMethodAnalysisSection(
            paPercent: '${(parsed.paHomeRatio * 100).round()}%',
            paHomeRatio: parsed.paHomeRatio,
            minMaxPercent: '${(parsed.minMaxHomeRatio * 100).round()}%',
            minMaxHomeRatio: parsed.minMaxHomeRatio,
            firstGoalPercent: '${(parsed.firstGoalHomeRatio * 100).round()}%',
            firstGoalHomeRatio: parsed.firstGoalHomeRatio,
          ),
        ),
        const SizedBox(height: TsSpacing.xl),
      ],
    );
  }

  String? _buildLockOverlayMessage({
    required DateTime matchTimestamp,
    required PlanType planType,
  }) {
    final message = AccessGate.lockMessage(
      matchTimestamp: matchTimestamp,
      planType: planType,
    );
    if (message == null) return null;

    final until = AccessGate.timeUntilUnlock(
      matchTimestamp: matchTimestamp,
      planType: planType,
    );
    if (until == null || until <= Duration.zero) return message;
    return '$message\n${_formatUnlockCountdown(until)} 후 오픈';
  }

  String _formatUnlockCountdown(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일 ${duration.inHours % 24}시간';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}시간 ${duration.inMinutes % 60}분';
    }
    final minutes = duration.inMinutes;
    return minutes > 0 ? '$minutes분' : '1분';
  }
}

class SoccerStandardTabLoading extends StatelessWidget {
  const SoccerStandardTabLoading({super.key});

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
            'AI 분석 중...',
            style: TsType.bodyLRegular.copyWith(color: semantic.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            '잠시만 기다려주세요 (약 5–10초)',
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '분석 데이터를 불러오지 못했습니다.',
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
