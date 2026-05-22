import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/baseball_service.dart';

final baseballMatchDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  return ref.read(baseballServiceProvider).getMatchDetail(matchId: matchId);
});

final baseballAiAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, matchId) async {
  return ref.read(baseballServiceProvider).getAiAnalysis(matchId: matchId);
});
