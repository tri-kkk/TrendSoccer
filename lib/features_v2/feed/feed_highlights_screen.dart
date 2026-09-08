import 'package:flutter/material.dart';

import 'package:trendsoccer/features_v2/feed/feed_header_shell.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';

class FeedHighlightsScreen extends StatelessWidget {
  const FeedHighlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeedHeaderShell(
      segment: FeedSegment.highlights,
      child: SizedBox.shrink(),
    );
  }
}
