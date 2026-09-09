class FeedNewsArticle {
  const FeedNewsArticle({
    required this.id,
    required this.titleLabel,
    required this.sourceLabel,
    required this.timeLabel,
    required this.url,
    this.imageUrl,
  });

  final String id;
  final String titleLabel;
  final String sourceLabel;
  final String timeLabel;
  final String url;
  final String? imageUrl;
}
