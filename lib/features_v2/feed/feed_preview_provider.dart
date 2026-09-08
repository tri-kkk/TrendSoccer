import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/blog_service.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_logic.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_post.dart';

const feedPreviewPostsLimit = 40;

final feedPreviewPostsProvider =
    FutureProvider<List<FeedPreviewPost>>((ref) async {
  ref.watch(languageProvider);
  final locale = getApiLanguage(ref.read(sharedPreferencesProvider));
  final raw = await ref
      .read(blogServiceProvider)
      .getBlogPosts(limit: feedPreviewPostsLimit, offset: 0);
  return parseFeedPreviewPosts(raw, locale: locale);
});
