import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/icons/ts_league_icon.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';

class TsLeagueFilterChip extends StatelessWidget {
  const TsLeagueFilterChip({
    required this.leagueId,
    required this.label,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String leagueId;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: TsRadius.full,
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? c.primaryMuted : c.surfaceRaised,
            borderRadius: TsRadius.full,
            border: selected ? Border.all(color: c.primary, width: 1) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TsSpacing.md),
            child: SizedBox(
              height: TsSpacing.xxl,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TsLeagueIcon(leagueId, size: TsSpacing.lg),
                  const SizedBox(width: TsSpacing.xs),
                  Text(
                    label,
                    style: (selected ? TsType.bodyMBold : TsType.bodyMMedium)
                        .copyWith(
                      color: selected ? c.primary : c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
