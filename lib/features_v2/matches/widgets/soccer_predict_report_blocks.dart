import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/models/soccer_predict_v2_parsed.dart';
import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_insight_text.dart';
import 'package:trendsoccer/design_system/widgets/ts_method_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_prediction_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_stat_compare_row.dart';
import 'package:trendsoccer/features_v2/matches/widgets/soccer_extended_report_blocks.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

final soccerPredictV2ParsedProvider =
    Provider.family<AsyncValue<SoccerPredictV2Parsed>, SoccerAnalysisParams>(
  (ref, params) {
    return ref
        .watch(soccerPredictionProvider(params))
        .whenData(parseSoccerPredictV2);
  },
);

class SoccerPredictReportBlocks extends ConsumerWidget {
  const SoccerPredictReportBlocks({required this.header, super.key});

  final MatchHeaderData header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = SoccerAnalysisParams.fromHeader(header);
    final parsedAsync = ref.watch(soccerPredictV2ParsedProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SoccerPredictBlocksBody(
          header: header,
          parsedAsync: parsedAsync,
          onRetry: () => ref.invalidate(soccerPredictionProvider(params)),
        ),
        const SizedBox(height: TsSpacing.lg),
        SoccerExtendedReportBlocks(header: header, params: params),
      ],
    );
  }
}

class _SoccerPredictBlocksBody extends StatelessWidget {
  const _SoccerPredictBlocksBody({
    required this.header,
    required this.parsedAsync,
    required this.onRetry,
  });

  final MatchHeaderData header;
  final AsyncValue<SoccerPredictV2Parsed> parsedAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return parsedAsync.when(
      data: (parsed) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SoccerReportBlockCard(
            title: 'Prediction',
            child: _PredictionBlockContent(header: header, parsed: parsed),
          ),
          const SizedBox(height: TsSpacing.lg),
          _SoccerReportBlockCard(
            title: 'Reasoning',
            child: _ReasoningBlockContent(reasons: parsed.reasons),
          ),
          const SizedBox(height: TsSpacing.lg),
          _SoccerReportBlockCard(
            title: 'Three-method',
            child: _ThreeMethodBlockContent(parsed: parsed),
          ),
          const SizedBox(height: TsSpacing.lg),
          _SoccerReportBlockCard(
            title: l10n.soccerStatTeamStats,
            child: _TeamStatsBlockContent(
              rows: parsed.teamStats,
              l10n: l10n,
            ),
          ),
        ],
      ),
      loading: () => const _SoccerPredictBlocksLoading(),
      error: (_, _) => _SoccerPredictBlocksError(onRetry: onRetry),
    );
  }
}

class _SoccerReportBlockCard extends StatelessWidget {
  const _SoccerReportBlockCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsSectionHeader(title: title),
          const SizedBox(height: TsSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _PredictionBlockContent extends StatelessWidget {
  const _PredictionBlockContent({
    required this.header,
    required this.parsed,
  });

  final MatchHeaderData header;
  final SoccerPredictV2Parsed parsed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prob = parsed.finalProb;
    final pickProb = switch (parsed.pickDirection) {
      SoccerPickDirection.home => prob.home,
      SoccerPickDirection.draw => prob.draw,
      SoccerPickDirection.away => prob.away,
      SoccerPickDirection.unknown => 0.0,
    };

    return TsPredictionCard(
      pickTeam: _pickTeamLabel(context, header, parsed.pickDirection, l10n),
      probabilityLabel: _formatPickProbability(pickProb),
      pickEmblemUrl: _pickEmblemUrl(header, parsed.pickDirection),
      resultLabel: _gradeBadgeLabel(parsed.grade),
      resultTone: _gradeBadgeTone(parsed.grade),
      homeFraction: prob.home,
      drawFraction: prob.draw,
      awayFraction: prob.away,
      homeLabel: _gaugePercentLabel(prob.home),
      drawLabel: _gaugePercentLabel(prob.draw),
      awayLabel: _gaugePercentLabel(prob.away),
    );
  }
}

class _ReasoningBlockContent extends StatelessWidget {
  const _ReasoningBlockContent({required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    if (reasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < reasons.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          TsInsightText(
            text: reasons[i],
            tone: TsInsightTone.confirmed,
          ),
        ],
      ],
    );
  }
}

class _ThreeMethodBlockContent extends StatelessWidget {
  const _ThreeMethodBlockContent({required this.parsed});

  final SoccerPredictV2Parsed parsed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final methodLabels = [
      l10n.soccerMethodPaCompare,
      l10n.soccerMethodMinMax,
      l10n.soccerMethodFirstGoal,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < parsed.methods.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          _MethodRowContent(
            methodLabel: methodLabels[i],
            method: parsed.methods[i],
          ),
        ],
      ],
    );
  }
}

class _TeamStatsBlockContent extends StatelessWidget {
  const _TeamStatsBlockContent({
    required this.rows,
    required this.l10n,
  });

  final List<SoccerTeamStatRow> rows;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final labels = [
      l10n.soccerStatFirstGoalRate,
      l10n.soccerStatComebackRate,
      l10n.soccerRecentForm,
      l10n.soccerStatGoalDifference,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.md),
          _TeamStatCompareRow(
            statLabel: labels[i],
            row: rows[i],
          ),
        ],
      ],
    );
  }
}

class _TeamStatCompareRow extends StatelessWidget {
  const _TeamStatCompareRow({
    required this.statLabel,
    required this.row,
  });

  final String statLabel;
  final SoccerTeamStatRow row;

  @override
  Widget build(BuildContext context) {
    final homeDisplay = _formatTeamStatValue(row.homeValue, row.format);
    final awayDisplay = _formatTeamStatValue(row.awayValue, row.format);
    final homeFraction = _teamStatFraction(row.homeValue, row.awayValue, true);
    final awayFraction = _teamStatFraction(row.homeValue, row.awayValue, false);

    var homeEmphasized = false;
    var awayEmphasized = false;
    if (row.homeValue != null &&
        row.awayValue != null &&
        homeDisplay != '-' &&
        awayDisplay != '-') {
      if (row.homeValue! > row.awayValue!) {
        homeEmphasized = true;
      } else if (row.awayValue! > row.homeValue!) {
        awayEmphasized = true;
      }
    }

    return TsStatCompareRow(
      statLabel: statLabel,
      homeLabel: homeDisplay,
      awayLabel: awayDisplay,
      homeFraction: homeFraction,
      awayFraction: awayFraction,
      homeEmphasized: homeEmphasized,
      awayEmphasized: awayEmphasized,
    );
  }
}

class _MethodRowContent extends StatelessWidget {
  const _MethodRowContent({
    required this.methodLabel,
    required this.method,
  });

  final String methodLabel;
  final SoccerMethodProbabilities method;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final win = method.winValue;
    final draw = method.drawValue;
    final lose = method.loseValue;
    final total = method.total;

    final pickLabel = total <= 0
        ? '-'
        : win >= lose
            ? l10n.soccerHomeWinPct((win * 100).round())
            : l10n.soccerAwayWinPct((lose * 100).round());

    return TsMethodRow(
      methodLabel: methodLabel,
      pickLabel: pickLabel,
      homeFraction: win,
      drawFraction: draw,
      awayFraction: lose,
      homeLabel: total <= 0 ? null : _gaugePercentLabel(win),
      drawLabel: total <= 0 ? null : _gaugePercentLabel(draw),
      awayLabel: total <= 0 ? null : _gaugePercentLabel(lose),
    );
  }
}

class _SoccerPredictBlocksLoading extends StatelessWidget {
  const _SoccerPredictBlocksLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.lg),
          _SoccerReportBlockSkeleton(),
        ],
      ],
    );
  }
}

class _SoccerReportBlockSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsSkeletonBlock(TsSkeletonType.title, width: 160),
          SizedBox(height: TsSpacing.md),
          TsSkeletonBlock(TsSkeletonType.block),
        ],
      ),
    );
  }
}

class _SoccerPredictBlocksError extends StatelessWidget {
  const _SoccerPredictBlocksError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(height: TsSpacing.lg),
          _SoccerReportBlockCard(
            title: switch (i) {
              0 => 'Prediction',
              1 => 'Reasoning',
              2 => 'Three-method',
              _ => 'Team statistics',
            },
            child: TsEmptyState(
              type: TsEmptyType.failure,
              title: 'Could not load',
              description: 'Match analysis is unavailable right now.',
              actionLabel: 'Retry',
              onAction: onRetry,
            ),
          ),
        ],
      ],
    );
  }
}

String _pickTeamLabel(
  BuildContext context,
  MatchHeaderData header,
  SoccerPickDirection direction,
  AppLocalizations l10n,
) {
  return switch (direction) {
    SoccerPickDirection.home => localizedTeamName(
        context,
        header.homeTeam,
        header.homeTeamKo,
      ),
    SoccerPickDirection.away => localizedTeamName(
        context,
        header.awayTeam,
        header.awayTeamKo,
      ),
    SoccerPickDirection.draw => l10n.soccerDraw,
    SoccerPickDirection.unknown => '-',
  };
}

String? _pickEmblemUrl(MatchHeaderData header, SoccerPickDirection direction) {
  return switch (direction) {
    SoccerPickDirection.home => header.homeTeamLogo,
    SoccerPickDirection.away => header.awayTeamLogo,
    _ => null,
  };
}

String _formatPickProbability(double prob) {
  if (prob <= 0) return '-';
  return '${(prob * 100).round()}%';
}

String _gaugePercentLabel(double fraction) {
  if (fraction <= 0) return '-';
  return '${(fraction * 100).round()}%';
}

String _gradeBadgeLabel(SoccerPredictGrade grade) {
  return switch (grade) {
    SoccerPredictGrade.pick => 'REPORT',
    SoccerPredictGrade.good => 'GOOD',
    SoccerPredictGrade.pass => 'PASS',
  };
}

TsBadgeTone _gradeBadgeTone(SoccerPredictGrade grade) {
  return switch (grade) {
    SoccerPredictGrade.pick => TsBadgeTone.positive,
    SoccerPredictGrade.good => TsBadgeTone.primary,
    SoccerPredictGrade.pass => TsBadgeTone.neutral,
  };
}

String _formatTeamStatValue(double? value, SoccerTeamStatFormat format) {
  if (value == null) return '-';
  return switch (format) {
    SoccerTeamStatFormat.integerPercent => _formatIntegerPercent(value),
    SoccerTeamStatFormat.form => value.toStringAsFixed(1),
    SoccerTeamStatFormat.goalRatio => value.toStringAsFixed(2),
  };
}

String _formatIntegerPercent(double value) {
  final percent = value < 1.0 ? value * 100 : value;
  return '${percent.round()}%';
}

double _teamStatFraction(double? home, double? away, bool forHome) {
  if (home == null || away == null) return 0.5;
  final total = home + away;
  if (total <= 0) return 0.5;
  final ratio = (forHome ? home : away) / total;
  return ratio.clamp(0.0, 1.0);
}
