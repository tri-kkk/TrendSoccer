import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_chip.dart';
import 'package:trendsoccer/design_system/widgets/ts_league_filter_chip.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';

/// Horizontal league filter for reports — "All" plus emblem chips per league.
class ReportsLeagueFilterRow extends StatelessWidget {
  const ReportsLeagueFilterRow({
    required this.leagues,
    required this.selectedLeagueId,
    required this.onSelected,
    this.allLabel = 'All',
    super.key,
  });

  final List<ReportsLeagueFilterOption> leagues;
  final String? selectedLeagueId;
  final ValueChanged<String?> onSelected;
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: leagues.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TsChip(
              label: allLabel,
              selected: selectedLeagueId == null,
              onTap: () => onSelected(null),
            );
          }

          final league = leagues[index - 1];
          return TsLeagueFilterChip(
            leagueId: league.emblemId,
            label: league.label,
            selected: selectedLeagueId == league.id,
            onTap: () => onSelected(league.id),
          );
        },
      ),
    );
  }
}
