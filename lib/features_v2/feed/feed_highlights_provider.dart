import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/language_provider.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/highlights_service.dart';
import 'package:trendsoccer/core/utils/api_language_helper.dart';
import 'package:trendsoccer/features_v2/feed/feed_highlights_logic.dart';
import 'package:trendsoccer/features_v2/feed/feed_highlight.dart';

const feedHighlightsLimit = 20;

final feedHighlightsProvider =
    FutureProvider<List<FeedHighlight>>((ref) async {
  ref.watch(languageProvider);
  final locale = getApiLanguage(ref.read(sharedPreferencesProvider));
  final raw = await ref
      .read(highlightsServiceProvider)
      .getHighlights(limit: feedHighlightsLimit);
  return parseFeedHighlights(raw, locale: locale);
});
