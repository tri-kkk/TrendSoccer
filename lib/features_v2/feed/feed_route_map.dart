import 'package:trendsoccer/l10n/app_localizations.dart';

/// Feed shell segment — distinct from bottom-nav tab.
enum FeedSegment {
  preview,
  news,
  highlights,
}

/// One league chip option for [FeedLeagueFilterRow].
typedef FeedLeagueFilterOption = ({  String id,
  String label,
  String emblemId,
});

/// News sport filter selection — `null` means All.
enum FeedNewsSportFilter {
  soccer,
  baseball,
}

const feedPreviewRoute = '/feed/preview';
const feedNewsRoute = '/feed/news';
const feedHighlightsRoute = '/feed/highlights';

/// All three routes inside the feed shell branch.
const feedShellRoutes = [
  feedPreviewRoute,
  feedNewsRoute,
  feedHighlightsRoute,
];

String _normalizeFeedPath(String path) {
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}

/// Segment tab labels for the feed shell.
List<String> feedSegmentLabels(AppLocalizations l10n) => [
      l10n.feedTabPreview,
      l10n.feedTabNews,
      l10n.feedTabHighlights,
    ];

/// Route path for segment.
String feedRouteFor(FeedSegment segment) {
  switch (segment) {
    case FeedSegment.preview:
      return feedPreviewRoute;
    case FeedSegment.news:
      return feedNewsRoute;
    case FeedSegment.highlights:
      return feedHighlightsRoute;
  }
}

/// Derive segment from a feed shell route path.
FeedSegment feedSegmentFromPath(String path) {
  switch (_normalizeFeedPath(path)) {
    case feedNewsRoute:
      return FeedSegment.news;
    case feedHighlightsRoute:
      return FeedSegment.highlights;
    case feedPreviewRoute:
    default:
      return FeedSegment.preview;
  }
}

int feedSegmentIndex(FeedSegment segment) {
  switch (segment) {
    case FeedSegment.preview:
      return 0;
    case FeedSegment.news:
      return 1;
    case FeedSegment.highlights:
      return 2;
  }
}

FeedSegment feedSegmentAtIndex(int index) {
  switch (index) {
    case 1:
      return FeedSegment.news;
    case 2:
      return FeedSegment.highlights;
    case 0:
    default:
      return FeedSegment.preview;
  }
}
