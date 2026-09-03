import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_stat_compare_row.dart';

class TsPitcherProfile {
  const TsPitcherProfile({
    required this.positionLabel,
    required this.nameLabel,
    required this.handLabel,
    this.photoUrl,
    this.strengths = const [],
    this.weaknesses = const [],
  });

  final String positionLabel;
  final String nameLabel;
  final String handLabel;
  final String? photoUrl;
  final List<String> strengths;
  final List<String> weaknesses;
}

class TsStatComparison {
  const TsStatComparison({
    required this.statLabel,
    required this.homeValueLabel,
    required this.awayValueLabel,
    required this.homeFraction,
  });

  final String statLabel;
  final String homeValueLabel;
  final String awayValueLabel;
  final double homeFraction;
}

class TsStartingPitchersSection extends StatefulWidget {
  const TsStartingPitchersSection({
    required this.home,
    required this.away,
    required this.versusLabel,
    required this.stats,
    this.secondaryStats = const [],
    this.prevSeasonStats = const [],
    this.prevSeasonTitleLabel,
    this.showSecondaryStats = false,
    this.showComments = true,
    super.key,
  });

  final TsPitcherProfile home;
  final TsPitcherProfile away;
  final String versusLabel;
  final List<TsStatComparison> stats;
  final List<TsStatComparison> secondaryStats;
  final List<TsStatComparison> prevSeasonStats;
  final String? prevSeasonTitleLabel;
  final bool showSecondaryStats;
  final bool showComments;

  @override
  State<TsStartingPitchersSection> createState() =>
      _TsStartingPitchersSectionState();
}

class _TsStartingPitchersSectionState extends State<TsStartingPitchersSection> {
  bool _prevSeasonExpanded = false;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final showCommentSection = widget.showComments &&
        (_hasComments(widget.home) || _hasComments(widget.away));
    final showSecondaryStatRows =
        widget.showSecondaryStats && widget.secondaryStats.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, minHeight: 280),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _profileColumn(c, widget.home)),
              const SizedBox(width: TsSpacing.sm),
              Text(
                widget.versusLabel,
                style: TsType.labelSBold.copyWith(color: c.textTertiary),
              ),
              const SizedBox(width: TsSpacing.sm),
              Expanded(child: _profileColumn(c, widget.away)),
            ],
          ),
          const SizedBox(height: TsSpacing.lg),
          Column(
            children: [
              for (var i = 0; i < widget.stats.length; i++) ...[
                if (i > 0) const SizedBox(height: TsSpacing.xs),
                _statRow(widget.stats[i]),
              ],
            ],
          ),
          if (showSecondaryStatRows) ...[
            const SizedBox(height: TsSpacing.sm),
            Column(
              children: [
                for (var i = 0; i < widget.secondaryStats.length; i++) ...[
                  if (i > 0) const SizedBox(height: TsSpacing.xs),
                  _statRow(widget.secondaryStats[i]),
                ],
              ],
            ),
          ],
          if (showCommentSection) ...[
            const SizedBox(height: TsSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _chipColumn(c, widget.home)),
                const SizedBox(width: TsSpacing.md),
                Expanded(child: _chipColumn(c, widget.away)),
              ],
            ),
          ],
          if (widget.prevSeasonStats.isNotEmpty) ...[
            const SizedBox(height: TsSpacing.lg),
            _prevSeasonPanel(c),
          ],
        ],
      ),
    );
  }

  bool _hasComments(TsPitcherProfile profile) =>
      profile.strengths.isNotEmpty || profile.weaknesses.isNotEmpty;

  Widget _profileColumn(TsThemeColors c, TsPitcherProfile profile) {
    return Column(
      children: [
        TsBadge(label: profile.positionLabel, tone: TsBadgeTone.neutral),
        const SizedBox(height: TsSpacing.xs),
        _photo(c, profile.photoUrl),
        const SizedBox(height: TsSpacing.xs),
        Text(
          profile.nameLabel,
          style: TsType.bodyLBold.copyWith(color: c.textPrimary),
          textAlign: TextAlign.center,
        ),
        Text(
          profile.handLabel,
          style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _photo(TsThemeColors c, String? photoUrl) {
    const photoSize = 56.0;
    final placeholder = TsIcon(
      TsIcons.accountCircle,
      size: TsIconSize.lg,
      color: c.textTertiary,
    );

    return ClipOval(
      child: ColoredBox(
        color: c.surfaceRaised,
        child: SizedBox(
          width: photoSize,
          height: photoSize,
          child: photoUrl == null || photoUrl.isEmpty
              ? Center(child: placeholder)
              : CachedNetworkImage(
                  imageUrl: photoUrl,
                  fit: BoxFit.cover,
                  width: photoSize,
                  height: photoSize,
                  placeholder: (_, _) => Center(child: placeholder),
                  errorWidget: (_, _, _) => Center(child: placeholder),
                ),
        ),
      ),
    );
  }

  Widget _chipColumn(TsThemeColors c, TsPitcherProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final label in profile.strengths) ...[
          _fullWidthBadge(label, TsBadgeTone.positive),
          const SizedBox(height: TsSpacing.xs),
        ],
        for (final label in profile.weaknesses)
          _fullWidthBadge(label, TsBadgeTone.negative),
      ],
    );
  }

  Widget _fullWidthBadge(String label, TsBadgeTone tone) {
    return TsBadge(
      label: label,
      tone: tone,
      expand: true,
      textAlign: TextAlign.center,
    );
  }

  Widget _statRow(TsStatComparison stat) {
    return TsStatCompareRow(
      statLabel: stat.statLabel,
      homeLabel: stat.homeValueLabel,
      awayLabel: stat.awayValueLabel,
      homeFraction: stat.homeFraction,
      awayFraction: 1 - stat.homeFraction,
    );
  }

  Widget _prevSeasonPanel(TsThemeColors c) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: TsRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: TsSpacing.sm,
          horizontal: TsSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => setState(() => _prevSeasonExpanded = !_prevSeasonExpanded),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.prevSeasonTitleLabel ?? '',
                      style: TsType.labelSBold.copyWith(color: c.textSecondary),
                    ),
                  ),
                  TsIcon(
                    _prevSeasonExpanded
                        ? TsIcons.keyboardArrowUp
                        : TsIcons.keyboardArrowDown,
                    size: TsIconSize.xs,
                    color: c.textPrimary,
                  ),
                ],
              ),
            ),
            if (_prevSeasonExpanded) ...[
              const SizedBox(height: TsSpacing.sm),
              Column(
                children: [
                  for (var i = 0; i < widget.prevSeasonStats.length; i++) ...[
                    if (i > 0) const SizedBox(height: TsSpacing.xs),
                    _statRow(widget.prevSeasonStats[i]),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
