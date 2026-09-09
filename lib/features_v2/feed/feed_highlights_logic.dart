import 'package:intl/intl.dart';

import 'package:trendsoccer/core/assets/ts_assets.dart';
import 'package:trendsoccer/features_v2/feed/feed_highlight.dart';

String? leagueEmblemIdFromLeague(String league) =>
    TsAssets.leagueLogoIdFromBlogTags([league]);

String formatHighlightMetaLabel({
  required String league,
  required String matchDate,
  required String locale,
}) {
  final leagueLabel = league.trim();
  final dateLabel = _formatHighlightMatchDate(matchDate, locale: locale);
  if (leagueLabel.isEmpty) return dateLabel;
  if (dateLabel.isEmpty) return leagueLabel;
  return '$leagueLabel · $dateLabel';
}

String _formatHighlightMatchDate(String matchDate, {required String locale}) {
  final parsed = DateTime.tryParse(matchDate.trim());
  if (parsed == null) return '';
  final local = parsed.toLocal();
  if (locale == 'en') {
    return DateFormat('MMM d', 'en').format(local);
  }
  return DateFormat('M월 d일', 'ko').format(local);
}

String? _readThumbnail(Map<String, dynamic> item) {
  final thumbnail = item['thumbnailUrl']?.toString() ?? '';
  if (thumbnail.trim().isEmpty) return null;
  return thumbnail.trim();
}

List<FeedHighlight> parseFeedHighlights(
  Map<String, dynamic> response, {
  required String locale,
}) {
  if (response.isEmpty) {
    throw Exception('Failed to load feed highlights');
  }

  final highlightsRaw = response['highlights'];
  if (highlightsRaw is! List) {
    throw Exception('Failed to load feed highlights');
  }

  final highlights = <FeedHighlight>[];
  for (final item in highlightsRaw) {
    if (item is! Map) continue;
    final json = Map<String, dynamic>.from(item);

    final youtubeId = json['youtubeId']?.toString().trim() ?? '';
    final youtubeUrl = json['youtubeUrl']?.toString().trim() ?? '';
    if (youtubeId.isEmpty || youtubeUrl.isEmpty) continue;

    final title = json['videoTitle']?.toString().trim() ?? '';
    if (title.isEmpty) continue;

    final league = json['league']?.toString().trim() ?? '';
    final matchDate = json['matchDate']?.toString().trim() ?? '';
    final id = json['id']?.toString().trim() ?? youtubeId;

    highlights.add(
      FeedHighlight(
        id: id,
        youtubeId: youtubeId,
        youtubeUrl: youtubeUrl,
        titleLabel: title,
        metaLabel: formatHighlightMetaLabel(
          league: league,
          matchDate: matchDate,
          locale: locale,
        ),
        league: league,
        imageUrl: _readThumbnail(json),
      ),
    );
  }

  return highlights;
}
