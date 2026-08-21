import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_badge.dart';

class TsAiReportLeg {
  const TsAiReportLeg({required this.label, required this.body});

  final String label;
  final String body;
}

class TsAiReportBlock extends StatelessWidget {
  const TsAiReportBlock({
    required this.titleLabel,
    required this.summaryLabel,
    required this.legs,
    required this.caution,
    required this.cautionLabel,
    required this.disclaimerLabel,
    super.key,
  });

  final String titleLabel;
  final String summaryLabel;
  final List<TsAiReportLeg> legs;
  final String caution;
  final String cautionLabel;
  final String disclaimerLabel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TsIcon(TsIcons.analytics, size: TsIconSize.sm, color: c.textPrimary),
            const SizedBox(width: TsSpacing.sm),
            Expanded(
              child: Text(
                titleLabel,
                style: TsType.h3.copyWith(color: c.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TsSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: TsRadius.sm,
          ),
          child: Text(
            summaryLabel,
            style: TsType.bodyMRegular.copyWith(color: c.textSecondary),
          ),
        ),
        const SizedBox(height: TsSpacing.md),
        Column(
          children: [
            for (var i = 0; i < legs.length; i++) ...[
              if (i > 0) const SizedBox(height: TsSpacing.sm),
              _sectionRow(
                c: c,
                badgeLabel: legs[i].label,
                body: legs[i].body,
                tone: TsBadgeTone.primary,
              ),
            ],
            if (legs.isNotEmpty) const SizedBox(height: TsSpacing.sm),
            _sectionRow(
              c: c,
              badgeLabel: cautionLabel,
              body: caution,
              tone: TsBadgeTone.negative,
            ),
          ],
        ),
        const SizedBox(height: TsSpacing.md),
        Text(
          disclaimerLabel,
          style: TsType.labelXsRegular.copyWith(color: c.textDisabled),
        ),
      ],
    );
  }
}

Widget _sectionRow({
  required TsThemeColors c,
  required String badgeLabel,
  required String body,
  required TsBadgeTone tone,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TsBadge(label: badgeLabel, tone: tone),
      const SizedBox(width: TsSpacing.sm),
      Expanded(
        child: Text(
          body,
          style: TsType.bodyMRegular.copyWith(color: c.textSecondary),
        ),
      ),
    ],
  );
}
