import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_chip.dart';
import 'package:trendsoccer/design_system/widgets/ts_league_filter_chip.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

/// Horizontal league filter for feed preview — "All" plus emblem chips per league.
class FeedLeagueFilterRow extends StatelessWidget {
  const FeedLeagueFilterRow({
    required this.leagues,
    required this.selectedLeagueId,
    required this.onSelected,
    required this.scrollController,
    super.key,
  });

  final List<FeedLeagueFilterOption> leagues;
  final String? selectedLeagueId;
  final ValueChanged<String?> onSelected;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final allLabel = AppLocalizations.of(context)!.feedNewsSportAll;
    return SizedBox(
      height: 32,
      child: ListView.separated(
        controller: scrollController,
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
