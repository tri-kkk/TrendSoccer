import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'package:trendsoccer/design_system/widgets/ts_empty_state.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_skeleton_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_starting_pitchers_section.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class BaseballStartingPitchersReportBlock extends ConsumerWidget {
  const BaseballStartingPitchersReportBlock({
    required this.header,
    required this.retry,
    super.key,
  });

  final MatchHeaderData header;
  final MatchReportRetryButton retry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = _normalizeLeagueCode(header.leagueCode ?? '');
    final title = isKoreanLocale(context)
        ? l10n.baseballSectionPitchersKo
        : l10n.baseballSectionPitchers;

    if (league != 'MLB' && league != 'KBO' && league != 'NPB') {
      return const SizedBox.shrink();
    }

    final detailAsync = ref.watch(baseballMatchDetailProvider(header.matchId));

    return _PitchersReportBlockCard(
      title: title,
      child: detailAsync.when(
        loading: () => const _PitchersReportBlockSkeleton(),
        error: (error, _) => _PitchersReportBlockFailure(
          retry: retry,
          description: resolveApiError(context, error),
        ),
        data: (detail) {
          if (detail.isEmpty) {
            return _PitchersReportBlockEmpty(
              title: title,
              description: l10n.baseballPitcherAnalysisNoData,
            );
          }

          if (league == 'MLB') {
            final statsAsync =
                ref.watch(mlbPitcherStatsProvider(header.matchId));
            final prevAsync =
                ref.watch(mlbPitcherStatsPrevProvider(header.matchId));
            return _buildMergedBody(
              context,
              l10n: l10n,
              league: league,
              detail: detail,
              statsAsync: statsAsync,
              prevStatsResponse: prevAsync.hasValue
                  ? Map<String, dynamic>.from(prevAsync.value!)
                  : null,
            );
          }

          final params = _asianPitcherStatsParams(detail, league);
          final shouldFetchStats = params != null &&
              (params.homePitcher.isNotEmpty ||
                  params.awayPitcher.isNotEmpty);
          if (!shouldFetchStats) {
            final parsed = buildBaseballStartingPitchersParsed(
              leagueCode: league,
              matchDetail: detail,
            );
            return _StartingPitchersSectionContent(
              l10n: l10n,
              league: league,
              parsed: parsed,
            );
          }

          final statsAsync =
              ref.watch(baseballPitcherStatsProvider(params));
          return _buildMergedBody(
            context,
            l10n: l10n,
            league: league,
            detail: detail,
            statsAsync: statsAsync,
          );
        },
      ),
    );
  }

  Widget _buildMergedBody(
    BuildContext context, {
    required AppLocalizations l10n,
    required String league,
    required Map<String, dynamic> detail,
    required AsyncValue<Map<String, dynamic>> statsAsync,
    Map<String, dynamic>? prevStatsResponse,
  }) {
    if (statsAsync.isLoading) {
      return const _PitchersReportBlockSkeleton();
    }

    final stats = statsAsync.hasError
        ? const <String, dynamic>{}
        : (statsAsync.value ?? const <String, dynamic>{});
    final parsed = buildBaseballStartingPitchersParsed(
      leagueCode: league,
      matchDetail: detail,
      statsResponse: stats,
      prevStatsResponse: prevStatsResponse,
    );

    return _StartingPitchersSectionContent(
      l10n: l10n,
      league: league,
      parsed: parsed,
    );
  }
}

class _StartingPitchersSectionContent extends StatelessWidget {
  const _StartingPitchersSectionContent({
    required this.l10n,
    required this.league,
    required this.parsed,
  });

  final AppLocalizations l10n;
  final String league;
  final BaseballStartingPitchersParsed parsed;

  @override
  Widget build(BuildContext context) {
    final showSecondaryStats = league == 'MLB';
    final home = parsed.home;
    final away = parsed.away;

    return TsStartingPitchersSection(
      home: _mapProfile(context, home, isHome: true),
      away: _mapProfile(context, away, isHome: false),
      versusLabel: 'VS',
      stats: _buildPrimaryStats(home, away, showSecondaryStats),
      secondaryStats: showSecondaryStats
          ? _buildSecondaryStats(home, away)
          : const [],
      prevSeasonStats: _buildPrevSeasonStats(home, away),
      prevSeasonTitleLabel: _prevSeasonTitleLabel(home, away),
      showSecondaryStats: showSecondaryStats,
      showComments: true,
    );
  }

  TsPitcherProfile _mapProfile(
    BuildContext context,
    BaseballPitcherSideParsed side, {
    required bool isHome,
  }) {
    if (side.isNameTbd) {
      return TsPitcherProfile(
        positionLabel: isHome ? l10n.labelHome : l10n.labelAway,
        nameLabel: l10n.pitcherTbd,
        handLabel: '',
        photoUrl: null,
        strengths: const [],
        weaknesses: const [],
      );
    }

    final name = localizedPitcherName(context, side.name, side.nameKo);
    return TsPitcherProfile(
      positionLabel: isHome ? l10n.labelHome : l10n.labelAway,
      nameLabel: name.isEmpty ? l10n.pitcherTbd : name,
      handLabel: _handLabel(side.throwingHand),
      photoUrl: side.photoUrl,
      strengths: side.strengths,
      weaknesses: side.weaknesses,
    );
  }

  String _handLabel(String? hand) {
    final normalized = hand?.trim() ?? '';
    if (normalized.isEmpty || normalized == '-') return '';
    switch (normalized.toUpperCase()) {
      case 'L':
        return l10n.baseballPitcherLeftHand;
      case 'R':
        return l10n.baseballPitcherRightHand;
      default:
        if (normalized == '투수' || normalized == l10n.baseballPitcherGeneric) {
          return '';
        }
        return normalized;
    }
  }

  List<TsStatComparison> _buildPrimaryStats(
    BaseballPitcherSideParsed home,
    BaseballPitcherSideParsed away,
    bool isMlb,
  ) {
    final thirdLabel = isMlb ? 'K/9' : 'K';
    return [
      _compareDecimalStat(
        label: 'ERA',
        homeValue: _effectiveValue(home.era, home.isNameTbd),
        awayValue: _effectiveValue(away.era, away.isNameTbd),
        lowerIsBetter: true,
        decimals: 2,
      ),
      _compareDecimalStat(
        label: 'WHIP',
        homeValue: _effectiveValue(home.whip, home.isNameTbd),
        awayValue: _effectiveValue(away.whip, away.isNameTbd),
        lowerIsBetter: true,
        decimals: 2,
      ),
      if (isMlb)
        _compareDecimalStat(
          label: thirdLabel,
          homeValue: _effectiveValue(home.strikeoutsPer9, home.isNameTbd),
          awayValue: _effectiveValue(away.strikeoutsPer9, away.isNameTbd),
          lowerIsBetter: false,
          decimals: 1,
        )
      else
        _compareIntStat(
          label: thirdLabel,
          homeValue: _effectiveInt(home.strikeouts, home.isNameTbd),
          awayValue: _effectiveInt(away.strikeouts, away.isNameTbd),
        ),
    ];
  }

  List<TsStatComparison> _buildSecondaryStats(
    BaseballPitcherSideParsed home,
    BaseballPitcherSideParsed away,
  ) {
    return [
      _compareRecordStat(
        label: 'W-L',
        homeWins: _effectiveInt(home.wins, home.isNameTbd),
        homeLosses: _effectiveInt(home.losses, home.isNameTbd),
        awayWins: _effectiveInt(away.wins, away.isNameTbd),
        awayLosses: _effectiveInt(away.losses, away.isNameTbd),
      ),
      _compareDecimalStat(
        label: 'IP',
        homeValue: _effectiveInnings(home.inningsPitched, home.isNameTbd),
        awayValue: _effectiveInnings(away.inningsPitched, away.isNameTbd),
        lowerIsBetter: false,
        decimals: 1,
      ),
      _compareIntStat(
        label: 'K',
        homeValue: _effectiveInt(home.strikeouts, home.isNameTbd),
        awayValue: _effectiveInt(away.strikeouts, away.isNameTbd),
      ),
    ];
  }

  List<TsStatComparison> _buildPrevSeasonStats(
    BaseballPitcherSideParsed home,
    BaseballPitcherSideParsed away,
  ) {
    if (!_hasPrevSeasonData(home) && !_hasPrevSeasonData(away)) {
      return const [];
    }

    return [
      _compareDecimalStat(
        label: 'ERA',
        homeValue: _effectiveValue(home.prevEra, home.isNameTbd),
        awayValue: _effectiveValue(away.prevEra, away.isNameTbd),
        lowerIsBetter: true,
        decimals: 2,
      ),
      _compareDecimalStat(
        label: 'WHIP',
        homeValue: _effectiveValue(home.prevWhip, home.isNameTbd),
        awayValue: _effectiveValue(away.prevWhip, away.isNameTbd),
        lowerIsBetter: true,
        decimals: 2,
      ),
      _compareIntStat(
        label: 'K',
        homeValue: _effectiveInt(home.prevStrikeouts, home.isNameTbd),
        awayValue: _effectiveInt(away.prevStrikeouts, away.isNameTbd),
      ),
    ];
  }

  String? _prevSeasonTitleLabel(
    BaseballPitcherSideParsed home,
    BaseballPitcherSideParsed away,
  ) {
    return l10n.seasonPrevious;
  }
}

TsStatComparison _compareDecimalStat({
  required String label,
  required double? homeValue,
  required double? awayValue,
  required bool lowerIsBetter,
  required int decimals,
}) {
  return TsStatComparison(
    statLabel: label,
    homeValueLabel: _formatDecimal(homeValue, decimals: decimals),
    awayValueLabel: _formatDecimal(awayValue, decimals: decimals),
    homeFraction: _ratioForNullableValues(
      homeValue,
      awayValue,
      lowerIsBetter: lowerIsBetter,
    ),
  );
}

TsStatComparison _compareIntStat({
  required String label,
  required int? homeValue,
  required int? awayValue,
}) {
  return TsStatComparison(
    statLabel: label,
    homeValueLabel: _formatInt(homeValue),
    awayValueLabel: _formatInt(awayValue),
    homeFraction: _ratioForNullableValues(
      homeValue?.toDouble(),
      awayValue?.toDouble(),
      lowerIsBetter: false,
    ),
  );
}

TsStatComparison _compareRecordStat({
  required String label,
  required int? homeWins,
  required int? homeLosses,
  required int? awayWins,
  required int? awayLosses,
}) {
  return TsStatComparison(
    statLabel: label,
    homeValueLabel: _formatRecord(homeWins, homeLosses),
    awayValueLabel: _formatRecord(awayWins, awayLosses),
    homeFraction: _ratioForNullableValues(
      homeWins?.toDouble(),
      awayWins?.toDouble(),
      lowerIsBetter: false,
    ),
  );
}

double? _effectiveValue(double? value, bool isTbd) => isTbd ? null : value;

int? _effectiveInt(int? value, bool isTbd) => isTbd ? null : value;

double? _effectiveInnings(String? value, bool isTbd) {
  if (isTbd || value == null) return null;
  return double.tryParse(value.trim());
}

double _ratioForNullableValues(
  double? homeValue,
  double? awayValue, {
  required bool lowerIsBetter,
}) {
  return _ratioForValues(
    homeValue ?? 0,
    awayValue ?? 0,
    lowerIsBetter: lowerIsBetter,
  );
}

double _ratioForValues(
  double homeValue,
  double awayValue, {
  required bool lowerIsBetter,
}) {
  if (lowerIsBetter) {
    if (homeValue <= 0 && awayValue <= 0) return 0.5;
    if (homeValue <= 0) return 0;
    if (awayValue <= 0) return 1;
    final homeScore = 1 / homeValue;
    final awayScore = 1 / awayValue;
    final total = homeScore + awayScore;
    return total > 0 ? (homeScore / total).clamp(0.0, 1.0) : 0.5;
  }

  final total = homeValue + awayValue;
  return total > 0 ? (homeValue / total).clamp(0.0, 1.0) : 0.5;
}

String _formatDecimal(double? value, {required int decimals}) {
  if (value == null) return '-';
  return value.toStringAsFixed(decimals);
}

String _formatInt(int? value) {
  if (value == null) return '-';
  return value.toString();
}

String _formatRecord(int? wins, int? losses) {
  if (wins == null && losses == null) return '-';
  if (wins != null && losses != null) return '$wins-$losses';
  if (wins != null) return '$wins-';
  return '-$losses';
}

bool _hasPrevSeasonData(BaseballPitcherSideParsed side) {
  return side.prevEra != null ||
      side.prevWhip != null ||
      side.prevStrikeouts != null;
}

BaseballPitcherStatsParams? _asianPitcherStatsParams(
  Map<String, dynamic> detail,
  String leagueCode,
) {
  final match = _unwrapBaseballMatch(detail);
  final league = _normalizeLeagueCode(leagueCode);
  if (league != 'KBO' && league != 'NPB') return null;

  final homeSide = _readSideMap(match, isHome: true);
  final awaySide = _readSideMap(match, isHome: false);

  final homePitcher = baseballAsianLeagueApiLookupName(
    _readFlatOrNestedString(match, homeSide, const [
      'homePitcher',
      'home_pitcher',
    ]),
    _readFlatOrNestedString(match, homeSide, const [
      'homePitcherKo',
      'home_pitcher_ko',
    ]),
  );
  final awayPitcher = baseballAsianLeagueApiLookupName(
    _readFlatOrNestedString(match, awaySide, const [
      'awayPitcher',
      'away_pitcher',
    ]),
    _readFlatOrNestedString(match, awaySide, const [
      'awayPitcherKo',
      'away_pitcher_ko',
    ]),
  );
  final homeTeam = baseballAsianLeagueApiLookupTeam(
    _readFlatOrNestedString(match, homeSide, const [
      'homeTeam',
      'home_team',
    ]) ??
        _readString(homeSide, const ['team', 'name']),
    _readFlatOrNestedString(match, homeSide, const [
      'homeTeamKo',
      'home_team_ko',
    ]) ??
        _readString(homeSide, const ['teamKo', 'team_ko']),
  );
  final awayTeam = baseballAsianLeagueApiLookupTeam(
    _readFlatOrNestedString(match, awaySide, const [
      'awayTeam',
      'away_team',
    ]) ??
        _readString(awaySide, const ['team', 'name']),
    _readFlatOrNestedString(match, awaySide, const [
      'awayTeamKo',
      'away_team_ko',
    ]) ??
        _readString(awaySide, const ['teamKo', 'team_ko']),
  );

  return (
    league: league.toLowerCase(),
    homePitcher: homePitcher,
    awayPitcher: awayPitcher,
    homeTeam: homeTeam,
    awayTeam: awayTeam,
  );
}

Map<String, dynamic> _readSideMap(
  Map<String, dynamic> match, {
  required bool isHome,
}) {
  final side = match[isHome ? 'home' : 'away'];
  if (side is Map<String, dynamic>) return side;
  if (side is Map) return Map<String, dynamic>.from(side);
  return const {};
}

String? _readFlatOrNestedString(
  Map<String, dynamic> match,
  Map<String, dynamic> side,
  List<String> flatKeys,
) {
  for (final key in flatKeys) {
    final value = match[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _readString(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  for (final key in keys) {
    final value = json[key];
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }
  return null;
}

String _normalizeLeagueCode(String? league) {
  final upper = (league ?? '').trim().toUpperCase();
  if (upper.contains('MLB') || upper.contains('MAJOR')) return 'MLB';
  if (upper.contains('NPB')) return 'NPB';
  if (upper.contains('KBO') || upper.contains('KOREA')) return 'KBO';
  return upper;
}

Map<String, dynamic> _unwrapBaseballMatch(Map<String, dynamic> detail) {
  final match = detail['match'];
  if (match is Map<String, dynamic>) return match;
  if (match is Map) return Map<String, dynamic>.from(match);

  if (detail['matches'] is List && (detail['matches'] as List).isNotEmpty) {
    final first = (detail['matches'] as List).first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return Map<String, dynamic>.from(first);
  }

  return detail;
}

class _PitchersReportBlockCard extends StatelessWidget {
  const _PitchersReportBlockCard({
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
          TsSectionHeader(title: title, icon: TsIcons.baseball),
          const SizedBox(height: TsSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _PitchersReportBlockSkeleton extends StatelessWidget {
  const _PitchersReportBlockSkeleton();

  @override
  Widget build(BuildContext context) {
    return const TsSkeletonBlock(TsSkeletonType.block);
  }
}

class _PitchersReportBlockFailure extends StatelessWidget {
  const _PitchersReportBlockFailure({
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

class _PitchersReportBlockEmpty extends StatelessWidget {
  const _PitchersReportBlockEmpty({
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
