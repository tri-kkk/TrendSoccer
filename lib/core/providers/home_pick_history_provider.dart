import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/baseball_service.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';
import 'package:trendsoccer/design_system/widgets/ts_sport_toggle.dart';

/// Fetches pick history once per sport; period slicing is done client-side.
final homePickHistoryProvider =
    FutureProvider.family<Map<String, dynamic>, TsSport>((ref, sport) async {
  switch (sport) {
    case TsSport.soccer:
      return ref.read(soccerServiceProvider).getPremiumPickHistory();
    case TsSport.baseball:
      return ref.read(baseballServiceProvider).getBaseballPickHistory();
  }
});
