import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsLeagueGroupHeader extends StatelessWidget {
  const TsLeagueGroupHeader({
    required this.leagueId,
    required this.label,
    this.matchCount,
    this.showIcon = true,
    this.collapsed,
    this.onToggleCollapse,
    super.key,
  });

  final String leagueId;
  final String label;
  final String? matchCount;
  final bool showIcon;
  final bool? collapsed;
  final VoidCallback? onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return SizedBox(
      height: TsSpacing.xl,
      child: Row(
        children: [
          if (showIcon) ...[
            TsLeagueIcon(leagueId, size: TsSpacing.xl),
            const SizedBox(width: TsSpacing.sm),
          ],
          Expanded(
            child: Text(
              label,
              style: TsType.bodyLBold.copyWith(color: c.textSecondary),
            ),
          ),
          if (matchCount != null)
            Text(
              matchCount!,
              style: TsType.labelSMedium.copyWith(color: c.textTertiary),
            ),
          if (collapsed != null) ...[
            const SizedBox(width: TsSpacing.sm),
            GestureDetector(
              onTap: onToggleCollapse,
              child: TsIcon(
                collapsed! ? TsIcons.keyboardArrowDown : TsIcons.keyboardArrowUp,
                size: 20,
                color: c.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
