class FeedPreviewDetail {
  const FeedPreviewDetail({
    required this.slug,
    required this.title,
    required this.content,
    required this.dateLabel,
    required this.tags,
    this.imageUrl,
  });

  final String slug;
  final String title;
  final String content;
  final String dateLabel;
  final List<String> tags;
  final String? imageUrl;
}

const feedPreviewPredictionSectionMarkers = [
  '## TrendSoccer Prediction',
  '## TrendSoccer Analysis',
  '## TrendSoccer 분석',
  '## 트렌드사커 예측',
  '## 트렌드사커 분석',
  '## Prediction',
  '## Analysis',
  '## 예측',
  '## 분석',
];

Map<String, dynamic>? extractFeedPreviewPost(Map<String, dynamic> response) {
  final data = response['data'];
  if (data is Map) return Map<String, dynamic>.from(data);
  return null;
}

String localizedFeedPreviewTitle(String locale, Map<String, dynamic> json) {
  if (locale == 'en') {
    return json['title']?.toString() ?? json['title_kr']?.toString() ?? '';
  }
  return json['title_kr']?.toString() ?? json['title']?.toString() ?? '';
}

String? readFeedPreviewThumbnail(Map<String, dynamic> post) {
  final thumbnail = post['thumbnail_url']?.toString() ??
      post['cover_image']?.toString() ??
      '';
  if (thumbnail.trim().isEmpty) return null;
  return thumbnail.trim();
}

List<String> readFeedPreviewTags(Map<String, dynamic> post) {
  final tags = post['tags'];
  if (tags is List) {
    return tags.map((tag) => tag.toString()).toList();
  }
  return const [];
}

String formatFeedPreviewDate(String? publishedAt) {
  if (publishedAt == null || publishedAt.isEmpty) return '';
  final date = DateTime.tryParse(publishedAt);
  if (date == null) return '';
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

FeedPreviewDetail? parseFeedPreviewDetail(
  Map<String, dynamic> response, {
  required String locale,
}) {
  final post = extractFeedPreviewPost(response);
  if (post == null || post.isEmpty) return null;

  final slug = post['slug']?.toString().trim() ?? '';
  if (slug.isEmpty) return null;

  final title = localizedFeedPreviewTitle(locale, post).trim();
  if (title.isEmpty) return null;

  return FeedPreviewDetail(
    slug: slug,
    title: title,
    content: post['content']?.toString() ?? '',
    dateLabel: formatFeedPreviewDate(post['published_at']?.toString()),
    tags: readFeedPreviewTags(post),
    imageUrl: readFeedPreviewThumbnail(post),
  );
}

String extractFeedPreviewMatchupTitle(String content, String titleFallback) {
  final lines = content.split('\n');
  for (final line in lines) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('# ')) {
      final h1Text = trimmed.substring(2).trim();
      if (h1Text.contains(':')) {
        return h1Text.split(':').first.trim();
      }
      return h1Text;
    }
  }
  return titleFallback;
}

String removeFeedPreviewLeadingH1(String content) {
  final lines = content.split('\n');
  if (lines.isNotEmpty && lines.first.trimLeft().startsWith('# ')) {
    var startIndex = 1;
    while (startIndex < lines.length && lines[startIndex].trim().isEmpty) {
      startIndex++;
    }
    return lines.sublist(startIndex).join('\n');
  }
  return content;
}

String cleanFeedPreviewMarkdownContent(String content) {
  content = removeFeedPreviewLeadingH1(content);
  content = content.replaceAll(RegExp(r'[█░]+\s*'), '');
  return content;
}

(String body, String? heading, String? predictionBody) splitFeedPreviewAnalysisSection(
  String cleanContent,
) {
  int? splitIndex;
  String? matchedMarker;
  for (final marker in feedPreviewPredictionSectionMarkers) {
    final index = cleanContent.indexOf(marker);
    if (index >= 0 && (splitIndex == null || index < splitIndex)) {
      splitIndex = index;
      matchedMarker = marker;
    }
  }
  if (splitIndex == null || matchedMarker == null) {
    return (cleanContent, null, null);
  }

  final headingStart = splitIndex;
  final afterMarker = splitIndex + matchedMarker.length;
  final newlineIndex = cleanContent.indexOf('\n', afterMarker);
  final headingEnd = newlineIndex >= 0 ? newlineIndex : cleanContent.length;
  final headingLine = cleanContent.substring(headingStart, headingEnd).trim();
  final bodyAfterHeading = newlineIndex >= 0
      ? cleanContent.substring(newlineIndex + 1).trim()
      : '';

  return (
    cleanContent.substring(0, headingStart).trim(),
    headingLine,
    bodyAfterHeading.isEmpty ? null : bodyAfterHeading,
  );
}

String feedPreviewPredictionHeadingDisplayText(String headingLine) {
  final trimmed = headingLine.trimLeft();
  if (trimmed.startsWith('## ')) {
    return trimmed.substring(3).trim();
  }
  return headingLine;
}
