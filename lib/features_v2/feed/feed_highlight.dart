class FeedHighlight {
  const FeedHighlight({
    required this.id,
    required this.titleLabel,
    required this.metaLabel,
    required this.embedUrl,
    required this.leagueCode,
    this.imageUrl,
    this.leagueLogoUrl,
  });

  final String id;
  final String titleLabel;
  final String metaLabel;
  final String embedUrl;
  final String leagueCode;
  final String? imageUrl;
  final String? leagueLogoUrl;
}
