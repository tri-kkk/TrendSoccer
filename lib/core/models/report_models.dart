/// Report feature models: soccer editorials and external baseball news.
class SoccerReport {
  const SoccerReport({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.leagueId,
    required this.publishedAt,
    required this.content,
    this.author = 'TrendSoccer',
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final String leagueId;
  final DateTime publishedAt;
  final String content;
  final String author;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'leagueId': leagueId,
        'publishedAt': publishedAt.toIso8601String(),
        'content': content,
        'author': author,
      };

  factory SoccerReport.fromJson(Map<String, dynamic> json) {
    return SoccerReport(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      leagueId: json['leagueId'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      content: json['content'] as String,
      author: json['author'] as String? ?? 'TrendSoccer',
    );
  }

  SoccerReport copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    String? leagueId,
    DateTime? publishedAt,
    String? content,
    String? author,
  }) {
    return SoccerReport(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      leagueId: leagueId ?? this.leagueId,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      author: author ?? this.author,
    );
  }
}

class BaseballNews {
  const BaseballNews({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.source,
    required this.publishedAt,
    required this.url,
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final String source;
  final DateTime publishedAt;
  final String url;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'source': source,
        'publishedAt': publishedAt.toIso8601String(),
        'url': url,
      };

  factory BaseballNews.fromJson(Map<String, dynamic> json) {
    return BaseballNews(
      id: json['id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      source: json['source'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      url: json['url'] as String,
    );
  }

  BaseballNews copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    String? source,
    DateTime? publishedAt,
    String? url,
  }) {
    return BaseballNews(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      url: url ?? this.url,
    );
  }
}
