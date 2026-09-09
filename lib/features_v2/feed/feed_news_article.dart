import 'package:trendsoccer/features_v2/feed/feed_route_map.dart';

class FeedNewsArticle {
  const FeedNewsArticle({
    required this.id,
    required this.titleLabel,
    required this.sourceLabel,
    required this.timeLabel,
    required this.url,
    this.sport,
    this.imageUrl,
  });

  final String id;
  final String titleLabel;
  final String sourceLabel;
  final String timeLabel;
  final String url;
  final FeedNewsSportFilter? sport;
  final String? imageUrl;
}
