import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/soccer_match_report_provider.dart';

/// Clears cached soccer analysis data so the next read uses the updated API language.
void invalidateSoccerLanguageDependentProviders(Ref ref) {
  debugPrint('[SOCCER] Invalidating providers after language change');
  ref.invalidate(soccerH2HAnalysisProvider);
  ref.invalidate(homeTeamStatsProvider);
  ref.invalidate(awayTeamStatsProvider);
}
