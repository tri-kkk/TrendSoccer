import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

/// Reports shell segment — distinct from bottom-nav tab.
enum ReportsSegment {
  analysis,
  premium,
  multiMatch,
}

/// One league chip option for [ReportsLeagueFilterRow].
typedef ReportsLeagueFilterOption = ({
  String id,
  String label,
  String emblemId,
});

const reportsSoccerAnalysisRoute = '/reports/soccer';
const reportsSoccerPremiumRoute = '/reports/soccer/premium';
const reportsBaseballAnalysisRoute = '/reports/baseball';
const reportsComboRoute = '/reports/combo';

/// All four routes inside the reports shell branch.
const reportsShellRoutes = [
  reportsSoccerAnalysisRoute,
  reportsSoccerPremiumRoute,
  reportsBaseballAnalysisRoute,
  reportsComboRoute,
];

class ReportsRouteDescriptor {
  const ReportsRouteDescriptor({
    required this.sport,
    required this.segment,
  });

  final TsSport sport;
  final ReportsSegment segment;
}

String _normalizeReportsPath(String path) {
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}

/// Segment tab labels for the active sport.
List<String> reportsSegmentLabels(TsSport sport, AppLocalizations l10n) {
  switch (sport) {
    case TsSport.soccer:
      return [l10n.reportsTabAnalysis, l10n.reportsTabPremium];
    case TsSport.baseball:
      return [l10n.reportsTabAnalysis, l10n.reportsTabMultiMatch];
  }
}

/// Route path for sport + segment.
String reportsRouteFor(TsSport sport, ReportsSegment segment) {
  switch (sport) {
    case TsSport.soccer:
      switch (segment) {
        case ReportsSegment.analysis:
          return reportsSoccerAnalysisRoute;
        case ReportsSegment.premium:
          return reportsSoccerPremiumRoute;
        case ReportsSegment.multiMatch:
          return reportsComboRoute;
      }
    case TsSport.baseball:
      switch (segment) {
        case ReportsSegment.analysis:
          return reportsBaseballAnalysisRoute;
        case ReportsSegment.multiMatch:
          return reportsComboRoute;
        case ReportsSegment.premium:
          return reportsBaseballAnalysisRoute;
      }
  }
}

/// Derive sport and segment from a reports shell route path.
ReportsRouteDescriptor reportsDescriptorFromPath(String path) {
  switch (_normalizeReportsPath(path)) {
    case reportsSoccerPremiumRoute:
      return const ReportsRouteDescriptor(
        sport: TsSport.soccer,
        segment: ReportsSegment.premium,
      );
    case reportsBaseballAnalysisRoute:
      return const ReportsRouteDescriptor(
        sport: TsSport.baseball,
        segment: ReportsSegment.analysis,
      );
    case reportsComboRoute:
      return const ReportsRouteDescriptor(
        sport: TsSport.baseball,
        segment: ReportsSegment.multiMatch,
      );
    case reportsSoccerAnalysisRoute:
    default:
      return const ReportsRouteDescriptor(
        sport: TsSport.soccer,
        segment: ReportsSegment.analysis,
      );
  }
}

int reportsSegmentIndex(TsSport sport, ReportsSegment segment) {
  switch (sport) {
    case TsSport.soccer:
      switch (segment) {
        case ReportsSegment.premium:
          return 1;
        case ReportsSegment.analysis:
        case ReportsSegment.multiMatch:
          return 0;
      }
    case TsSport.baseball:
      switch (segment) {
        case ReportsSegment.multiMatch:
          return 1;
        case ReportsSegment.analysis:
        case ReportsSegment.premium:
          return 0;
      }
  }
}

ReportsSegment reportsSegmentAtIndex(TsSport sport, int index) {
  switch (sport) {
    case TsSport.soccer:
      return index == 1 ? ReportsSegment.premium : ReportsSegment.analysis;
    case TsSport.baseball:
      return index == 1 ? ReportsSegment.multiMatch : ReportsSegment.analysis;
  }
}

/// Multi-Match shows the date strip above the league filter row.
bool reportsShowsDateStrip(ReportsSegment segment) =>
    segment == ReportsSegment.multiMatch;
