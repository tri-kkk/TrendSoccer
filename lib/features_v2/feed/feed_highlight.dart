class FeedHighlight {
  const FeedHighlight({
    required this.id,
    required this.youtubeId,
    required this.youtubeUrl,
    required this.titleLabel,
    required this.metaLabel,
    required this.league,
    this.imageUrl,
  });

  final String id;
  final String youtubeId;
  final String youtubeUrl;
  final String titleLabel;
  final String metaLabel;
  final String league;
  final String? imageUrl;
}
