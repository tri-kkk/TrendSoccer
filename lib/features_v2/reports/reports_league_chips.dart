import 'package:trendsoccer/core/models/league_filter_chips.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/features_v2/reports/reports_route_map.dart';

/// Static league filter chips for reports, derived from analysis chip constants.
List<ReportsLeagueFilterOption> reportsLeagueFiltersForSport(TsSport sport) {
  switch (sport) {
    case TsSport.soccer:
      return soccerAnalysisLeagueChips
          .where((chip) => !chip.isAll)
          .map(
            (chip) => (
              id: chip.id,
              label: chip.displayLabel,
              emblemId: chip.iconId ?? chip.id,
            ),
          )
          .toList();
    case TsSport.baseball:
      return baseballAnalysisLeagueChips
          .where((chip) => !chip.isAll)
          .map(
            (chip) => (
              id: chip.id,
              label: chip.displayLabel,
              emblemId: chip.iconId ?? chip.id,
            ),
          )
          .toList();
  }
}
