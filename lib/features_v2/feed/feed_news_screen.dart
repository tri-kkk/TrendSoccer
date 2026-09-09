import 'package:flutter/material.dart';

import 'package:trendsoccer/features_v2/feed/feed_header_shell.dart';
import 'package:trendsoccer/features_v2/feed/feed_news_body.dart';
import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';

class FeedNewsScreen extends StatelessWidget {
  const FeedNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeedHeaderShell(
      segment: FeedSegment.news,
      child: FeedNewsBody(),
    );
  }
}
