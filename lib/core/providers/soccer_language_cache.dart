import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';
import 'package:trendsoccer/core/providers/soccer_provider.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';

/// Clears cached soccer analysis data so the next read uses the updated API language.
void invalidateSoccerLanguageDependentProviders(Ref ref) {
    clearSoccerAnalysisEmptyCache();
  ref.read(soccerServiceProvider).clearResponseCache();
  ref.invalidate(analysisSoccerMatchesProvider);
  ref.invalidate(soccerH2HAnalysisProvider);
  ref.invalidate(homeTeamStatsProvider);
  ref.invalidate(awayTeamStatsProvider);
}
