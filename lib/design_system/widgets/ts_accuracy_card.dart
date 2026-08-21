import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';
import 'package:trendsoccer/design_system/widgets/ts_gauge_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_recent_pick_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';

enum TsAccuracyPeriod { d7, d30 }

enum TsRecentPickResult { match, mismatch }

class TsRecentPick {
  const TsRecentPick({
    required this.result,
    required this.homeTeamLabel,
    required this.awayTeamLabel,
    required this.homeScoreLabel,
    required this.awayScoreLabel,
    required this.pickedTeamLabel,
    required this.leagueLabel,
    required this.leagueIcon,
    required this.dateLabel,
  });

  final TsRecentPickResult result;
  final String homeTeamLabel;
  final String awayTeamLabel;
  final String homeScoreLabel;
  final String awayScoreLabel;
  final String pickedTeamLabel;
  final String leagueLabel;
  final Widget leagueIcon;
  final String dateLabel;
}

class TsAccuracyCard extends StatefulWidget {
  const TsAccuracyCard({
    required this.titleLabel,
    required this.period7Label,
    required this.period30Label,
    this.initialPeriod = TsAccuracyPeriod.d30,
    this.onPeriodChanged,
    required this.sport,
    this.onSportChanged,
    required this.valueLabel,
    required this.winLossLabel,
    required this.accuracyFraction,
    required this.baselineFraction,
    required this.sampleLabel,
    required this.baselineNoteLabel,
    required this.streakLabel,
    required this.nextUpdateLabel,
    this.recentPicks = const [],
    this.recentLabel,
    this.seeAllLabel,
    this.onSeeAllPressed,
    super.key,
  });

  final String titleLabel;
  final String period7Label;
  final String period30Label;
  final TsAccuracyPeriod initialPeriod;
  final ValueChanged<TsAccuracyPeriod>? onPeriodChanged;
  final TsSport sport;
  final ValueChanged<TsSport>? onSportChanged;
  final String valueLabel;
  final String winLossLabel;
  final double accuracyFraction;
  final double baselineFraction;
  final String sampleLabel;
  final String baselineNoteLabel;
  final String streakLabel;
  final String nextUpdateLabel;
  final List<TsRecentPick> recentPicks;
  final String? recentLabel;
  final String? seeAllLabel;
  final VoidCallback? onSeeAllPressed;

  @override
  State<TsAccuracyCard> createState() => _TsAccuracyCardState();
}

class _TsAccuracyCardState extends State<TsAccuracyCard> {
  late TsAccuracyPeriod _period;

  @override
  void initState() {
    super.initState();
    _period = widget.initialPeriod;
  }

  void _selectPeriod(TsAccuracyPeriod period) {
    if (_period == period) return;
    setState(() => _period = period);
    widget.onPeriodChanged?.call(period);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final showRecent = widget.recentPicks.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: TsRadius.md,
        ),
        child: Padding(
          padding: const EdgeInsets.all(TsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.titleLabel,
                      style: TsType.h3.copyWith(color: c.textPrimary),
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  _buildPeriodToggle(c),
                ],
              ),
              if (widget.onSportChanged != null) ...[
                const SizedBox(height: TsSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 240),
                  child: TsSportToggle(
                    active: widget.sport,
                    onChanged: widget.onSportChanged!,
                  ),
                ),
              ],
              const SizedBox(height: TsSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.valueLabel,
                    style: TsType.display.copyWith(color: c.primary),
                  ),
                  const SizedBox(width: TsSpacing.md),
                  Expanded(
                    child: Text(
                      widget.winLossLabel,
                      style: TsType.bodyLBold.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 10,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor:
                                  widget.accuracyFraction.clamp(0.0, 1.0),
                              alignment: Alignment.centerLeft,
                              child: const TsGaugeBar(
                                line: TsGaugeLine.oneWay,
                                home: 1,
                                showValues: false,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment(
                                widget.baselineFraction.clamp(0.0, 1.0) * 2 -
                                    1,
                                0,
                              ),
                              child: Container(
                                width: TsSpacing.xxs,
                                height: 10,
                                color: c.canvas,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: TsSpacing.md),
                  Text(
                    widget.sampleLabel,
                    style: TsType.labelSMedium.copyWith(color: c.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: TsSpacing.md),
              Text(
                widget.baselineNoteLabel,
                style: TsType.labelXsMedium.copyWith(color: c.textTertiary),
              ),
              const SizedBox(height: TsSpacing.md),
              Container(height: 1, color: c.borderSubtle),
              const SizedBox(height: TsSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.streakLabel,
                    style: TsType.bodyMBold.copyWith(color: c.textPrimary),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Text(
                    '·',
                    style: TsType.bodyMMedium.copyWith(color: c.textTertiary),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.nextUpdateLabel,
                      style: TsType.labelSMedium.copyWith(color: c.textTertiary),
                    ),
                  ),
                ],
              ),
              if (showRecent) ...[
                const SizedBox(height: TsSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.recentLabel ?? '',
                        style: TsType.labelSMedium.copyWith(
                          color: c.textTertiary,
                        ),
                      ),
                    ),
                    if (widget.seeAllLabel != null)
                      GestureDetector(
                        onTap: widget.onSeeAllPressed,
                        child: Text(
                          widget.seeAllLabel!,
                          style: TsType.labelSBold.copyWith(color: c.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: TsSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < widget.recentPicks.length; i++) ...[
                        if (i > 0) const SizedBox(width: TsSpacing.sm),
                        _RecentPickCard(pick: widget.recentPicks[i]),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodToggle(TsThemeColors c) {
    return Container(
      padding: const EdgeInsets.all(TsSpacing.xs),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: TsRadius.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodSegment(
            c,
            widget.period7Label,
            _period == TsAccuracyPeriod.d7,
            () => _selectPeriod(TsAccuracyPeriod.d7),
          ),
          const SizedBox(width: TsSpacing.xs),
          _buildPeriodSegment(
            c,
            widget.period30Label,
            _period == TsAccuracyPeriod.d30,
            () => _selectPeriod(TsAccuracyPeriod.d30),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSegment(
    TsThemeColors c,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? c.primary : Colors.transparent,
          borderRadius: TsRadius.full,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: TsSpacing.xs,
            horizontal: TsSpacing.sm,
          ),
          child: Text(
            label,
            style: (selected ? TsType.labelSBold : TsType.labelSMedium).copyWith(
              color: selected ? c.onPrimary : c.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentPickCard extends StatelessWidget {
  const _RecentPickCard({required this.pick});

  final TsRecentPick pick;

  @override
  Widget build(BuildContext context) {
    final (resultLabel, resultTone) = switch (pick.result) {
      TsRecentPickResult.match => ('Match', TsBadgeTone.positive),
      TsRecentPickResult.mismatch => ('Mismatch', TsBadgeTone.negative),
    };

    return TsRecentPickCard(
      leagueId: '',
      leagueIcon: pick.leagueIcon,
      leagueLabel: pick.leagueLabel,
      dateLabel: pick.dateLabel,
      homeTeam: pick.homeTeamLabel,
      awayTeam: pick.awayTeamLabel,
      homeScore: pick.homeScoreLabel,
      awayScore: pick.awayScoreLabel,
      pickedTeam: pick.pickedTeamLabel,
      resultLabel: resultLabel,
      resultTone: resultTone,
    );
  }
}
