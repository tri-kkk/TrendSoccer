import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/shared/widgets/baseball/pitcher_comment_chip.dart';
import 'package:trendsoccer/shared/widgets/baseball/position_chip.dart';
import 'package:trendsoccer/shared/widgets/baseball/season_chip.dart';

class PitcherData {
  const PitcherData({
    required this.name,
    this.nameKo,
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
    this.season,
    this.prevSeason,
  });

  final String name;
  final String? nameKo;
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
  final String? season;
  final String? prevSeason;
}

bool isPitcherNameTbd(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty || trimmed == '-') return true;
  final upper = trimmed.toUpperCase();
  return upper == 'TBD' || trimmed == '미정';
}

String displayPitcherName(AppLocalizations l10n, String name) {
  if (isPitcherNameTbd(name)) return l10n.pitcherTbd;
  return name;
}

bool shouldShowPitcherHandedness({
  required String pitcherName,
  required String pitcherType,
  required AppLocalizations l10n,
}) {
  if (isPitcherNameTbd(pitcherName)) return false;
  final type = pitcherType.trim();
  if (type.isEmpty || type == '-') return false;
  if (type == '투수' || type == l10n.baseballPitcherGeneric) return false;
  return true;
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
    this.homePitcherLookupName,
    this.awayPitcherLookupName,
    this.homeTeamLookupName,
    this.awayTeamLookupName,
    super.key,
  });

  final int matchId;
  final String leagueCode;
  final String currentSeason;
  final String homeTeam;
  final String awayTeam;
  final String homePitcherName;
  final String awayPitcherName;
  final String? homePitcherLookupName;
  final String? awayPitcherLookupName;
  final String? homeTeamLookupName;
  final String? awayTeamLookupName;
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
    final l10n = context.l10n;

    final defaultPrevSeason = previousSeasonYear(currentSeason);
    var homeDisplay = _withSeasonLabels(
      homePitcher,
      season: homePitcher.season ?? currentSeason,
      prevSeason: homePitcher.prevSeason ?? defaultPrevSeason,
    );
    var awayDisplay = _withSeasonLabels(
      awayPitcher,
      season: awayPitcher.season ?? currentSeason,
      prevSeason: awayPitcher.prevSeason ?? defaultPrevSeason,
    );

    Map<String, dynamic>? homePrevRaw;
    Map<String, dynamic>? awayPrevRaw;
    List<String> homeStrengths = const [];
    List<String> homeWeaknesses = const [];
    List<String> awayStrengths = const [];
    List<String> awayWeaknesses = const [];

    if (_isMlb) {
      final statsData = switch (ref.watch(mlbPitcherStatsProvider(matchId))) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (statsData != null) {
        final home = statsData['homePitcher'];
        final away = statsData['awayPitcher'];
        if (home is Map) {
          homeStrengths = (home['strengths'] as List?)?.cast<String>() ?? [];
          homeWeaknesses = (home['weakness'] as List?)?.cast<String>() ??
              (home['weaknesses'] as List?)?.cast<String>() ??
              [];
        }
        if (away is Map) {
          awayStrengths = (away['strengths'] as List?)?.cast<String>() ?? [];
          awayWeaknesses = (away['weakness'] as List?)?.cast<String>() ??
              (away['weaknesses'] as List?)?.cast<String>() ??
              [];
        }

        final homeRaw = statsData['homePitcher'];
        final awayRaw = statsData['awayPitcher'];
        homeDisplay = _mergeMlbPitcherStats(
          l10n,
          homeDisplay,
          homeRaw is Map ? Map<String, dynamic>.from(homeRaw) : null,
          preferEnglishChips: !isKoreanLocale(context),
        );
        awayDisplay = _mergeMlbPitcherStats(
          l10n,
          awayDisplay,
          awayRaw is Map ? Map<String, dynamic>.from(awayRaw) : null,
          preferEnglishChips: !isKoreanLocale(context),
        );
        final rootSeason = _readSeasonField(statsData['season']);
        if (rootSeason != null) {
          homeDisplay = _withSeasonLabels(homeDisplay, season: rootSeason);
          awayDisplay = _withSeasonLabels(awayDisplay, season: rootSeason);
        }
      }

      final prevData = switch (ref.watch(mlbPitcherStatsPrevProvider(matchId))) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (prevData != null) {
        final homeRaw = prevData['homePitcher'];
        final awayRaw = prevData['awayPitcher'];
        homePrevRaw = homeRaw is Map
            ? Map<String, dynamic>.from(homeRaw)
            : null;
        awayPrevRaw = awayRaw is Map
            ? Map<String, dynamic>.from(awayRaw)
            : null;
        final prevSeasonLabel = _readSeasonField(prevData['season']) ??
            previousSeasonYear(currentSeason);
        homeDisplay = _withSeasonLabels(
          homeDisplay,
          prevSeason: _readSeasonField(homePrevRaw?['season']) ?? prevSeasonLabel,
        );
        awayDisplay = _withSeasonLabels(
          awayDisplay,
          prevSeason: _readSeasonField(awayPrevRaw?['season']) ?? prevSeasonLabel,
        );
      }
    } else if (_isAsianLeague) {
      final preferEnglishChips = !isKoreanLocale(context);
      final statsData = switch (
        ref.watch(
          baseballPitcherStatsProvider(
            (
              league: leagueCode.toLowerCase(),
              homePitcher: homePitcherLookupName ?? homePitcherName,
              awayPitcher: awayPitcherLookupName ?? awayPitcherName,
              homeTeam: homeTeamLookupName ?? homeTeam,
              awayTeam: awayTeamLookupName ?? awayTeam,
            ),
          ),
        )
      ) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (statsData != null) {
        final home = statsData['homePitcher'];
        final away = statsData['awayPitcher'];
        if (home is Map) {
          homeStrengths = (home['strengths'] as List?)?.cast<String>() ?? [];
          homeWeaknesses = (home['weakness'] as List?)?.cast<String>() ??
              (home['weaknesses'] as List?)?.cast<String>() ??
              [];
        }
        if (away is Map) {
          awayStrengths = (away['strengths'] as List?)?.cast<String>() ?? [];
          awayWeaknesses = (away['weakness'] as List?)?.cast<String>() ??
              (away['weaknesses'] as List?)?.cast<String>() ??
              [];
        }

        final homeCurrentRaw = statsData['homePitcher'];
        final awayCurrentRaw = statsData['awayPitcher'];
        homeDisplay = _mergeKboPitcherStats(
          homeDisplay,
          homeCurrentRaw is Map
              ? Map<String, dynamic>.from(homeCurrentRaw)
              : null,
          preferEnglishChips: preferEnglishChips,
        );
        awayDisplay = _mergeKboPitcherStats(
          awayDisplay,
          awayCurrentRaw is Map
              ? Map<String, dynamic>.from(awayCurrentRaw)
              : null,
          preferEnglishChips: preferEnglishChips,
        );

        final homeRaw = statsData['homePitcherPrev'];
        final awayRaw = statsData['awayPitcherPrev'];
        homePrevRaw = homeRaw is Map
            ? Map<String, dynamic>.from(homeRaw)
            : null;
        awayPrevRaw = awayRaw is Map
            ? Map<String, dynamic>.from(awayRaw)
            : null;

        final rootSeason = _readSeasonField(statsData['season']);
        if (rootSeason != null) {
          homeDisplay = _withSeasonLabels(homeDisplay, season: rootSeason);
          awayDisplay = _withSeasonLabels(awayDisplay, season: rootSeason);
        }
        homeDisplay = _withSeasonLabels(
          homeDisplay,
          prevSeason:
              _readSeasonField(homePrevRaw?['season']) ?? homeDisplay.prevSeason,
        );
        awayDisplay = _withSeasonLabels(
          awayDisplay,
          prevSeason:
              _readSeasonField(awayPrevRaw?['season']) ?? awayDisplay.prevSeason,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.baseballSectionPitchersKo,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: TsSpacing.sm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: semantic.surfaceBase,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PitcherSide(
                      leagueCode: leagueCode,
                      pitcher: homeDisplay,
                      isHome: true,
                    ).buildProfile(context),
                  ),
                  Expanded(
                    child: _PitcherSide(
                      leagueCode: leagueCode,
                      pitcher: awayDisplay,
                      isHome: false,
                    ).buildProfile(context),
                  ),
                ],
              ),
              _PitcherSide.sectionDivider(semantic),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PitcherSide(
                      leagueCode: leagueCode,
                      pitcher: homeDisplay,
                      isHome: true,
                    ).buildCurrentStats(context),
                  ),
                  Expanded(
                    child: _PitcherSide(
                      leagueCode: leagueCode,
                      pitcher: awayDisplay,
                      isHome: false,
                    ).buildCurrentStats(context),
                  ),
                ],
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _PitcherSide(
                        leagueCode: leagueCode,
                        pitcher: homeDisplay,
                        isHome: true,
                        directStrengths: homeStrengths,
                        directWeaknesses: homeWeaknesses,
                      ).buildCommentChips(context),
                    ),
                    Expanded(
                      child: _PitcherSide(
                        leagueCode: leagueCode,
                        pitcher: awayDisplay,
                        isHome: false,
                        directStrengths: awayStrengths,
                        directWeaknesses: awayWeaknesses,
                      ).buildCommentChips(context),
                    ),
                  ],
                ),
              ),
              _PitcherSide.sectionDivider(semantic),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PitcherSide(
                      leagueCode: leagueCode,
                      pitcher: homeDisplay,
                      isHome: true,
                      previousSeasonStatsRaw: homePrevRaw,
                    ).buildPreviousSeason(context),
                  ),
                  Expanded(
                    child: _PitcherSide(
                      leagueCode: leagueCode,
                      pitcher: awayDisplay,
                      isHome: false,
                      previousSeasonStatsRaw: awayPrevRaw,
                    ).buildPreviousSeason(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PitcherStatsCard extends StatelessWidget {
  const _PitcherStatsCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Container(
      padding: const EdgeInsets.all(TsSpacing.sm),
      decoration: BoxDecoration(
        color: semantic.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              value,
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: TsSpacing.sm),
          Text(
            label,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PitcherSide {
  const _PitcherSide({
    required this.leagueCode,
    required this.pitcher,
    required this.isHome,
    this.previousSeasonStatsRaw,
    this.directStrengths,
    this.directWeaknesses,
  });

  final String leagueCode;
  final PitcherData pitcher;
  final bool isHome;
  final Map<String, dynamic>? previousSeasonStatsRaw;
  final List<String>? directStrengths;
  final List<String>? directWeaknesses;

  static const _handednessLineHeight = 17.0;
  static const _emblemSize = 80.0;

  bool get _isMlb => leagueCode == 'MLB';

  bool get _isAsianLeague => leagueCode == 'KBO' || leagueCode == 'NPB';

  bool get _showCommentChips => _isMlb || _isAsianLeague;

  String get _currentSeasonLabel =>
      pitcher.season ?? '${DateTime.now().year}';

  String get _previousSeasonLabel =>
      pitcher.prevSeason ?? '${DateTime.now().year - 1}';

  bool get _isTbd =>
      isPitcherNameTbd(pitcher.name) && isPitcherNameTbd(pitcher.nameKo);

  static Widget sectionDivider(TsSemanticColors semantic) {
    return Container(
      height: 1,
      width: double.infinity,
      color: semantic.borderSubtle,
    );
  }

  Widget buildProfile(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final localizedName = localizedPitcherName(
      context,
      pitcher.name,
      pitcher.nameKo,
    );
    final displayName = displayPitcherName(l10n, localizedName);
    final showHandedness = shouldShowPitcherHandedness(
      pitcherName: localizedName,
      pitcherType: pitcher.pitcherType,
      l10n: l10n,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PositionChip(isHome: isHome),
          const SizedBox(height: TsSpacing.md),
          _pitcherEmblem(semantic),
          const SizedBox(height: TsSpacing.md),
          Text(
            displayName,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.xs),
          SizedBox(
            height: _handednessLineHeight,
            child: showHandedness
                ? Center(
                    child: Text(
                      pitcher.pitcherType,
                      style: TsType.labelSRegular.copyWith(
                        color: semantic.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: TsSpacing.md),
          SeasonChip(isCurrent: true, label: _currentSeasonLabel),
        ],
      ),
    );
  }

  Widget buildCurrentStats(BuildContext context) {
    const dash = '-';
    final era = _isTbd ? dash : pitcher.era;
    final whip = _isTbd ? dash : pitcher.whip;
    final k9 = _isTbd ? dash : pitcher.k9;
    final wl = _isTbd ? dash : pitcher.wl;
    final ip = _isTbd ? dash : pitcher.ip;
    final k = _isTbd ? dash : pitcher.k;
    final thirdStatValue = _isMlb ? k9 : k;
    final thirdStatLabel = _isMlb ? 'K/9' : 'K';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PitcherSideStatsRow.triple(
            v1: era,
            l1: 'ERA',
            v2: whip,
            l2: 'WHIP',
            v3: thirdStatValue,
            l3: thirdStatLabel,
          ),
          if (_isMlb) ...[
            const SizedBox(height: TsSpacing.sm),
            _PitcherSideStatsRow.triple(
              v1: wl,
              l1: 'W-L',
              v2: ip,
              l2: 'IP',
              v3: k,
              l3: 'K',
            ),
          ],
        ],
      ),
    );
  }

  Widget buildCommentChips(BuildContext context) {
    final strengthsSource = directStrengths ?? pitcher.strengths;
    final weaknessesSource = directWeaknesses ?? pitcher.weaknesses;
    final displayStrengths = _isTbd || !_showCommentChips
        ? const <String>[]
        : strengthsSource.map(stripParenthetical).toList();
    final displayWeaknesses = _isTbd || !_showCommentChips
        ? const <String>[]
        : weaknessesSource.map(stripParenthetical).toList();

    final chipWidgets = <Widget>[
      for (final text in displayStrengths)
        PitcherCommentChip(text: text, isStrength: true),
      for (final text in displayWeaknesses)
        PitcherCommentChip(text: text, isStrength: false),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.md),
      child: chipWidgets.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < chipWidgets.length; i++) ...[
                  if (i > 0) const SizedBox(height: TsSpacing.sm),
                  chipWidgets[i],
                ],
              ],
            ),
    );
  }

  Widget buildPreviousSeason(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TsSpacing.sm, vertical: TsSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: SeasonChip(isCurrent: false, label: _previousSeasonLabel)),
          const SizedBox(height: TsSpacing.md),
          _buildPrevSeasonStats(),
        ],
      ),
    );
  }

  Widget _buildPrevSeasonStats() {
    if (_isTbd) {
      return _PitcherSideStatsRow.triple(
        v1: '-',
        l1: 'ERA',
        v2: '-',
        l2: 'WHIP',
        v3: '-',
        l3: 'K',
      );
    }

    return _PitcherSideStatsRow.triple(
      v1: _formatPrevEra(previousSeasonStatsRaw),
      l1: 'ERA',
      v2: _formatPrevWhip(previousSeasonStatsRaw),
      l2: 'WHIP',
      v3: _formatPrevK(previousSeasonStatsRaw),
      l3: 'K',
    );
  }

  String _formatPrevEra(Map<String, dynamic>? prevStats) {
    if (prevStats == null) return '-';
    return _formatMlbStat(prevStats['era'], decimals: 2);
  }

  String _formatPrevWhip(Map<String, dynamic>? prevStats) {
    if (prevStats == null) return '-';
    return _formatMlbStat(prevStats['whip'], decimals: 2);
  }

  String _formatPrevK(Map<String, dynamic>? prevStats) {
    if (prevStats == null) return '-';
    final k =
        prevStats['strikeOuts'] ?? prevStats['strikeouts'] ?? prevStats['k'];
    return _formatMlbK(k);
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
        size: 32,
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
    if (_isTbd) {
            return _avatarPlaceholder(semantic);
    }

    if (!_isMlb) {
      final photoUrl = pitcher.photoUrl?.trim();
      if (photoUrl != null && photoUrl.isNotEmpty) {
        return _photoEmblem(photoUrl, semantic);
      }
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
}

abstract final class _PitcherSideStatsRow {
  static Widget triple({
    required String v1,
    required String l1,
    required String v2,
    required String l2,
    required String v3,
    required String l3,
  }) {
    return Row(
      children: [
        Expanded(child: _PitcherStatsCard(value: v1, label: l1)),
        const SizedBox(width: TsSpacing.sm),
        Expanded(child: _PitcherStatsCard(value: v2, label: l2)),
        const SizedBox(width: TsSpacing.sm),
        Expanded(child: _PitcherStatsCard(value: v3, label: l3)),
      ],
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

String _mlbThrowingHandLabel(AppLocalizations l10n, Object? hand) {
  switch (hand?.toString().trim().toUpperCase()) {
    case 'L':
      return l10n.baseballPitcherLeftHand;
    case 'R':
      return l10n.baseballPitcherRightHand;
    default:
      return l10n.baseballPitcherGeneric;
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

List<String> _englishChipKeys(String singularKey) {
  return switch (singularKey) {
    'strength' => const [
        'strengthsEn',
        'strengths_en',
        'strengthEn',
        'strength_en',
      ],
    'weakness' => const [
        'weaknessesEn',
        'weaknesses_en',
        'weaknessEn',
        'weakness_en',
      ],
    _ => <String>[
        '${singularKey}sEn',
        '${singularKey}s_en',
        '${singularKey}En',
        '${singularKey}_en',
      ],
  };
}

List<String> _localizedChipList(
  Map<String, dynamic> stats, {
  required String singularKey,
  required bool preferEnglish,
}) {
  final localized = _mlbStringList(
    stats['${singularKey}s'] ??
        stats[singularKey] ??
        stats['${singularKey}es'],
  );

  List<String> english = const [];
  for (final key in _englishChipKeys(singularKey)) {
    english = _mlbStringList(stats[key]);
    if (english.isNotEmpty) break;
  }

  if (preferEnglish) {
    if (english.isNotEmpty) return english;
    return localized;
  }
  if (localized.isNotEmpty) return localized;
  return english;
}

List<String> _mergePitcherChipList({
  required List<String> fromStats,
  required List<String> fromBase,
}) {
  if (fromStats.isNotEmpty) return fromStats;
  return fromBase;
}

Map<String, dynamic> _normalizePitcherStatsMap(Map<String, dynamic>? stats) {
  if (stats == null || stats.isEmpty) return const {};

  var merged = Map<String, dynamic>.from(stats);
  for (final key in const ['data', 'current', 'seasonStats', 'stats']) {
    final nested = stats[key];
    if (nested is Map) {
      merged = {
        ...Map<String, dynamic>.from(nested),
        ...merged,
      };
    }
  }
  return merged;
}

List<String> _mlbPitcherChips(
  Map<String, dynamic> stats, {
  required String singularKey,
  required bool preferEnglish,
}) {
  final normalized = _normalizePitcherStatsMap(stats);
  final chips = _localizedChipList(
    normalized,
    singularKey: singularKey,
    preferEnglish: preferEnglish,
  );
  if (chips.isNotEmpty) return chips;

  // Preserve pre-i18n direct reads for flat pitcher-stats payloads.
  return _localizedChipList(
    stats,
    singularKey: singularKey,
    preferEnglish: preferEnglish,
  );
}

Object? _readPitcherStatValue(Map<String, dynamic> stats, String key) {
  final variants = switch (key) {
    'era' => const ['era', 'ERA'],
    'whip' => const ['whip', 'WHIP'],
    'wins' => const ['wins', 'W'],
    'losses' => const ['losses', 'L'],
    'strikeouts' => const ['strikeouts', 'strikeOuts', 'k', 'K'],
    'strikeoutsPer9Inn' => const [
        'strikeoutsPer9Inn',
        'k9',
        'K9',
        'strikeouts_per_9_inn',
      ],
    'inningsPitched' => const ['inningsPitched', 'ip', 'IP', 'innings_pitched'],
    'strikeOuts' => const ['strikeOuts', 'strikeouts', 'k', 'K'],
    _ => <String>[key],
  };
  for (final variant in variants) {
    if (stats.containsKey(variant)) return stats[variant];
  }
  return null;
}

PitcherData _mergeKboPitcherStats(
  PitcherData base,
  Map<String, dynamic>? stats, {
  bool preferEnglishChips = false,
}) {
  if (stats == null || stats.isEmpty) return base;

  final normalized = _normalizePitcherStatsMap(stats);
  final strengths = _mlbPitcherChips(
    stats,
    singularKey: 'strength',
    preferEnglish: preferEnglishChips,
  );
  final weaknesses = _mlbPitcherChips(
    stats,
    singularKey: 'weakness',
    preferEnglish: preferEnglishChips,
  );
  final name = (normalized['name'] as String?)?.trim();
  final summary = (preferEnglishChips
          ? (normalized['summaryEn'] ?? normalized['summary_en']) as String?
          : null)
      ?.trim() ??
      (normalized['summary'] as String?)?.trim();
  final wins = (_readPitcherStatValue(normalized, 'wins') as num?)?.toInt();
  final losses = (_readPitcherStatValue(normalized, 'losses') as num?)?.toInt();
  final eraRaw = _readPitcherStatValue(normalized, 'era');
  final whipRaw = _readPitcherStatValue(normalized, 'whip');
  final k9Raw = _readPitcherStatValue(normalized, 'strikeoutsPer9Inn') ??
      _readPitcherStatValue(normalized, 'k9');
  final ipRaw = _readPitcherStatValue(normalized, 'inningsPitched');
  final kRaw = _readPitcherStatValue(normalized, 'strikeouts');

  final mergedEra = eraRaw != null ? _formatMlbStat(eraRaw, decimals: 2) : base.era;
  final mergedWhip =
      whipRaw != null ? _formatMlbStat(whipRaw, decimals: 2) : base.whip;
  final mergedK9 = k9Raw != null ? _formatMlbStat(k9Raw, decimals: 1) : base.k9;
  final mergedWl = wins != null || losses != null
      ? '${wins ?? 0}-${losses ?? 0}'
      : base.wl;
  final mergedIp = ipRaw != null ? _formatMlbIp(ipRaw) : base.ip;
  final mergedK = kRaw != null ? _formatMlbK(kRaw) : base.k;

  return PitcherData(
    name: preferEnglishChips
        ? base.name
        : (name != null && name.isNotEmpty ? name : base.name),
    nameKo: base.nameKo,
    pitcherType: base.pitcherType,
    teamLogoUrl: base.teamLogoUrl,
    pitcherId: base.pitcherId,
    photoUrl: base.photoUrl,
    era: mergedEra,
    whip: mergedWhip,
    k9: mergedK9,
    wl: mergedWl,
    ip: mergedIp,
    k: mergedK,
    prevWl: base.prevWl,
    prevIp: base.prevIp,
    prevK: base.prevK,
    strengths: _mergePitcherChipList(
      fromStats: strengths,
      fromBase: base.strengths,
    ),
    weaknesses: _mergePitcherChipList(
      fromStats: weaknesses,
      fromBase: base.weaknesses,
    ),
    summary: summary?.isNotEmpty == true ? summary : base.summary,
    season: base.season,
    prevSeason: base.prevSeason,
  );
}

PitcherData _mergeMlbPitcherStats(
  AppLocalizations l10n,
  PitcherData base,
  Map<String, dynamic>? stats, {
  bool preferEnglishChips = false,
}) {
  if (stats == null || stats.isEmpty) return base;

  final normalized = _normalizePitcherStatsMap(stats);
  final strengths = _mlbPitcherChips(
    stats,
    singularKey: 'strength',
    preferEnglish: preferEnglishChips,
  );
  final weaknesses = _mlbPitcherChips(
    stats,
    singularKey: 'weakness',
    preferEnglish: preferEnglishChips,
  );
  final name = (normalized['fullName'] as String?)?.trim();
  final summary = (preferEnglishChips
          ? (normalized['summaryEn'] ?? normalized['summary_en']) as String?
          : null)
      ?.trim() ??
      (normalized['summary'] as String?)?.trim();
  final photo = (normalized['photo'] as String?)?.trim();
  final playerId = (normalized['playerId'] as num?)?.toInt();
  final resolvedPhoto = photo != null && photo.isNotEmpty
      ? optimizeMlbPhotoUrl(photo)
      : base.photoUrl;

  final mergedEra =
      _formatMlbStat(_readPitcherStatValue(normalized, 'era'), decimals: 2);
  final mergedWhip =
      _formatMlbStat(_readPitcherStatValue(normalized, 'whip'), decimals: 2);
  final mergedK9 = _formatMlbStat(
    _readPitcherStatValue(normalized, 'strikeoutsPer9Inn'),
    decimals: 1,
  );
  final mergedWl =
      '${(_readPitcherStatValue(normalized, 'wins') as num?)?.toInt() ?? 0}-${(_readPitcherStatValue(normalized, 'losses') as num?)?.toInt() ?? 0}';
  final mergedIp =
      _formatMlbIp(_readPitcherStatValue(normalized, 'inningsPitched'));
  final mergedK = _formatMlbK(
    _readPitcherStatValue(normalized, 'strikeOuts') ??
        _readPitcherStatValue(normalized, 'strikeouts'),
  );

  return PitcherData(
    name: preferEnglishChips
        ? base.name
        : (name != null && name.isNotEmpty ? name : base.name),
    nameKo: base.nameKo,
    pitcherType: _mlbThrowingHandLabel(l10n, normalized['throwingHand']),
    teamLogoUrl: base.teamLogoUrl,
    pitcherId: playerId ?? base.pitcherId,
    photoUrl: resolvedPhoto,
    era: mergedEra,
    whip: mergedWhip,
    k9: mergedK9,
    wl: mergedWl,
    ip: mergedIp,
    k: mergedK,
    prevWl: base.prevWl,
    prevIp: base.prevIp,
    prevK: base.prevK,
    strengths: _mergePitcherChipList(
      fromStats: strengths,
      fromBase: base.strengths,
    ),
    weaknesses: _mergePitcherChipList(
      fromStats: weaknesses,
      fromBase: base.weaknesses,
    ),
    summary: summary?.isNotEmpty == true ? summary : base.summary,
    season: base.season,
    prevSeason: base.prevSeason,
  );
}

String? _readSeasonField(Object? raw) {
  final text = raw?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

PitcherData _withSeasonLabels(
  PitcherData base, {
  String? season,
  String? prevSeason,
}) {
  return PitcherData(
    name: base.name,
    nameKo: base.nameKo,
    pitcherType: base.pitcherType,
    teamLogoUrl: base.teamLogoUrl,
    pitcherId: base.pitcherId,
    photoUrl: base.photoUrl,
    era: base.era,
    whip: base.whip,
    k9: base.k9,
    wl: base.wl,
    ip: base.ip,
    k: base.k,
    prevWl: base.prevWl,
    prevIp: base.prevIp,
    prevK: base.prevK,
    strengths: base.strengths,
    weaknesses: base.weaknesses,
    summary: base.summary,
    season: season ?? base.season,
    prevSeason: prevSeason ?? base.prevSeason,
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
