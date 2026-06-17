import 'package:flutter/material.dart';

import 'package:trendsoccer/core/providers/fixture_provider.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/shared/widgets/filter/ts_filter_chip.dart';
import 'package:trendsoccer/shared/widgets/fixture/fixture_league_logo.dart';

class FixtureLeagueFilters extends StatelessWidget {
  const FixtureLeagueFilters({
    required this.leagues,
    required this.selectedLeague,
    required this.filterAllLabel,
    required this.liveLabel,
    required this.locale,
    required this.isLiveFilter,
    required this.onSelectAll,
    required this.onLiveTap,
    required this.onSelectLeague,
    super.key,
  });

  final List<FixtureLeagueOption> leagues;
  final String? selectedLeague;
  final String filterAllLabel;
  final String liveLabel;
  final String locale;
  final bool isLiveFilter;
  final VoidCallback onSelectAll;
  final VoidCallback onLiveTap;
  final ValueChanged<String> onSelectLeague;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: leagues.length + 2,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TsFilterChip(
              label: filterAllLabel,
              isSelected: selectedLeague == null && !isLiveFilter,
              type: TsFilterChipType.textOnly,
              onTap: onSelectAll,
            );
          }

          if (index == 1) {
            return TsFilterChip(
              label: liveLabel,
              isSelected: isLiveFilter,
              type: TsFilterChipType.textOnly,
              activeBackgroundColor: TsColors.error500,
              activeTextColor: Colors.white,
              onTap: onLiveTap,
            );
          }

          final league = leagues[index - 2];
          final displayName = locale == 'en'
              ? (league.nameEn ?? league.name)
              : league.name;
          final isSelected = selectedLeague == league.code && !isLiveFilter;

          return TsFilterChip(
            label: displayName,
            isSelected: isSelected,
            type: TsFilterChipType.withIcon,
            iconWidget: FixtureLeagueLogo(
              leagueName: displayName,
              leagueCode: league.code,
              leagueLogoUrl: league.logo,
              size: 16,
              isActive: isSelected,
            ),
            onTap: () => onSelectLeague(league.code),
          );
        },
      ),
    );
  }
}
