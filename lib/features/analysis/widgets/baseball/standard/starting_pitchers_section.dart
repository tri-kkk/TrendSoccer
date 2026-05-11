import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/baseball/pitcher_comment_chip.dart';
import 'package:trendsoccer/shared/widgets/baseball/position_chip.dart';
import 'package:trendsoccer/shared/widgets/baseball/season_chip.dart';
import 'package:trendsoccer/shared/widgets/report/info_cell.dart';

class PitcherData {
  const PitcherData({
    required this.name,
    required this.pitcherType,
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
  });

  final String name;
  final String pitcherType;
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
}

class StartingPitchersSection extends StatelessWidget {
  const StartingPitchersSection({
    required this.awayPitcher,
    required this.homePitcher,
    super.key,
  });

  final PitcherData awayPitcher;
  final PitcherData homePitcher;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PitcherColumn(pitcher: awayPitcher, isHome: false),
              ),
              Expanded(
                child: _PitcherColumn(pitcher: homePitcher, isHome: true),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PitcherColumn extends StatelessWidget {
  const _PitcherColumn({
    required this.pitcher,
    required this.isHome,
  });

  final PitcherData pitcher;
  final bool isHome;

  Widget _photo(BuildContext context, TsSemanticColors semantic) {
    Widget placeholder() {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: semantic.surfaceContainer,
          shape: BoxShape.circle,
        ),
      );
    }

    final url = pitcher.photoUrl;
    if (url == null || url.isEmpty) {
      return placeholder();
    }
    return ClipOval(
      child: SizedBox(
        width: 80,
        height: 80,
          child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => placeholder(),
          errorWidget: (context, url, error) => placeholder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PositionChip(isHome: isHome),
          const SizedBox(height: TsSpacing.md),
          _photo(context, semantic),
          const SizedBox(height: TsSpacing.md),
          Text(
            pitcher.name,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.md),
          Text(
            pitcher.pitcherType,
            style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TsSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SeasonChip(isCurrent: true),
              const SizedBox(width: TsSpacing.xs),
              const SeasonChip(isCurrent: false),
            ],
          ),
          const SizedBox(height: TsSpacing.md),
          Divider(height: 1, thickness: 1, color: semantic.borderSubtle),
          const SizedBox(height: TsSpacing.md),
          Row(
            children: [
              Expanded(
                child: InfoCell(value: pitcher.era, label: 'ERA'),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: InfoCell(value: pitcher.whip, label: 'WHIP'),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: InfoCell(value: pitcher.k9, label: 'K/9'),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.sm),
          Row(
            children: [
              Expanded(
                child: InfoCell(value: pitcher.wl, label: 'W-L'),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: InfoCell(value: pitcher.ip, label: 'IP'),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: InfoCell(value: pitcher.k, label: 'K'),
              ),
            ],
          ),
          const SizedBox(height: TsSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < pitcher.strengths.length; i++) ...[
                PitcherCommentChip(text: pitcher.strengths[i], isStrength: true),
                if (i < pitcher.strengths.length - 1 || pitcher.weaknesses.isNotEmpty)
                  const SizedBox(height: TsSpacing.sm),
              ],
              for (var j = 0; j < pitcher.weaknesses.length; j++) ...[
                PitcherCommentChip(text: pitcher.weaknesses[j], isStrength: false),
                if (j < pitcher.weaknesses.length - 1)
                  const SizedBox(height: TsSpacing.sm),
              ],
            ],
          ),
          const SizedBox(height: TsSpacing.md),
          Divider(height: 1, thickness: 1, color: semantic.borderSubtle),
          const SizedBox(height: TsSpacing.md),
          const SeasonChip(isCurrent: false),
          const SizedBox(height: TsSpacing.md),
          Row(
            children: [
              Expanded(
                child: InfoCell(value: pitcher.prevWl, label: 'W-L'),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: InfoCell(value: pitcher.prevIp, label: 'IP'),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(
                child: InfoCell(value: pitcher.prevK, label: 'K'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
