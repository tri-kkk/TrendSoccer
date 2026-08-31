import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/utils/baseball_status.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/core/utils/match_date_formatter.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_match_hero.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/features_v2/matches/widgets/soccer_predict_report_blocks.dart';

class MatchReportScreen extends ConsumerWidget {
  const MatchReportScreen({
    required this.sport,
    required this.matchId,
    this.initialHeader,
    super.key,
  });

  final String sport;
  final String matchId;
  final MatchHeaderData? initialHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final numericMatchId = int.tryParse(matchId);

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: 'Match Report',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          TsSpacing.lg,
          TsSpacing.lg,
          TsSpacing.lg,
          TsSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(ref, numericMatchId),
            if (sport == 'soccer' && initialHeader != null) ...[
              const SizedBox(height: TsSpacing.lg),
              SoccerPredictReportBlocks(header: initialHeader!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHero(WidgetRef ref, int? numericMatchId) {
    if (sport == 'baseball' && numericMatchId != null) {
      final detailAsync = ref.watch(baseballMatchDetailProvider(numericMatchId));
      return detailAsync.when(
        data: (detail) {
          MatchHeaderData? header = initialHeader;
          if (detail.isNotEmpty) {
            final apiHeader = MatchHeaderData.fromBaseballMatchDetail(
              detail,
              matchId: numericMatchId,
            );
            header = (header ?? apiHeader).mergeWith(apiHeader);
          }
          if (header == null) {
            return const _MatchHeroSkeleton();
          }
          return _MatchReportHero(header: header, sport: sport);
        },
        loading: () {
          if (initialHeader != null) {
            return _MatchReportHero(header: initialHeader!, sport: sport);
          }
          return const _MatchHeroSkeleton();
        },
        error: (_, _) {
          if (initialHeader != null) {
            return _MatchReportHero(header: initialHeader!, sport: sport);
          }
          return const _MatchHeroSkeleton();
        },
      );
    }

    if (initialHeader != null) {
      return _MatchReportHero(header: initialHeader!, sport: sport);
    }
    return const _MatchHeroSkeleton();
  }
}

class _MatchReportHero extends StatelessWidget {
  const _MatchReportHero({
    required this.header,
    required this.sport,
  });

  final MatchHeaderData header;
  final String sport;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final labels = _heroCenterLabels(header, sport: sport, locale: locale);

    return TsMatchHero(
      leagueId: header.resolvedLeagueIconId,
      homeTeam: localizedTeamName(
        context,
        header.homeTeam,
        header.homeTeamKo,
      ),
      awayTeam: localizedTeamName(
        context,
        header.awayTeam,
        header.awayTeamKo,
      ),
      homeEmblemUrl: header.homeTeamLogo,
      awayEmblemUrl: header.awayTeamLogo,
      centerLabel: labels.$1,
      subLabel: labels.$2,
    );
  }
}

class _MatchHeroSkeleton extends StatelessWidget {
  const _MatchHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: TsSpacing.xl,
        horizontal: TsSpacing.md,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsSkeletonBlock(TsSkeletonType.circle, width: 32),
          SizedBox(height: TsSpacing.lg),
          TsSkeletonBlock(TsSkeletonType.block),
        ],
      ),
    );
  }
}

(String? centerLabel, String? subLabel) _heroCenterLabels(
  MatchHeaderData header, {
  required String sport,
  required String locale,
}) {
  final status = header.matchStatus;
  if (status == 'live' || status == 'finished') {
    final home = header.homeScore;
    final away = header.awayScore;
    final center = home != null && away != null ? '$home - $away' : null;
    final sub = switch (status) {
      'finished' => 'FT',
      'live' => sport == 'baseball'
          ? _baseballLiveStatusLabel(header.rawStatus)
          : (header.rawStatus?.trim().isNotEmpty == true
              ? header.rawStatus!.trim().toUpperCase()
              : 'LIVE'),
      _ => null,
    };
    return (center, sub);
  }

  final timestamp = header.matchTimestamp;
  if (timestamp != null) {
    final local = timestamp.toLocal();
    final center = DateFormat('HH:mm').format(local);
    final sub = _heroDateLabel(locale, local);
    return (center, sub);
  }

  if (header.matchTime.isNotEmpty) {
    return (
      header.matchTime,
      header.matchDate.isNotEmpty ? header.matchDate : null,
    );
  }

  return (null, null);
}

String _heroDateLabel(String locale, DateTime local) {
  if (isKoreanLocaleCode(locale)) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[local.weekday - 1];
    return '${local.month}월 ${local.day}일 $weekday요일';
  }
  final month = DateFormat('MMM', 'en').format(local);
  final weekday = DateFormat('EEE', 'en').format(local);
  return '$month ${local.day} ($weekday)';
}

String _baseballLiveStatusLabel(String? rawStatus) {
  final code = rawStatus?.trim().toUpperCase() ?? '';
  if (code.isEmpty) return 'LIVE';
  if (BaseballStatus.isLive(code)) return code;
  return 'LIVE';
}
