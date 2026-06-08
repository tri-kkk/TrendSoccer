import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/baseball_combo_provider.dart';
import 'package:trendsoccer/core/providers/baseball_match_report_provider.dart';
import 'package:trendsoccer/core/providers/baseball_provider.dart';

/// Clears cached baseball data so the next read uses the updated API language.
void invalidateBaseballLanguageDependentProviders(Ref ref) {
  debugPrint('[BASEBALL] Invalidating providers after language change');
  ref.invalidate(baseballMatchDetailProvider);
  ref.invalidate(baseballPitcherAnalysisProvider);
  ref.invalidate(baseballPredictProvider);
  ref.invalidate(baseballHomeTeamStatsProvider);
  ref.invalidate(baseballAwayTeamStatsProvider);
  ref.invalidate(baseballH2HProvider);
  ref.invalidate(baseballPitcherStatsProvider);
  ref.invalidate(mlbPitcherStatsProvider);
  ref.invalidate(mlbPitcherStatsPrevProvider);
  ref.invalidate(baseballAnalysisMatchesProvider);
  ref.invalidate(baseballComboPicksProvider);
  ref.invalidate(baseballComboStatsProvider);
}
