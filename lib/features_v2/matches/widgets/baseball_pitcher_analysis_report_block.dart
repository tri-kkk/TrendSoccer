import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/baseball_pitcher_stats_parsed.dart';
import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_insight_text.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class BaseballPitcherAnalysisReportBlock extends ConsumerStatefulWidget {
  const BaseballPitcherAnalysisReportBlock({
    required this.header,
    super.key,
  });

  final MatchHeaderData header;

  @override
  ConsumerState<BaseballPitcherAnalysisReportBlock> createState() =>
      _BaseballPitcherAnalysisReportBlockState();
}

class _BaseballPitcherAnalysisReportBlockState
    extends ConsumerState<BaseballPitcherAnalysisReportBlock> {
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
      onPressed: () => unawaited(_guardedRetry(_retryAnalysis)),
    );
  }

  Future<void> _retryAnalysis() async {
    ref.invalidate(baseballPitcherAnalysisProvider(widget.header.matchId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = _normalizeLeagueCode(widget.header.leagueCode ?? '');
    final title = l10n.baseballPitcherAnalysis;
    final retry = _retryButton();

    if (league != 'MLB' && league != 'KBO' && league != 'NPB') {
      return const SizedBox.shrink();
    }

    final analysisAsync =
        ref.watch(baseballPitcherAnalysisProvider(widget.header.matchId));

    return _PitcherAnalysisReportBlockCard(
      title: title,
      child: analysisAsync.when(
        loading: () => const _PitcherAnalysisReportBlockSkeleton(),
        error: (error, _) => _PitcherAnalysisReportBlockFailure(
          retry: retry,
          description: resolveApiError(context, error),
        ),
        data: (response) {
          final sentences = _parseAnalysisSentences(response);
          if (sentences.isEmpty) {
            final detail =
                ref.read(baseballMatchDetailProvider(widget.header.matchId)).value;
            return _PitcherAnalysisReportBlockEmpty(
              title: title,
              description: baseballMatchHasUndecidedStarter(
                matchDetail: detail,
                leagueCode: league,
              )
                  ? l10n.baseballAnalysisHeldUntilStarters
                  : l10n.baseballPitcherAnalysisNoData,
            );
          }

          return _PitcherAnalysisInsightContent(sentences: sentences);
        },
      ),
    );
  }
}

final _analysisSentenceSplitPattern = RegExp(r'(?<=\.)\s+');

List<String> _parseAnalysisSentences(Map<String, dynamic> response) {
  final analysis = response['analysis'];
  if (analysis is! String) return const [];

  final sentences = <String>[];
  for (final line in analysis.split('\n')) {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty) continue;

    for (final part in _mergeAbbreviationSplits(
      trimmedLine
          .split(_analysisSentenceSplitPattern)
          .map((segment) => segment.trim())
          .where((segment) => segment.isNotEmpty)
          .toList(),
    )) {
      sentences.add(part);
    }
  }
  return sentences;
}

List<String> _mergeAbbreviationSplits(List<String> fragments) {
  if (fragments.length <= 1) return fragments;

  final merged = <String>[];
  var index = 0;
  while (index < fragments.length) {
    var current = fragments[index];
    while (
      index < fragments.length - 1 &&
      _fragmentEndsWithAbbreviation(current)
    ) {
      index++;
      current = '$current ${fragments[index]}';
    }
    merged.add(current);
    index++;
  }
  return merged;
}

bool _fragmentEndsWithAbbreviation(String fragment) {
  final trimmed = fragment.trim();
  if (!trimmed.endsWith('.')) return false;

  final match = RegExp(r'(\S+)\.$').firstMatch(trimmed);
  if (match == null) return false;

  final word = match.group(1)!;
  if (word.isEmpty || word.length > 2) return false;

  final first = word.codeUnitAt(0);
  return first >= 0x41 && first <= 0x5A;
}

String _normalizeLeagueCode(String? league) {
  final upper = (league ?? '').trim().toUpperCase();
  if (upper.contains('MLB') || upper.contains('MAJOR')) return 'MLB';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('KBO') || upper.contains('KOREA')) return 'KBO';
  return upper;
}

class _PitcherAnalysisInsightContent extends StatelessWidget {
  const _PitcherAnalysisInsightContent({required this.sentences});

  final List<String> sentences;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sentences.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          TsInsightText(
            text: sentences[i],
            tone: TsInsightTone.confirmed,
          ),
        ],
      ],
    );
  }
}

class _PitcherAnalysisReportBlockCard extends StatelessWidget {
  const _PitcherAnalysisReportBlockCard({
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
          TsSectionHeader(title: title, icon: TsIcons.analysis),
          const SizedBox(height: TsSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _PitcherAnalysisReportBlockSkeleton extends StatelessWidget {
  const _PitcherAnalysisReportBlockSkeleton();

  @override
  Widget build(BuildContext context) {
    return const TsSkeletonBlock(TsSkeletonType.block);
  }
}

class _PitcherAnalysisReportBlockFailure extends StatelessWidget {
  const _PitcherAnalysisReportBlockFailure({
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

class _PitcherAnalysisReportBlockEmpty extends StatelessWidget {
  const _PitcherAnalysisReportBlockEmpty({
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
