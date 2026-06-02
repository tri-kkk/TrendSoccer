import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/services/baseball_combo_service.dart';
import 'package:trendsoccer/core/services/baseball_service.dart';

final baseballComboPicksProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(baseballServiceProvider);
  return service.getBaseballComboPicks(days: 30);
});

void invalidateBaseballComboPicks(WidgetRef ref) {
  debugPrint('[BASEBALL] combo-picks provider invalidated — fetching fresh data');
  ref.invalidate(baseballComboPicksProvider);
}

class BaseballComboStatsView {
  const BaseballComboStatsView({
    required this.comboCount,
    required this.accuracy,
    required this.avgOdds,
    required this.avgConfidence,
    required this.safeRate,
    required this.highOddsRate,
    required this.safeRecord,
    required this.highOddsRecord,
    required this.leagues,
    required this.pendingCount,
    required this.settledCount,
    required this.partialCount,
    required this.winCount,
    required this.loseCount,
  });

  final int comboCount;
  final String accuracy;
  final String avgOdds;
  final String avgConfidence;
  final String safeRate;
  final String highOddsRate;
  final String safeRecord;
  final String highOddsRecord;
  final List<String> leagues;
  final int pendingCount;
  final int settledCount;
  final int partialCount;
  final int winCount;
  final int loseCount;

  static const empty = BaseballComboStatsView(
    comboCount: 0,
    accuracy: '-',
    avgOdds: '-',
    avgConfidence: '-',
    safeRate: '-',
    highOddsRate: '-',
    safeRecord: '-',
    highOddsRecord: '-',
    leagues: [],
    pendingCount: 0,
    settledCount: 0,
    partialCount: 0,
    winCount: 0,
    loseCount: 0,
  );

  String get displayComboCount => comboCount > 0 ? comboCount.toString() : '-';

  String get displayAccuracy => settledCount > 0 ? accuracy : '-';

  String get displayAvgOdds => comboCount > 0 ? avgOdds : '-';

  String get displaySubtitle =>
      comboCount > 0 ? '오늘 조합 $comboCount개' : '오늘의 AI 조합을 확인하세요.';

  String get resultStatusSummary {
    final parts = <String>[];
    if (pendingCount > 0) parts.add('$pendingCount개 진행 중');
    if (partialCount > 0) parts.add('$partialCount개 부분 적중');
    if (winCount > 0) parts.add('$winCount개 적중');
    if (loseCount > 0) parts.add('$loseCount개 미적중');
    return parts.join(' · ');
  }

  factory BaseballComboStatsView.fromResponse(Map<String, dynamic> response) {
    if (response.isEmpty) return BaseballComboStatsView.empty;

    final combos = _extractComboMaps(response);
    if (combos.isEmpty) return BaseballComboStatsView.empty;

    final comboCount = combos.length;

    final settled =
        combos.where((combo) => combo['result']?.toString() != 'pending').toList();
    final wins = combos.where((combo) => combo['result']?.toString() == 'win').length;
    final accuracyValue =
        settled.isNotEmpty ? (wins / settled.length * 100).round() : 0;

    final totalOddsList = combos
        .map((combo) => (combo['total_odds'] as num?)?.toDouble() ?? 0.0)
        .where((odds) => odds > 0)
        .toList();
    final avgOddsValue = totalOddsList.isNotEmpty
        ? totalOddsList.reduce((a, b) => a + b) / totalOddsList.length
        : 0.0;

    final confidenceList = combos
        .map((combo) => (combo['avg_confidence'] as num?)?.toDouble() ?? 0.0)
        .where((confidence) => confidence > 0)
        .toList();
    final avgConfidenceValue = confidenceList.isNotEmpty
        ? confidenceList.reduce((a, b) => a + b) / confidenceList.length
        : 0.0;

    final safeCombos =
        combos.where((combo) => combo['fold_count'] == 2).toList();
    final highOddsCombos =
        combos.where((combo) => combo['fold_count'] == 3).toList();

    final safeWins =
        safeCombos.where((combo) => combo['result']?.toString() == 'win').length;
    final safeSettled = safeCombos
        .where((combo) => combo['result']?.toString() != 'pending')
        .length;
    final safeRateValue =
        safeSettled > 0 ? (safeWins / safeSettled * 100).round() : 0;

    final highWins = highOddsCombos
        .where((combo) => combo['result']?.toString() == 'win')
        .length;
    final highSettled = highOddsCombos
        .where((combo) => combo['result']?.toString() != 'pending')
        .length;
    final highOddsRateValue =
        highSettled > 0 ? (highWins / highSettled * 100).round() : 0;

    final leagues = combos
        .map((combo) => combo['league']?.toString().trim() ?? '')
        .where((league) => league.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final pendingCount =
        combos.where((combo) => combo['result']?.toString() == 'pending').length;
    final partialCount =
        combos.where((combo) => combo['result']?.toString() == 'partial').length;
    final winCount =
        combos.where((combo) => combo['result']?.toString() == 'win').length;
    final loseCount =
        combos.where((combo) => combo['result']?.toString() == 'lose').length;

    return BaseballComboStatsView(
      comboCount: comboCount,
      accuracy: '$accuracyValue%',
      avgOdds: avgOddsValue.toStringAsFixed(2),
      avgConfidence: '${avgConfidenceValue.toStringAsFixed(1)}%',
      safeRate: '$safeRateValue%',
      highOddsRate: '$highOddsRateValue%',
      safeRecord: '$safeWins/$safeSettled',
      highOddsRecord: '$highWins/$highSettled',
      leagues: leagues,
      pendingCount: pendingCount,
      settledCount: settled.length,
      partialCount: partialCount,
      winCount: winCount,
      loseCount: loseCount,
    );
  }
}

List<Map<String, dynamic>> _extractComboMaps(Map<String, dynamic> response) {
  final picks = response['picks'];
  if (picks is List) {
    return picks
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  final data = response['data'];
  if (data is Map) {
    final nestedPicks = data['picks'];
    if (nestedPicks is List) {
      return nestedPicks
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }

  return const [];
}

final baseballComboStatsProvider =
    FutureProvider.autoDispose<BaseballComboStatsView>((ref) async {
  final raw =
      await ref.read(baseballComboServiceProvider).getTodayComboStats();
  return BaseballComboStatsView.fromResponse(raw);
});
