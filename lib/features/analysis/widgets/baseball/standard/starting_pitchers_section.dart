import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/features/analysis/models/baseball_standard_parser.dart';
import 'package:trendsoccer/shared/widgets/baseball/position_chip.dart';
import 'package:trendsoccer/shared/widgets/baseball/season_chip.dart';
import 'package:trendsoccer/shared/widgets/report/info_cell.dart';

class PitcherData {
  const PitcherData({
    required this.name,
    required this.pitcherType,
    this.teamLogoUrl,
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
    this.currentSeasonYear,
    this.previousSeasonYear,
  });

  final String name;
  final String pitcherType;
  final String? teamLogoUrl;
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
  final String? currentSeasonYear;
  final String? previousSeasonYear;
}

class StartingPitchersSection extends ConsumerWidget {
  const StartingPitchersSection({
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    PitcherPreviousSeasonDisplay? homePrev;
    PitcherPreviousSeasonDisplay? awayPrev;

    if (_isAsianLeague) {
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

    final previousSeason = previousSeasonYear(currentSeason);

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
                    pitcher: homePitcher,
                    isHome: true,
                    currentSeason: currentSeason,
                    previousSeason: previousSeason,
                    previousSeasonStats: homePrev,
                  ),
                ),
                Expanded(
                  child: _PitcherColumn(
                    leagueCode: leagueCode,
                    pitcher: awayPitcher,
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

  static const _emblemSize = 48.0;

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
        size: 28,
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

  Widget _pitcherEmblem(TsSemanticColors semantic) {
    if (!_isMlb) {
      return _avatarPlaceholder(semantic);
    }

    final photoUrl = pitcher.photoUrl?.trim();
    final teamLogoUrl = pitcher.teamLogoUrl?.trim();

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return _networkEmblem(photoUrl, semantic);
    }
    if (teamLogoUrl != null && teamLogoUrl.isNotEmpty) {
      return _networkEmblem(teamLogoUrl, semantic);
    }
    return _avatarPlaceholder(semantic);
  }

  Widget? _buildPreviousSeasonSection(TsSemanticColors semantic) {
    if (_isMlb) {
      return Column(
        children: [
          Container(
            height: 1,
            width: double.infinity,
            color: semantic.borderSubtle,
          ),
          const SizedBox(height: TsSpacing.md),
          // TODO: Wire previous season pitcher stats — need statsapi.mlb.com integration
          SeasonChip(isCurrent: false, label: previousSeason),
          const SizedBox(height: TsSpacing.md),
          _statsRowTriple(
            v1: pitcher.prevWl,
            l1: 'W-L',
            v2: pitcher.prevIp,
            l2: 'IP',
            v3: pitcher.prevK,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
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
            '-',
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
          if (previousSeasonSection != null) ...[
            const SizedBox(height: TsSpacing.md),
            previousSeasonSection,
          ],
        ],
      ),
    );
  }
}
