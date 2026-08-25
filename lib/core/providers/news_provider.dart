import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trendsoccer/core/services/news_service.dart';

const homeNewsLimit = 3;

class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.url,
    required this.source,
    required this.publishedAt,
  });

  final String id;
  final String title;
  final String? imageUrl;
  final String url;
  final String source;
  final DateTime? publishedAt;
}

final homeNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final raw = await ref.read(newsServiceProvider).getNews();
  final extraction = _extractNewsArticles(raw);
  // TODO(diagnostic): remove once the news feed is verified
  debugPrint(
    '[news] shape=${extraction.flat ? 'flat' : 'nested'} raw=${extraction.rawCount}',
  );
  final articles = extraction.articles;
  // TODO(diagnostic): remove once the news feed is verified
  debugPrint('[news] flattened=${articles.length} after dedupe');
  articles.sort(_comparePublishedAt);
  if (articles.length <= homeNewsLimit) {
    return articles;
  }
  return articles.sublist(0, homeNewsLimit);
});

class _NewsExtraction {
  const _NewsExtraction({
    required this.articles,
    required this.flat,
    required this.rawCount,
  });

  final List<NewsArticle> articles;
  final bool flat;
  final int rawCount;
}

_NewsExtraction _extractNewsArticles(Map<String, dynamic> response) {
  final seenIds = <String>{};

  final flatArticles = response['articles'];
  if (flatArticles is List) {
    final articleMaps = <Map<String, dynamic>>[];
    for (final article in flatArticles) {
      if (article is Map) {
        articleMaps.add(Map<String, dynamic>.from(article));
      }
    }
    return _NewsExtraction(
      articles: _parseArticleMaps(articleMaps, seenIds),
      flat: true,
      rawCount: flatArticles.length,
    );
  }

  final categories = response['categories'];
  if (categories is! List) {
    return const _NewsExtraction(articles: [], flat: false, rawCount: 0);
  }

  final articleMaps = <Map<String, dynamic>>[];
  var rawCount = 0;

  for (final category in categories) {
    if (category is! Map) continue;
    final categoryMap = Map<String, dynamic>.from(category);
    final categoryArticles = categoryMap['articles'];
    if (categoryArticles is! List) continue;

    rawCount += categoryArticles.length;
    for (final article in categoryArticles) {
      if (article is Map) {
        articleMaps.add(Map<String, dynamic>.from(article));
      }
    }
  }

  return _NewsExtraction(
    articles: _parseArticleMaps(articleMaps, seenIds),
    flat: false,
    rawCount: rawCount,
  );
}

List<NewsArticle> _parseArticleMaps(
  List<Map<String, dynamic>> articleMaps,
  Set<String> seenIds,
) {
  final articles = <NewsArticle>[];

  for (final articleMap in articleMaps) {
    final id = articleMap['id']?.toString().trim() ?? '';
    final title = articleMap['title']?.toString().trim() ?? '';
    final url = articleMap['url']?.toString().trim() ?? '';
    final source = articleMap['source']?.toString().trim() ?? '';
    if (id.isEmpty || title.isEmpty || url.isEmpty) continue;
    if (seenIds.contains(id)) continue;
    seenIds.add(id);

    final imageUrl = articleMap['imageUrl']?.toString().trim();
    final publishedAt = _parsePublishedAt(articleMap['publishedAt']);

    articles.add(
      NewsArticle(
        id: id,
        title: title,
        imageUrl: imageUrl != null && imageUrl.isNotEmpty ? imageUrl : null,
        url: url,
        source: source.isNotEmpty ? source : 'News',
        publishedAt: publishedAt,
      ),
    );
  }

  return articles;
}

DateTime? _parsePublishedAt(Object? raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw.toString().trim());
}

int _comparePublishedAt(NewsArticle a, NewsArticle b) {
  final aDate = a.publishedAt;
  final bDate = b.publishedAt;
  if (aDate == null && bDate == null) return 0;
  if (aDate == null) return 1;
  if (bDate == null) return -1;
  return bDate.compareTo(aDate);
}
