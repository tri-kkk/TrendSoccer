import 'package:flutter/material.dart';

import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_logo.dart';

class FixtureLeagueFilters extends StatelessWidget {
  const FixtureLeagueFilters({
    required this.leagues,
    required this.selectedLeague,
    required this.filterAllLabel,
    required this.locale,
    required this.onSelectAll,
    required this.onSelectLeague,
    super.key,
  });

  final List<FixtureLeagueOption> leagues;
  final String? selectedLeague;
  final String filterAllLabel;
  final String locale;
  final VoidCallback onSelectAll;
  final ValueChanged<String> onSelectLeague;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: leagues.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TsFilterChip(
              label: filterAllLabel,
              isSelected: selectedLeague == null,
              type: TsFilterChipType.textOnly,
              onTap: onSelectAll,
            );
          }

          final league = leagues[index - 1];
          final displayName = locale == 'en'
              ? (league.nameEn ?? league.name)
              : league.name;

          return TsFilterChip(
            label: displayName,
            isSelected: selectedLeague == league.code,
            type: TsFilterChipType.withIcon,
            iconWidget: FixtureLeagueLogo(
              leagueName: displayName,
              leagueCode: league.code,
              leagueLogoUrl: league.logo,
              size: 16,
            ),
            onTap: () => onSelectLeague(league.code),
          );
        },
      ),
    );
  }
}
