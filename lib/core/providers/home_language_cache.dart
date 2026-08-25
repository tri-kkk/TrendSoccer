import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/home_combo_summary_provider.dart';
import 'package:trendsoccer/core/providers/home_match_preview_provider.dart';
import 'package:trendsoccer/core/providers/home_pick_history_provider.dart';
import 'package:trendsoccer/core/providers/news_provider.dart';

/// Clears cached home data so the next read uses the updated API language.
void invalidateHomeLanguageDependentProviders(Ref ref) {
  ref.invalidate(homeNewsProvider);
  ref.invalidate(homeComboSummaryProvider);
  ref.invalidate(homePickHistoryProvider);
  ref.invalidate(homeAnalysisMatchesProvider);
  ref.invalidate(homeTodayMatchesProvider);
}
