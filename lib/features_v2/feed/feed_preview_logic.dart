import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/core/models/league_filter_chips.dart';
import 'package:trendsoccer/features_v2/feed/feed_preview_post.dart';

List<Map<String, dynamic>> _extractPosts(Map<String, dynamic> response) {
  final data = response['data'];
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  final posts = response['posts'];
  if (posts is List) {
    return posts
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  return const [];
}

String _localizedTitle(String locale, Map<String, dynamic> json) {
  if (locale == 'en') {
    return json['title']?.toString() ?? json['title_kr']?.toString() ?? '';
  }
  return json['title_kr']?.toString() ?? json['title']?.toString() ?? '';
}

String _localizedExcerpt(String locale, Map<String, dynamic> json) {
  if (locale == 'en') {
    final english =
        json['excerpt_en']?.toString() ?? json['excerptEn']?.toString();
    if (english != null && english.trim().isNotEmpty) {
      return english.trim();
    }
    return json['excerpt']?.toString() ?? '';
  }
  return json['excerpt_kr']?.toString() ??
      json['excerpt']?.toString() ??
      '';
}

String? _readThumbnail(Map<String, dynamic> post) {
  final thumbnail = post['thumbnail_url']?.toString() ??
      post['cover_image']?.toString() ??
      '';
  if (thumbnail.trim().isEmpty) return null;
  return thumbnail.trim();
}

List<String> _readTags(Map<String, dynamic> post) {
  final tags = post['tags'];
  if (tags is List) {
    return tags.map((tag) => tag.toString()).toList();
  }
  return const [];
}

String _formatPublishedDate(String publishedAt) {
  final date = DateTime.tryParse(publishedAt.trim());
  if (date == null) return '';
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

bool _responseHasPostsEnvelope(Map<String, dynamic> response) {
  return response.containsKey('data') || response.containsKey('posts');
}

List<FeedPreviewPost> parseFeedPreviewPosts(
  Map<String, dynamic> response, {
  required String locale,
}) {
  if (response.isEmpty) {
    throw Exception('Failed to load feed previews');
  }
  if (!_responseHasPostsEnvelope(response)) {
    throw Exception('Failed to load feed previews');
  }

  final posts = <FeedPreviewPost>[];
  for (final post in _extractPosts(response)) {
    if (post['published_at'] == null) continue;

    final slug = post['slug']?.toString().trim() ?? '';
    if (slug.isEmpty) continue;

    final title = _localizedTitle(locale, post).trim();
    if (title.isEmpty) continue;

    posts.add(
      FeedPreviewPost(
        slug: slug,
        title: title,
        excerpt: _localizedExcerpt(locale, post).trim(),
        dateLabel: _formatPublishedDate(post['published_at'].toString()),
        tags: _readTags(post),
        imageUrl: _readThumbnail(post),
      ),
    );
  }

  return posts;
}

List<FeedPreviewPost> filterFeedPreviewPosts(
  List<FeedPreviewPost> posts,
  String? selectedLeagueId,
) {
  if (selectedLeagueId == null || selectedLeagueId.isEmpty) {
    return posts;
  }

  return posts.where((post) {
    final postLeagueId = TsAssets.leagueLogoIdFromBlogTags(post.tags);
    return postLeagueId == selectedLeagueId;
  }).toList();
}

String leagueLabelForEmblemId(String? emblemId, String languageCode) {
  if (emblemId == null || emblemId.isEmpty) return '';
  for (final chip in soccerAnalysisLeagueChips) {
    if (chip.id == emblemId) {
      return chip.displayLabel(languageCode);
    }
  }
  return '';
}

String? leagueEmblemIdFromTags(List<String> tags) =>
    TsAssets.leagueLogoIdFromBlogTags(tags);
