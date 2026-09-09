import 'package:trendsoccer/core/utils/relative_time.dart';
import 'package:trendsoccer/features_v2/feed/feed_news_article.dart';

List<FeedNewsArticle> parseFeedNewsArticles(Map<String, dynamic> response) {
  final articlesRaw = response['articles'];
  if (articlesRaw is! List) {
    throw Exception('Failed to load feed news');
  }

  final seenIds = <String>{};
  final parsed = <({FeedNewsArticle article, DateTime? publishedAt})>[];

  for (final item in articlesRaw) {
    if (item is! Map) continue;
    final json = Map<String, dynamic>.from(item);

    final id = json['id']?.toString().trim() ?? '';
    final title = json['title']?.toString().trim() ?? '';
    final url = json['url']?.toString().trim() ?? '';
    if (id.isEmpty || title.isEmpty || url.isEmpty) continue;
    if (seenIds.contains(id)) continue;
    seenIds.add(id);

    final source = json['source']?.toString().trim() ?? '';
    final publishedAt = DateTime.tryParse(
      json['publishedAt']?.toString().trim() ?? '',
    );
    final imageUrl = json['imageUrl']?.toString().trim();
    final parsedImageUrl =
        imageUrl != null && imageUrl.isNotEmpty ? imageUrl : null;

    parsed.add(
      (
        article: FeedNewsArticle(
          id: id,
          titleLabel: title,
          sourceLabel: source.isNotEmpty ? source : 'News',
          timeLabel:
              publishedAt == null ? '—' : formatRelativeTime(publishedAt),
          url: url,
          imageUrl: parsedImageUrl,
        ),
        publishedAt: publishedAt,
      ),
    );
  }

  parsed.sort((a, b) => _comparePublishedAt(a.publishedAt, b.publishedAt));
  return parsed.map((entry) => entry.article).toList(growable: false);
}

int _comparePublishedAt(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}
