import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/baseball_predict_v2_parsed.dart';
import 'package:trendsoccer/core/models/baseball_pitcher_stats_parsed.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_gauge_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_prediction_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class BaseballAiMatchAnalysisReportBlock extends ConsumerStatefulWidget {
  const BaseballAiMatchAnalysisReportBlock({
    required this.header,
    super.key,
  });

  final MatchHeaderData header;

  @override
  ConsumerState<BaseballAiMatchAnalysisReportBlock> createState() =>
      _BaseballAiMatchAnalysisReportBlockState();
}

class _BaseballAiMatchAnalysisReportBlockState
    extends ConsumerState<BaseballAiMatchAnalysisReportBlock> {
  bool _retryInProgress = false;

  Future<void> _guardedRetry(Future<void> Function() work) async {
    if (_retryInProgress) return;
    setState(() => _retryInProgress = true);
    try {
      await work();
    } finally {
      if (mounted) {
        setState(() => _retryInProgress = false);
      }
    }
  }

  MatchReportRetryButton _retryButton() {
    return MatchReportRetryButton(
      inProgress: _retryInProgress,
      onPressed: () => unawaited(_guardedRetry(_retryPredict)),
    );
  }

  Future<void> _retryPredict() async {
    ref.invalidate(baseballPredictProvider(widget.header.matchId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = _normalizeLeagueCode(widget.header.leagueCode ?? '');
    final title = l10n.baseballAiMatchAnalysis;
    final retry = _retryButton();

    if (league != 'MLB' && league != 'KBO' && league != 'NPB') {
      return const SizedBox.shrink();
    }

    final predictAsync =
        ref.watch(baseballPredictProvider(widget.header.matchId));

    return _AiMatchAnalysisReportBlockCard(
      title: title,
      child: predictAsync.when(
        loading: () => const _AiMatchAnalysisReportBlockSkeleton(),
        error: (error, _) => _AiMatchAnalysisReportBlockFailure(
          retry: retry,
          description: resolveApiError(context, error),
        ),
        data: (predict) {
          final detail =
              ref.read(baseballMatchDetailProvider(widget.header.matchId)).value;

          if (predict.isEmpty) {
            return _AiMatchAnalysisReportBlockEmpty(
              title: title,
              description: baseballMatchHasUndecidedStarter(
                matchDetail: detail,
                leagueCode: league,
              )
                  ? l10n.baseballAnalysisHeldUntilStarters
                  : l10n.analysisNoResult,
            );
          }

          final parsed = parseBaseballPredictV2(
            predict,
            matchDetail: detail,
          );
          if (!_hasUsableBaseballPrediction(parsed)) {
            return _AiMatchAnalysisReportBlockEmpty(
              title: title,
              description: baseballMatchHasUndecidedStarter(
                matchDetail: detail,
                leagueCode: league,
              )
                  ? l10n.baseballAnalysisHeldUntilStarters
                  : l10n.analysisNoResult,
            );
          }

          return _AiMatchAnalysisPredictionContent(
            header: widget.header,
            parsed: parsed,
          );
        },
      ),
    );
  }
}

bool _hasUsableBaseballPrediction(BaseballPredictV2Parsed parsed) {
  if (parsed.pickDirection != BaseballPickDirection.unknown) return true;
  return parsed.winProb.home != null || parsed.winProb.away != null;
}

String _normalizeLeagueCode(String? league) {
  final upper = (league ?? '').trim().toUpperCase();
  if (upper.contains('MLB') || upper.contains('MAJOR')) return 'MLB';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('KBO') || upper.contains('KOREA')) return 'KBO';
  return upper;
}

class _AiMatchAnalysisPredictionContent extends StatelessWidget {
  const _AiMatchAnalysisPredictionContent({
    required this.header,
    required this.parsed,
  });

  final MatchHeaderData header;
  final BaseballPredictV2Parsed parsed;

  @override
  Widget build(BuildContext context) {
    final homeFraction = parsed.winProb.home;
    final awayFraction = parsed.winProb.away;
    final isEnglishLocale =
        Localizations.localeOf(context).languageCode.startsWith('en');
    final pickDirection = _resolveBaseballPickDirection(
      parsed,
      header,
      isEnglishLocale: isEnglishLocale,
    );
    final pickProb = switch (pickDirection) {
      BaseballPickDirection.home => homeFraction,
      BaseballPickDirection.away => awayFraction,
      BaseballPickDirection.unknown => null,
    };
    final gradeLabel = _baseballGradeBadgeLabel(parsed.grade);

    return TsPredictionCard(
      pickTeam: _pickTeamLabel(context, header, pickDirection),
      probabilityLabel: _formatPickProbability(pickProb),
      pickEmblemUrl: _pickEmblemUrl(header, pickDirection),
      resultLabel: gradeLabel,
      resultTone: _baseballGradeBadgeTone(parsed.grade),
      line: TsGaugeLine.twoWay,
      homeFraction: homeFraction,
      awayFraction: awayFraction,
      homeLabel: _gaugePercentLabel(homeFraction),
      awayLabel: _gaugePercentLabel(awayFraction),
    );
  }
}

String _pickTeamLabel(
  BuildContext context,
  MatchHeaderData header,
  BaseballPickDirection direction,
) {
  return switch (direction) {
    BaseballPickDirection.home => localizedTeamName(
        context,
        header.homeTeam,
        header.homeTeamKo,
      ),
    BaseballPickDirection.away => localizedTeamName(
        context,
        header.awayTeam,
        header.awayTeamKo,
      ),
    BaseballPickDirection.unknown => '-',
  };
}

String? _pickEmblemUrl(
  MatchHeaderData header,
  BaseballPickDirection direction,
) {
  return switch (direction) {
    BaseballPickDirection.home => header.homeTeamLogo,
    BaseballPickDirection.away => header.awayTeamLogo,
    BaseballPickDirection.unknown => null,
  };
}

BaseballPickDirection _resolveBaseballPickDirection(
  BaseballPredictV2Parsed parsed,
  MatchHeaderData header, {
  required bool isEnglishLocale,
}) {
  if (parsed.pickDirection != BaseballPickDirection.unknown) {
    return parsed.pickDirection;
  }
  final home = parsed.winProb.home;
  final away = parsed.winProb.away;
  if (home == null || away == null) {
    return BaseballPickDirection.unknown;
  }
  if (home > away) return BaseballPickDirection.home;
  if (away > home) return BaseballPickDirection.away;

  final summaryText = _baseballInsightsSummaryForLocale(
    parsed,
    isEnglishLocale: isEnglishLocale,
  );
  if (summaryText == null) return BaseballPickDirection.unknown;

  final mentionsHome = _summaryMentionsTeam(summaryText, header.homeTeam) ||
      _summaryMentionsTeam(summaryText, header.homeTeamKo);
  final mentionsAway = _summaryMentionsTeam(summaryText, header.awayTeam) ||
      _summaryMentionsTeam(summaryText, header.awayTeamKo);

  if (mentionsHome && !mentionsAway) return BaseballPickDirection.home;
  if (mentionsAway && !mentionsHome) return BaseballPickDirection.away;
  return BaseballPickDirection.unknown;
}

String? _baseballInsightsSummaryForLocale(
  BaseballPredictV2Parsed parsed, {
  required bool isEnglishLocale,
}) {
  if (isEnglishLocale) {
    final english = parsed.summaryEn?.trim();
    if (english != null && english.isNotEmpty) return english;
  }
  final summary = parsed.summary?.trim();
  if (summary == null || summary.isEmpty) return null;
  return summary;
}

bool _summaryMentionsTeam(String summary, String? teamName) {
  final trimmed = teamName?.trim();
  if (trimmed == null || trimmed.isEmpty) return false;
  return summary.toLowerCase().contains(trimmed.toLowerCase());
}

String _formatPickProbability(double? prob) {
  if (prob == null || prob <= 0) return '-';
  return '${(prob * 100).round()}%';
}

String _gaugePercentLabel(double? fraction) {
  if (fraction == null || fraction <= 0) return '-';
  return '${(fraction * 100).round()}%';
}

String? _baseballGradeBadgeLabel(String? grade) {
  if (grade == null || grade.trim().isEmpty) return null;
  final raw = grade.trim().toLowerCase();
  if (raw.contains('pick') || raw == 'a') return 'REPORT';
  if (raw.contains('good') || raw == 'b') return 'GOOD';
  if (raw.contains('pass') || raw == 'c') return 'PASS';
  return grade.trim().toUpperCase();
}

TsBadgeTone _baseballGradeBadgeTone(String? grade) {
  if (grade == null || grade.trim().isEmpty) return TsBadgeTone.neutral;
  final raw = grade.trim().toLowerCase();
  if (raw.contains('pick') || raw == 'a') return TsBadgeTone.positive;
  if (raw.contains('good') || raw == 'b') return TsBadgeTone.primary;
  return TsBadgeTone.neutral;
}

class _AiMatchAnalysisReportBlockCard extends StatelessWidget {
  const _AiMatchAnalysisReportBlockCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsSectionHeader(
            title: title,
            icon: TsIcons.verified,
          ),
          const SizedBox(height: TsSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _AiMatchAnalysisReportBlockSkeleton extends StatelessWidget {
  const _AiMatchAnalysisReportBlockSkeleton();

  @override
  Widget build(BuildContext context) {
    return const TsSkeletonBlock(TsSkeletonType.block);
  }
}

class _AiMatchAnalysisReportBlockFailure extends StatelessWidget {
  const _AiMatchAnalysisReportBlockFailure({
    required this.retry,
    required this.description,
  });

  final MatchReportRetryButton retry;
  final String description;

  @override
  Widget build(BuildContext context) {
    return TsEmptyState(
      type: TsEmptyType.failure,
      title: 'Could not load',
      description: description,
      actionLabel: retry.label,
      onAction: retry.action,
    );
  }
}

class _AiMatchAnalysisReportBlockEmpty extends StatelessWidget {
  const _AiMatchAnalysisReportBlockEmpty({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return TsEmptyState(
      title: title,
      description: description,
    );
  }
}
