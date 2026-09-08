import 'package:flutter/material.dart';

import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/widgets/ts_chip.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';

/// Horizontal sport filter for feed news — All / Soccer / Baseball.
class FeedSportFilterRow extends StatelessWidget {
  const FeedSportFilterRow({
    required this.selectedSport,
    required this.onSelected,
    super.key,
  });

  final FeedNewsSportFilter? selectedSport;
  final ValueChanged<FeedNewsSportFilter?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TsSpacing.lg),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: TsSpacing.sm),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return TsChip(
                label: 'All',
                selected: selectedSport == null,
                onTap: () => onSelected(null),
              );
            case 1:
              return TsChip(
                label: 'Soccer',
                selected: selectedSport == FeedNewsSportFilter.soccer,
                onTap: () => onSelected(FeedNewsSportFilter.soccer),
              );
            case 2:
              return TsChip(
                label: 'Baseball',
                selected: selectedSport == FeedNewsSportFilter.baseball,
                onTap: () => onSelected(FeedNewsSportFilter.baseball),
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
