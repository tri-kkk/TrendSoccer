import 'package:intl/intl.dart';

import 'package:trendsoccer/features_v2/feed/feed_highlight.dart';

String? extractIframeSrcFromEmbed(String embedHtml) {
  final match = RegExp(
    r"""<iframe[^>]+src\s*=\s*['"]([^'"]+)['"]""",
    caseSensitive: false,
  ).firstMatch(embedHtml);
  final src = match?.group(1)?.trim();
  if (src == null || src.isEmpty) return null;
  return src;
}

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

String _readLeagueName(Map<String, dynamic> item, {required String locale}) {
  final leagueInfoRaw = item['leagueInfo'];
  if (leagueInfoRaw is Map) {
    final leagueInfo = Map<String, dynamic>.from(leagueInfoRaw);
    if (locale == 'ko') {
      final nameKr = leagueInfo['nameKR']?.toString().trim() ?? '';
      if (nameKr.isNotEmpty) return nameKr;
    }
    final name = leagueInfo['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) return name;
  }
  return item['competition']?.toString().trim() ?? '';
}

String? _readLeagueLogoUrl(Map<String, dynamic> item) {
  final leagueInfoRaw = item['leagueInfo'];
  if (leagueInfoRaw is! Map) return null;
  final logo = Map<String, dynamic>.from(leagueInfoRaw)['logo']?.toString().trim() ??
      '';
  if (logo.isEmpty) return null;
  return logo;
}

String? _readThumbnail(Map<String, dynamic> item) {
  final thumbnail = item['thumbnail']?.toString() ?? '';
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

  final videosRaw = response['videos'];
  if (videosRaw is! List) {
    throw Exception('Failed to load feed highlights');
  }

  final highlights = <FeedHighlight>[];
  for (final item in videosRaw) {
    if (item is! Map) continue;
    final json = Map<String, dynamic>.from(item);

    final embed = json['embed']?.toString() ?? '';
    final embedUrl = extractIframeSrcFromEmbed(embed);
    if (embedUrl == null) continue;

    final title = json['title']?.toString().trim() ?? '';
    if (title.isEmpty) continue;

    final id = json['id']?.toString().trim() ?? '';
    if (id.isEmpty) continue;

    final matchDate = json['date']?.toString().trim() ?? '';
    final leagueCode = json['leagueCode']?.toString().trim() ?? '';

    highlights.add(
      FeedHighlight(
        id: id,
        titleLabel: title,
        metaLabel: formatHighlightMetaLabel(
          league: _readLeagueName(json, locale: locale),
          matchDate: matchDate,
          locale: locale,
        ),
        embedUrl: embedUrl,
        leagueCode: leagueCode,
        imageUrl: _readThumbnail(json),
        leagueLogoUrl: _readLeagueLogoUrl(json),
      ),
    );
  }

  return highlights;
}
