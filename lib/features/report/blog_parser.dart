class BlogPostListItem {
  const BlogPostListItem({
    required this.slug,
    required this.title,
    required this.description,
    required this.date,
    required this.thumbnailUrl,
  });

  final String slug;
  final String title;
  final String description;
  final String date;
  final String thumbnailUrl;
}

class BlogPostDetail {
  const BlogPostDetail({
    required this.slug,
    required this.title,
    required this.content,
    required this.date,
    required this.thumbnailUrl,
    required this.tags,
  });

  final String slug;
  final String title;
  final String content;
  final String date;
  final String thumbnailUrl;
  final List<String> tags;
}

class BlogParser {
  BlogParser._();

  static List<BlogPostListItem> parsePostsList(Map<String, dynamic> response) {
    final raw = _extractPosts(response);
    return raw.map(_parseListItem).where((item) => item.slug.isNotEmpty).toList();
  }

  static BlogPostDetail? parsePostDetail(Map<String, dynamic> response) {
    final post = _extractPost(response);
    if (post == null || post.isEmpty) return null;

    final slug = post['slug']?.toString() ?? '';
    if (slug.isEmpty) return null;

    return BlogPostDetail(
      slug: slug,
      title: post['title_kr']?.toString() ?? post['title']?.toString() ?? '',
      content: post['content']?.toString() ?? '',
      date: formatPublishedDate(post['published_at']?.toString()),
      thumbnailUrl: _readThumbnail(post),
      tags: _readTags(post),
    );
  }

  static BlogPostListItem _parseListItem(Map<String, dynamic> post) {
    return BlogPostListItem(
      slug: post['slug']?.toString() ?? '',
      title: post['title_kr']?.toString() ?? post['title']?.toString() ?? '',
      description: post['excerpt']?.toString() ?? '',
      date: formatPublishedDate(post['published_at']?.toString()),
      thumbnailUrl: _readThumbnail(post),
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
