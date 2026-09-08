class FeedPreviewPost {
  const FeedPreviewPost({
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.dateLabel,
    required this.tags,
    this.imageUrl,
  });

  final String slug;
  final String title;
  final String excerpt;
  final String dateLabel;
  final List<String> tags;
  final String? imageUrl;
}
