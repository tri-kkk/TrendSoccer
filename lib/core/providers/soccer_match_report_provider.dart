import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/soccer_service.dart';

final soccerAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  return ref.read(soccerServiceProvider).getMatchAnalysis(matchId: matchId);
});

final soccerPremiumProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  return ref.read(soccerServiceProvider).getMatchPremium(matchId: matchId);
});
