import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/providers/baseball_combo_provider.dart';
import 'package:trendsoccer/core/services/baseball_combo_service.dart';
import 'package:trendsoccer/core/services/baseball_service.dart';

/// Fixed display order for home combo league cells (MLB · KBO · NPB).
const homeComboLeagueOrder = ['MLB', 'KBO', 'NPB'];

class HomeComboLeagueCount {
  const HomeComboLeagueCount({
    required this.leagueCode,
    required this.count,
  });

  final String leagueCode;
  final int count;
}

class HomeComboSummary {
  const HomeComboSummary({
    required this.comboCount,
    required this.leagueCounts,
    required this.stableCount,
    required this.aggressiveCount,
    required this.accuracyLabel,
  });

  final int comboCount;
  final List<HomeComboLeagueCount> leagueCounts;
  final int stableCount;
  final int aggressiveCount;
  final String accuracyLabel;

  double get stableFraction {
    final total = stableCount + aggressiveCount;
    if (total == 0) return 0.0;
    return stableCount / total;
  }
}

/// Home block 06: today's combo counts/split plus 14-day accuracy.
final homeComboSummaryProvider = FutureProvider<HomeComboSummary>((ref) async {
  final comboService = ref.read(baseballComboServiceProvider);
  final baseballService = ref.read(baseballServiceProvider);

  final results = await Future.wait([
    comboService.getTodayComboStats(),
    baseballService.getBaseballComboPicks(days: 14),
  ]);

  final todayPicks = extractHomeComboMaps(results[0]);
  final accuracy =
      BaseballComboStatsView.fromResponse(results[1]).displayAccuracy;

  final countsByLeague = <String, int>{};
  var stableCount = 0;
  var aggressiveCount = 0;

  for (final combo in todayPicks) {
    final league = combo['league']?.toString().trim().toUpperCase() ?? '';
    if (league.isNotEmpty) {
      countsByLeague[league] = (countsByLeague[league] ?? 0) + 1;
    }

    final foldCount = _foldCount(combo['fold_count']);
    if (foldCount != null) {
      if (foldCount <= 2) {
        stableCount++;
      } else {
        aggressiveCount++;
      }
    }
  }

  final leagueCounts = [
    for (final league in homeComboLeagueOrder)
      HomeComboLeagueCount(
        leagueCode: league,
        count: countsByLeague[league] ?? 0,
      ),
  ];

  return HomeComboSummary(
    comboCount: todayPicks.length,
    leagueCounts: leagueCounts,
    stableCount: stableCount,
    aggressiveCount: aggressiveCount,
    accuracyLabel: _accuracyLabel(accuracy),
  );
});

String _accuracyLabel(String displayAccuracy) {
  if (displayAccuracy == '-') return 'Accuracy not available yet';
  return '$displayAccuracy accuracy · last 14 days';
}

int? _foldCount(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw.trim());
  return null;
}

/// Same pick extraction as [_extractComboMaps] in [baseball_combo_provider.dart].
List<Map<String, dynamic>> extractHomeComboMaps(Map<String, dynamic> response) {
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
