import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/services/news_service.dart';
import 'package:trendsoccer/features_v2/feed/feed_news_article.dart';
import 'package:trendsoccer/features_v2/feed/feed_news_logic.dart';

final feedNewsProvider = FutureProvider<List<FeedNewsArticle>>((ref) async {
  ref.watch(languageProvider);
  final raw = await ref.read(newsServiceProvider).getNews();
  return parseFeedNewsArticles(raw);
});
