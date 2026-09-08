import 'package:flutter/material.dart';

import 'package:trendsoccer/features_v2/feed/feed_header_shell.dart';
import 'package:trendsoccer/features_v2/feed/feed_league_filter_row.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';

/// Placeholder leagues until preview list data is wired (7-3).
const _previewPlaceholderLeagues = <FeedLeagueFilterOption>[
  (id: 'epl', label: 'EPL', emblemId: 'premier_league'),
  (id: 'laliga', label: 'LaLiga', emblemId: 'laliga'),
  (id: 'bundesliga', label: 'Bundesliga', emblemId: 'bundesliga'),
  (id: 'serie_a', label: 'Serie A', emblemId: 'serie_a'),
];

class FeedPreviewScreen extends StatefulWidget {
  const FeedPreviewScreen({super.key});

  @override
  State<FeedPreviewScreen> createState() => _FeedPreviewScreenState();
}

class _FeedPreviewScreenState extends State<FeedPreviewScreen> {
  String? _selectedLeagueId;
  final ScrollController _leagueFilterScrollController = ScrollController();

  @override
  void dispose() {
    _leagueFilterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeedHeaderShell(
      segment: FeedSegment.preview,
      filterRow: FeedLeagueFilterRow(
        leagues: _previewPlaceholderLeagues,
        selectedLeagueId: _selectedLeagueId,
        scrollController: _leagueFilterScrollController,
        onSelected: (id) => setState(() => _selectedLeagueId = id),
      ),
      child: const SizedBox.shrink(),
    );
  }
}
