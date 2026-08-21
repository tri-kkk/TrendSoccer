import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_h2h_match_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_stack_bar.dart';

class TsH2HMeeting {
  const TsH2HMeeting({
    required this.dateLabel,
    required this.homeTeamLabel,
    required this.awayTeamLabel,
    required this.scoreLabel,
  });

  final String dateLabel;
  final String homeTeamLabel;
  final String awayTeamLabel;
  final String scoreLabel;
}

class TsH2HSummary extends StatefulWidget {
  const TsH2HSummary({
    required this.line,
    required this.homeValueLabel,
    required this.awayValueLabel,
    required this.homeFraction,
    required this.awayFraction,
    required this.homeLabel,
    required this.awayLabel,
    required this.detailTitleLabel,
    this.drawValueLabel,
    this.drawLabel,
    this.drawFraction = 0,
    this.meetings = const [],
    super.key,
  });

  final TsStackLine line;
  final String homeValueLabel;
  final String awayValueLabel;
  final double homeFraction;
  final double awayFraction;
  final String? drawValueLabel;
  final String homeLabel;
  final String awayLabel;
  final String? drawLabel;
  final double drawFraction;
  final String detailTitleLabel;
  final List<TsH2HMeeting> meetings;

  @override
  State<TsH2HSummary> createState() => _TsH2HSummaryState();
}

class _TsH2HSummaryState extends State<TsH2HSummary> {
  bool _detailExpanded = false;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, minHeight: 103),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsStackBar(
            line: widget.line,
            home: widget.homeFraction,
            draw: widget.drawFraction,
            away: widget.awayFraction,
            homeValue: widget.homeValueLabel,
            drawValue: widget.drawValueLabel,
            awayValue: widget.awayValueLabel,
            homeLabel: widget.homeLabel,
            drawLabel: widget.drawLabel,
            awayLabel: widget.awayLabel,
          ),
          if (widget.meetings.isNotEmpty) ...[
            const SizedBox(height: TsSpacing.lg),
            _detailPanel(c),
          ],
        ],
      ),
    );
  }

  Widget _detailPanel(TsThemeColors c) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: TsRadius.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(TsSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => setState(() => _detailExpanded = !_detailExpanded),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.detailTitleLabel,
                      style: TsType.labelSBold.copyWith(color: c.textSecondary),
                    ),
                  ),
                  TsIcon(
                    _detailExpanded
                        ? TsIcons.keyboardArrowUp
                        : TsIcons.keyboardArrowDown,
                    size: TsIconSize.xs,
                    color: c.textPrimary,
                  ),
                ],
              ),
            ),
            if (_detailExpanded) ...[
              const SizedBox(height: TsSpacing.sm),
              Column(
                children: [
                  for (var i = 0; i < widget.meetings.length; i++) ...[
                    if (i > 0) const SizedBox(height: TsSpacing.sm),
                    TsH2HMatchRow(
                      dateLabel: widget.meetings[i].dateLabel,
                      homeTeam: widget.meetings[i].homeTeamLabel,
                      awayTeam: widget.meetings[i].awayTeamLabel,
                      scoreLabel: widget.meetings[i].scoreLabel,
                    ),
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
