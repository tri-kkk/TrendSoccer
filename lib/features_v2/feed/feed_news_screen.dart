import 'package:flutter/material.dart';

import 'package:trendsoccer/features_v2/feed/feed_header_shell.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';
import 'package:trendsoccer/features_v2/feed/feed_sport_filter_row.dart';

class FeedNewsScreen extends StatefulWidget {
  const FeedNewsScreen({super.key});

  @override
  State<FeedNewsScreen> createState() => _FeedNewsScreenState();
}

class _FeedNewsScreenState extends State<FeedNewsScreen> {
  FeedNewsSportFilter? _selectedSport;

  @override
  Widget build(BuildContext context) {
    return FeedHeaderShell(
      segment: FeedSegment.news,
      filterRow: FeedSportFilterRow(
        selectedSport: _selectedSport,
        onSelected: (sport) => setState(() => _selectedSport = sport),
      ),
      child: const SizedBox.shrink(),
    );
  }
}
