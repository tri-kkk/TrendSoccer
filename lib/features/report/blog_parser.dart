import 'package:flutter/foundation.dart';

class BlogPostListItem {
  const BlogPostListItem({
    required this.slug,
    required this.title,
    required this.description,
    required this.date,
    required this.thumbnailUrl,
    this.language,
  });

  final String slug;
  final String title;
  final String description;
  final String date;
  final String thumbnailUrl;
  final String? language;
}

class BlogPostDetail {
  const BlogPostDetail({
    required this.slug,
    required this.title,
    required this.content,
    required this.date,
    required this.thumbnailUrl,
    required this.tags,
    this.language,
  });

  final String slug;
  final String title;
  final String content;
  final String date;
  final String thumbnailUrl;
  final List<String> tags;
  final String? language;
}

class BlogParser {
  BlogParser._();

  static List<BlogPostListItem> parsePostsList(
    Map<String, dynamic> response, {
    required String locale,
  }) {
    final raw = _extractPosts(response);
    if (raw.isNotEmpty) {
      final first = raw.first;
      debugPrint(
        '[BLOG] First item: title=${first['title']}, title_kr=${first['title_kr']}',
      );
    }
    return raw
        .map((post) => _parseListItem(post, locale: locale))
        .where((item) => item.slug.isNotEmpty)
        .toList();
  }

  static BlogPostDetail? parsePostDetail(
    Map<String, dynamic> response, {
    required String locale,
  }) {
    final post = _extractPost(response);
    if (post == null || post.isEmpty) return null;

    final slug = post['slug']?.toString() ?? '';
    if (slug.isEmpty) return null;

    return BlogPostDetail(
      slug: slug,
      title: localizedBlogTitle(locale, post),
      content: post['content']?.toString() ?? '',
      date: formatPublishedDate(post['published_at']?.toString()),
      thumbnailUrl: _readThumbnail(post),
      tags: _readTags(post),
      language: post['language']?.toString(),
    );
  }

  static String localizedBlogTitle(String locale, Map<String, dynamic> json) {
    if (locale == 'en') {
      return json['title']?.toString() ?? json['title_kr']?.toString() ?? '';
    }
    return json['title_kr']?.toString() ?? json['title']?.toString() ?? '';
  }

  static String localizedBlogExcerpt(String locale, Map<String, dynamic> json) {
    if (locale == 'en') {
      final english = json['excerpt_en']?.toString() ?? json['excerptEn']?.toString();
      if (english != null && english.trim().isNotEmpty) {
        return english.trim();
      }
      return json['excerpt']?.toString() ?? '';
    }
    return json['excerpt_kr']?.toString() ??
        json['excerpt']?.toString() ??
        '';
  }

  static BlogPostListItem _parseListItem(
    Map<String, dynamic> post, {
    required String locale,
  }) {
    return BlogPostListItem(
      slug: post['slug']?.toString() ?? '',
      title: localizedBlogTitle(locale, post),
      description: localizedBlogExcerpt(locale, post),
      date: formatPublishedDate(post['published_at']?.toString()),
      thumbnailUrl: _readThumbnail(post),
      language: post['language']?.toString(),
    );
  }

  static String _readThumbnail(Map<String, dynamic> post) {
    return post['thumbnail_url']?.toString() ??
        post['cover_image']?.toString() ??
        '';
  }

  static List<String> _readTags(Map<String, dynamic> post) {
    final tags = post['tags'];
    if (tags is List) {
      return tags.map((tag) => tag.toString()).toList();
    }
    return const [];
  }

  static String formatPublishedDate(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) return '';
    final date = DateTime.tryParse(publishedAt);
    if (date == null) return '';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  static List<Map<String, dynamic>> _extractPosts(Map<String, dynamic> response) {
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

  static Map<String, dynamic>? _extractPost(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) return Map<String, dynamic>.from(data);

    final post = response['post'];
    if (post is Map) return Map<String, dynamic>.from(post);

    if (response.containsKey('slug') || response.containsKey('content')) {
      return response;
    }

    return null;
  }
}
