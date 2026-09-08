import 'package:flutter/material.dart';

import 'package:trendsoccer/features_v2/feed/feed_header_shell.dart';
import 'package:trendsoccer/features_v2/feed/feed_league_chips.dart';
import 'package:trendsoccer/features_v2/feed/feed_league_filter_row.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_body.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';

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

  void _clearLeagueSelection() {
    if (_leagueFilterScrollController.hasClients) {
      _leagueFilterScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    setState(() => _selectedLeagueId = null);
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final leagues = feedPreviewLeagueFilters(languageCode);

    return FeedHeaderShell(
      segment: FeedSegment.preview,
      filterRow: FeedLeagueFilterRow(
        leagues: leagues,
        selectedLeagueId: _selectedLeagueId,
        scrollController: _leagueFilterScrollController,
        onSelected: (id) => setState(() => _selectedLeagueId = id),
      ),
      child: FeedPreviewBody(
        selectedLeagueId: _selectedLeagueId,
        onClearLeagueSelection: _clearLeagueSelection,
      ),
    );
  }
}
