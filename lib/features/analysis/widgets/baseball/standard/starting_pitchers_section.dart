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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
        Expanded(
          child: InfoCell(value: v1, label: l1, valueStyle: TsType.bodyLBold),
        ),
        const SizedBox(width: TsSpacing.sm),
        Expanded(
          child: InfoCell(value: v2, label: l2, valueStyle: TsType.bodyLBold),
        ),
        const SizedBox(width: TsSpacing.sm),
        Expanded(
          child: InfoCell(value: v3, label: l3, valueStyle: TsType.bodyLBold),
        ),
      ],
    );
  }

  Widget _photo(BuildContext context, TsSemanticColors semantic) {
    Widget placeholder() {
      return Container(
        width: 48,
        height: 48,
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
        width: 48,
        height: 48,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, _) => placeholder(),
          errorWidget: (context, url, error) => placeholder(),
        ),
      ),
    );
  }

  bool get _hasExtendedStats =>
      pitcher.k9 != '-' ||
      pitcher.wl != '-' ||
      pitcher.ip != '-' ||
      pitcher.prevWl != '-' ||
      pitcher.prevIp != '-' ||
      pitcher.prevK != '-' ||
      pitcher.strengths.isNotEmpty ||
      pitcher.weaknesses.isNotEmpty;

  List<Widget> _commentChipChildren() {
    final out = <Widget>[];
    for (var i = 0; i < pitcher.strengths.length; i++) {
      out.add(PitcherCommentChip(text: pitcher.strengths[i], isStrength: true));
      final hasMoreStrengths = i < pitcher.strengths.length - 1;
      final hasWeaknesses = pitcher.weaknesses.isNotEmpty;
      if (hasMoreStrengths || hasWeaknesses) {
        out.add(const SizedBox(height: TsSpacing.sm));
      }
    }
    for (var j = 0; j < pitcher.weaknesses.length; j++) {
      out.add(PitcherCommentChip(text: pitcher.weaknesses[j], isStrength: false));
      if (j < pitcher.weaknesses.length - 1) {
        out.add(const SizedBox(height: TsSpacing.sm));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PositionChip(isHome: isHome),
          const SizedBox(height: 12),
          _photo(context, semantic),
          const SizedBox(height: 12),
          Text(
            pitcher.name,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: semantic.borderSubtle),
          const SizedBox(height: 12),
          _statsRowTriple(
            v1: pitcher.era,
            l1: 'ERA',
            v2: pitcher.whip,
            l2: 'WHIP',
            v3: pitcher.k,
            l3: 'K',
          ),
          if (_hasExtendedStats) ...[
            const SizedBox(height: 8),
            _statsRowTriple(
              v1: pitcher.wl,
              l1: 'W-L',
              v2: pitcher.ip,
              l2: 'IP',
              v3: pitcher.k9,
              l3: 'K/9',
            ),
            const SizedBox(height: 12),
            ..._commentChipChildren(),
            const SizedBox(height: 12),
            const Spacer(),
            Container(height: 1, color: semantic.borderSubtle),
            const SizedBox(height: 12),
            const SeasonChip(isCurrent: false),
            const SizedBox(height: 12),
            _statsRowTriple(
              v1: pitcher.prevWl,
              l1: 'W-L',
              v2: pitcher.prevIp,
              l2: 'IP',
              v3: pitcher.prevK,
              l3: 'K',
            ),
          ],
        ],
      ),
    );
  }
}
