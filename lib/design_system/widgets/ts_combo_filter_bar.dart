import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_chip.dart';
import 'package:trendsoccer/design_system/widgets/ts_league_filter_chip.dart';

class TsComboFilterBar extends StatelessWidget {
  const TsComboFilterBar({
    required this.leagues,
    required this.selectedId,
    required this.onSelect,
    this.allLabel = 'All',
    super.key,
  });

  final List<({String id, String label})> leagues;
  final String? selectedId;
  final ValueChanged<String?> onSelect;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return ColoredBox(
      color: c.canvas,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: TsSpacing.md,
          horizontal: TsSpacing.lg,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              TsChip(
                label: allLabel,
                selected: selectedId == null,
                onTap: () => onSelect(null),
              ),
              for (final league in leagues) ...[
                const SizedBox(width: TsSpacing.xs),
                TsLeagueFilterChip(
                  leagueId: league.id,
                  label: league.label,
                  selected: selectedId == league.id,
                  onTap: () => onSelect(league.id),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
