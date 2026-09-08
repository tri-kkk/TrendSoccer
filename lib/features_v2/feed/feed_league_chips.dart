import 'package:trendsoccer/core/models/league_filter_chips.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';

/// Soccer analysis league chips for feed preview — same list as Reports > Soccer > Analysis.
List<FeedLeagueFilterOption> feedPreviewLeagueFilters(String languageCode) {
  return soccerAnalysisLeagueChips
      .where((chip) => !chip.isAll)
      .map(
        (chip) => (
          id: chip.id,
          label: chip.displayLabel(languageCode),
          emblemId: chip.iconId ?? chip.id,
        ),
      )
      .toList();
}
