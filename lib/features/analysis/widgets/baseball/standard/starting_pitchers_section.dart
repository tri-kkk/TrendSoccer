import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';
import 'package:trendsoccer/shared/widgets/baseball/pitcher_comment_chip.dart';
import 'package:trendsoccer/shared/widgets/baseball/position_chip.dart';
import 'package:trendsoccer/shared/widgets/baseball/season_chip.dart';
import 'package:trendsoccer/shared/widgets/report/info_cell.dart';

class PitcherData {
  const PitcherData({
    required this.name,
    required this.pitcherType,
    this.teamLogoUrl,
    this.pitcherId,
    this.photoUrl,
    required this.era,
    required this.whip,
    required this.k9,
    required this.wl,
    required this.ip,
    required this.k,
    required this.prevWl,
    required this.prevIp,
    required this.prevK,
    required this.strengths,
    required this.weaknesses,
    this.summary,
    this.currentSeasonYear,
    this.previousSeasonYear,
  });

  final String name;
  final String pitcherType;
  final String? teamLogoUrl;
  final int? pitcherId;
  final String? photoUrl;
  final String era;
  final String whip;
  final String k9;
  final String wl;
  final String ip;
  final String k;
  final String prevWl;
  final String prevIp;
  final String prevK;
  final List<String> strengths;
  final List<String> weaknesses;
  final String? summary;
  final String? currentSeasonYear;
  final String? previousSeasonYear;
}

class StartingPitchersSection extends ConsumerWidget {
  const StartingPitchersSection({
    required this.matchId,
    required this.leagueCode,
    required this.currentSeason,
    required this.homeTeam,
    required this.awayTeam,
    required this.homePitcherName,
    required this.awayPitcherName,
    required this.awayPitcher,
    required this.homePitcher,
    super.key,
  });

  final int matchId;
  final String leagueCode;
  final String currentSeason;
  final String homeTeam;
  final String awayTeam;
  final String homePitcherName;
  final String awayPitcherName;
  final PitcherData awayPitcher;
  final PitcherData homePitcher;

  bool get _isAsianLeague => leagueCode == 'KBO' || leagueCode == 'NPB';

  static String previousSeasonYear(String currentSeason) {
    final parsed = int.tryParse(currentSeason.trim());
    if (parsed != null) return (parsed - 1).toString();
    return (DateTime.now().year - 1).toString();
  }

  bool get _isMlb => leagueCode == 'MLB';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    var homeDisplay = homePitcher;
    var awayDisplay = awayPitcher;

    PitcherPreviousSeasonDisplay? homePrev;
    PitcherPreviousSeasonDisplay? awayPrev;

    if (_isMlb) {
      final statsData = switch (ref.watch(mlbPitcherStatsProvider(matchId))) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (statsData != null) {
        final homeRaw = statsData['homePitcher'];
        final awayRaw = statsData['awayPitcher'];
        homeDisplay = _mergeMlbPitcherStats(
          homeDisplay,
          homeRaw is Map ? Map<String, dynamic>.from(homeRaw) : null,
        );
        awayDisplay = _mergeMlbPitcherStats(
          awayDisplay,
          awayRaw is Map ? Map<String, dynamic>.from(awayRaw) : null,
        );
      }

      final prevData = switch (ref.watch(mlbPitcherStatsPrevProvider(matchId))) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (prevData != null) {
        final seasonLabel =
            (prevData['season'] as num?)?.toInt() ?? DateTime.now().year - 1;
        final homePrevRaw = prevData['homePitcher'];
        final awayPrevRaw = prevData['awayPitcher'];
        homePrev = parseMlbPitcherPreviousSeason(
          pitcherRaw:
              homePrevRaw is Map ? Map<String, dynamic>.from(homePrevRaw) : null,
          seasonLabel: seasonLabel,
        );
        awayPrev = parseMlbPitcherPreviousSeason(
          pitcherRaw:
              awayPrevRaw is Map ? Map<String, dynamic>.from(awayPrevRaw) : null,
          seasonLabel: seasonLabel,
        );
      }
    } else if (_isAsianLeague) {
      final statsData = switch (
        ref.watch(
          baseballPitcherStatsProvider(
            (
              league: leagueCode.toLowerCase(),
              homePitcher: homePitcherName,
              awayPitcher: awayPitcherName,
              homeTeam: homeTeam,
              awayTeam: awayTeam,
            ),
          ),
        )
      ) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (statsData != null) {
        final homeRaw = statsData['homePitcherPrev'];
        final awayRaw = statsData['awayPitcherPrev'];
        homePrev = parsePitcherPreviousSeason(
          homeRaw is Map ? Map<String, dynamic>.from(homeRaw) : null,
        );
        awayPrev = parsePitcherPreviousSeason(
          awayRaw is Map ? Map<String, dynamic>.from(awayRaw) : null,
        );
      }
    }

    final previousSeason =
        _isMlb ? (DateTime.now().year - 1).toString() : previousSeasonYear(currentSeason);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선발 투수',
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: semantic.surfaceRaised,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _PitcherColumn(
                    leagueCode: leagueCode,
                    pitcher: homeDisplay,
                    isHome: true,
                    currentSeason: currentSeason,
                    previousSeason: previousSeason,
                    previousSeasonStats: homePrev,
                  ),
                ),
                Expanded(
                  child: _PitcherColumn(
                    leagueCode: leagueCode,
                    pitcher: awayDisplay,
                    isHome: false,
                    currentSeason: currentSeason,
                    previousSeason: previousSeason,
                    previousSeasonStats: awayPrev,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PitcherColumn extends StatelessWidget {
  const _PitcherColumn({
    required this.leagueCode,
    required this.pitcher,
    required this.isHome,
    required this.currentSeason,
    required this.previousSeason,
    this.previousSeasonStats,
  });

  final String leagueCode;
  final PitcherData pitcher;
  final bool isHome;
  final String currentSeason;
  final String previousSeason;
  final PitcherPreviousSeasonDisplay? previousSeasonStats;

  static const _emblemSize = 80.0;

  bool get _isMlb => leagueCode == 'MLB';

  static Widget _statsRowTriple({
    required String v1,
    required String l1,
    required String v2,
    required String l2,
    required String v3,
    required String l3,
  }) {
    return Row(
      children: [
        Expanded(child: InfoCell(value: v1, label: l1)),
        const SizedBox(width: TsSpacing.sm),
        Expanded(child: InfoCell(value: v2, label: l2)),
        const SizedBox(width: TsSpacing.sm),
        Expanded(child: InfoCell(value: v3, label: l3)),
      ],
    );
  }

  Widget _avatarPlaceholder(TsSemanticColors semantic) {
    return Container(
      width: _emblemSize,
      height: _emblemSize,
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: 40,
        color: semantic.textTertiary,
      ),
    );
  }

  Widget _networkEmblem(String url, TsSemanticColors semantic) {
    return ClipOval(
      child: SizedBox(
        width: _emblemSize,
        height: _emblemSize,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => _avatarPlaceholder(semantic),
          errorWidget: (context, url, error) => _avatarPlaceholder(semantic),
        ),
      ),
    );
  }

  Widget _mlbPitcherPhotoEmblem(String imageUrl, TsSemanticColors semantic) {
    final teamLogoUrl = pitcher.teamLogoUrl?.trim();

    return Container(
      width: _emblemSize,
      height: _emblemSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: semantic.surfaceContainer,
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: _emblemSize,
        height: _emblemSize,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        placeholder: (context, _) => _avatarPlaceholder(semantic),
        errorWidget: (context, url, error) {
          if (teamLogoUrl != null && teamLogoUrl.isNotEmpty) {
            return CachedNetworkImage(
              imageUrl: teamLogoUrl,
              fit: BoxFit.cover,
              width: _emblemSize,
              height: _emblemSize,
              placeholder: (context, _) => _avatarPlaceholder(semantic),
              errorWidget: (context, url, error) =>
                  _avatarPlaceholder(semantic),
            );
          }
          return _avatarPlaceholder(semantic);
        },
      ),
    );
  }

  Widget _photoEmblem(String photoUrl, TsSemanticColors semantic) {
    return _mlbPitcherPhotoEmblem(photoUrl, semantic);
  }

  Widget _mlbHeadshotEmblem(int pitcherId, TsSemanticColors semantic) {
    return _mlbPitcherPhotoEmblem(mlbPitcherPhotoUrl(pitcherId), semantic);
  }

  Widget _pitcherEmblem(TsSemanticColors semantic) {
    if (!_isMlb) {
      return _avatarPlaceholder(semantic);
    }

    final photoUrl = pitcher.photoUrl?.trim();
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return _photoEmblem(optimizeMlbPhotoUrl(photoUrl), semantic);
    }

    final pitcherId = pitcher.pitcherId;
    if (pitcherId != null) {
      return _mlbHeadshotEmblem(pitcherId, semantic);
    }

    final teamLogoUrl = pitcher.teamLogoUrl?.trim();
    if (teamLogoUrl != null && teamLogoUrl.isNotEmpty) {
      return _networkEmblem(teamLogoUrl, semantic);
    }
    return _avatarPlaceholder(semantic);
  }

  Widget? _buildCommentChips() {
    if (!_isMlb) return null;

    final displayStrengths =
        pitcher.strengths.map(stripParenthetical).toList();
    final displayWeaknesses =
        pitcher.weaknesses.map(stripParenthetical).toList();
    if (displayStrengths.isEmpty && displayWeaknesses.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final text in displayStrengths)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: PitcherCommentChip(text: text, isStrength: true),
          ),
        for (final text in displayWeaknesses)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: PitcherCommentChip(text: text, isStrength: false),
          ),
      ],
    );
  }

  Widget? _buildPreviousSeasonSection(TsSemanticColors semantic) {
    if (_isMlb) {
      final prev = previousSeasonStats;
      if (prev == null) return null;

      return Column(
        children: [
          Container(
            height: 1,
            width: double.infinity,
            color: semantic.borderSubtle,
          ),
          const SizedBox(height: TsSpacing.md),
          SeasonChip(isCurrent: false, label: previousSeason),
          const SizedBox(height: TsSpacing.md),
          _statsRowTriple(
            v1: prev.era,
            l1: 'ERA',
            v2: prev.whip,
            l2: 'WHIP',
            v3: prev.strikeouts,
            l3: 'K',
          ),
        ],
      );
    }

    final prev = previousSeasonStats;
    if (prev == null || !prev.hasData) return null;

    return Column(
      children: [
        Container(
          height: 1,
          width: double.infinity,
          color: semantic.borderSubtle,
        ),
        const SizedBox(height: TsSpacing.md),
        SeasonChip(isCurrent: false, label: previousSeason),
        const SizedBox(height: TsSpacing.md),
        _statsRowTriple(
          v1: prev.era,
          l1: 'ERA',
          v2: prev.whip,
          l2: 'WHIP',
          v3: prev.strikeouts,
          l3: 'K',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final thirdStatValue = _isMlb ? pitcher.k9 : pitcher.k;
    final thirdStatLabel = _isMlb ? 'K/9' : 'K';
    final previousSeasonSection = _buildPreviousSeasonSection(semantic);
    final commentChips = _buildCommentChips();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PositionChip(isHome: isHome),
          const SizedBox(height: TsSpacing.md),
          _pitcherEmblem(semantic),
          const SizedBox(height: TsSpacing.md),
          Text(
            pitcher.name,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.xs),
          Text(
            pitcher.pitcherType.isNotEmpty && pitcher.pitcherType != '투수'
                ? pitcher.pitcherType
                : '-',
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.md),
          SeasonChip(isCurrent: true, label: currentSeason),
          const SizedBox(height: TsSpacing.md),
          Container(
            height: 1,
            width: double.infinity,
            color: semantic.borderSubtle,
          ),
          const SizedBox(height: TsSpacing.md),
          _statsRowTriple(
            v1: pitcher.era,
            l1: 'ERA',
            v2: pitcher.whip,
            l2: 'WHIP',
            v3: thirdStatValue,
            l3: thirdStatLabel,
          ),
          if (_isMlb) ...[
            const SizedBox(height: TsSpacing.sm),
            _statsRowTriple(
              v1: pitcher.wl,
              l1: 'W-L',
              v2: pitcher.ip,
              l2: 'IP',
              v3: pitcher.k,
              l3: 'K',
            ),
          ],
          if (commentChips != null) ...[
            const SizedBox(height: TsSpacing.md),
            commentChips,
          ],
          if (previousSeasonSection != null) ...[
            const Spacer(),
            const SizedBox(height: TsSpacing.md),
            previousSeasonSection,
          ],
        ],
      ),
    );
  }
}

String stripParenthetical(String text) {
  final parenIndex = text.indexOf(' (');
  if (parenIndex > 0) return text.substring(0, parenIndex);
  return text;
}

String optimizeMlbPhotoUrl(String url) {
  return url.replaceFirst('w_213', 'w_120');
}

String mlbPitcherPhotoUrl(int pitcherId) {
  return 'https://img.mlbstatic.com/mlb-photos/image/upload/d_people:generic:headshot:67:current.png/w_120,q_auto:best/v1/people/$pitcherId/headshot/67/current';
}

String _mlbThrowingHandLabel(Object? hand) {
  switch (hand?.toString().trim().toUpperCase()) {
    case 'L':
      return '좌완 투수';
    case 'R':
      return '우완 투수';
    default:
      return '투수';
  }
}

String _formatMlbStat(Object? value, {int decimals = 2}) {
  if (value == null) return '-';
  if (value is num) return value.toStringAsFixed(decimals);
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

List<String> _mlbStringList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

PitcherData _mergeMlbPitcherStats(
  PitcherData base,
  Map<String, dynamic>? stats,
) {
  if (stats == null || stats.isEmpty) return base;

  final strengths = _mlbStringList(stats['strengths']);
  final weaknesses = _mlbStringList(stats['weakness'] ?? stats['weaknesses']);
  final name = (stats['fullName'] as String?)?.trim();
  final summary = (stats['summary'] as String?)?.trim();
  final photo = (stats['photo'] as String?)?.trim();
  final playerId = (stats['playerId'] as num?)?.toInt();
  final resolvedPhoto = photo != null && photo.isNotEmpty
      ? optimizeMlbPhotoUrl(photo)
      : base.photoUrl;

  return PitcherData(
    name: name != null && name.isNotEmpty ? name : base.name,
    pitcherType: _mlbThrowingHandLabel(stats['throwingHand']),
    teamLogoUrl: base.teamLogoUrl,
    pitcherId: playerId ?? base.pitcherId,
    photoUrl: resolvedPhoto,
    era: _formatMlbStat(stats['era'], decimals: 2),
    whip: _formatMlbStat(stats['whip'], decimals: 2),
    k9: _formatMlbStat(stats['strikeoutsPer9Inn'], decimals: 1),
    wl:
        '${(stats['wins'] as num?)?.toInt() ?? 0}-${(stats['losses'] as num?)?.toInt() ?? 0}',
    ip: _formatMlbIp(stats['inningsPitched']),
    k: _formatMlbK(stats['strikeOuts']),
    prevWl: base.prevWl,
    prevIp: base.prevIp,
    prevK: base.prevK,
    strengths: strengths.isNotEmpty ? strengths : base.strengths,
    weaknesses: weaknesses.isNotEmpty ? weaknesses : base.weaknesses,
    summary: summary?.isNotEmpty == true ? summary : base.summary,
    currentSeasonYear: base.currentSeasonYear,
    previousSeasonYear: base.previousSeasonYear,
  );
}

String _formatMlbIp(Object? value) {
  if (value == null) return '-';
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

String _formatMlbK(Object? value) {
  if (value == null) return '-';
  if (value is num) return value.toInt().toString();
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

String _mlbSafeStatString(dynamic value) {
  if (value == null) return '-';
  if (value is num) return value.toStringAsFixed(2);
  final text = value.toString().trim();
  return text.isEmpty ? '-' : text;
}

PitcherPreviousSeasonDisplay? parseMlbPitcherPreviousSeason({
  Map<String, dynamic>? pitcherRaw,
  required int seasonLabel,
}) {
  if (pitcherRaw == null || pitcherRaw.isEmpty) return null;

  final era = _mlbSafeStatString(pitcherRaw['era']);
  final whip = _mlbSafeStatString(pitcherRaw['whip']);
  final strikeouts = _formatMlbK(pitcherRaw['strikeOuts']);

  if (era == '-' && whip == '-' && strikeouts == '-') {
    return null;
  }

  return PitcherPreviousSeasonDisplay(
    seasonLabel: seasonLabel.toString(),
    era: era,
    whip: whip,
    strikeouts: strikeouts,
  );
}
