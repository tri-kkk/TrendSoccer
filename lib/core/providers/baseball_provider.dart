import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:trendsoccer/core/models/baseball_models.dart';
import 'package:trendsoccer/core/services/baseball_service.dart';

/// Hardcoded baseball analysis league chips (fixed order).
class BaseballAnalysisLeagueChip {
  const BaseballAnalysisLeagueChip({
    required this.id,
    required this.label,
    required this.labelEn,
    this.code,
    this.iconId,
  });

  final String id;
  final String label;
  final String labelEn;
  final String? code;
  final String? iconId;

  bool get isAll => code == null;

  String get displayLabel => label;
}

const baseballAnalysisLeagueChips = [
  BaseballAnalysisLeagueChip(
    id: 'all',
    label: '전체',
    labelEn: 'All',
  ),
  BaseballAnalysisLeagueChip(
    id: 'kbo',
    label: 'KBO',
    labelEn: 'KBO',
    code: 'KBO',
    iconId: 'kbo',
  ),
  BaseballAnalysisLeagueChip(
    id: 'mlb',
    label: 'MLB',
    labelEn: 'MLB',
    code: 'MLB',
    iconId: 'mlb',
  ),
  BaseballAnalysisLeagueChip(
    id: 'npb',
    label: 'NPB',
    labelEn: 'NPB',
    code: 'NPB',
    iconId: 'npb',
  ),
  BaseballAnalysisLeagueChip(
    id: 'cpbl',
    label: 'CPBL',
    labelEn: 'CPBL',
    code: 'CPBL',
    iconId: 'cpbl',
  ),
];

final selectedBaseballLeagueProvider = StateProvider<String?>((ref) => null);

String baseballDateString(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String baseballTodayDateString() => baseballDateString(DateTime.now());

List<DateTime> baseballAnalysisDateTimes() {
  final today = DateTime.now();
  final todayDay = DateTime(today.year, today.month, today.day);
  return List.generate(3, (index) => todayDay.add(Duration(days: index)));
}

final baseballAnalysisDateProvider = StateProvider<String>(
  (ref) => baseballTodayDateString(),
);

final baseballAnalysisDatesProvider = Provider<List<String>>((ref) {
  return baseballAnalysisDateTimes().map(baseballDateString).toList();
});

bool baseballMatchIsOnDate(BaseballAnalysisCard card, String dateStr) {
  final local = card.matchTimestamp.toLocal();
  return baseballDateString(local) == dateStr;
}

final baseballAnalysisMatchesProvider =
    FutureProvider.autoDispose<List<BaseballAnalysisCard>>((ref) async {
  final service = ref.read(baseballServiceProvider);
  final dates = ref.watch(baseballAnalysisDatesProvider);
  final results = await Future.wait(
    dates.map((date) => service.getMatches(date: date)),
  );

  final byId = <int, BaseballAnalysisCard>{};
  for (final dayMatches in results) {
    for (final match in dayMatches) {
      if (match.matchId == 0) continue;
      if (_isFinishedBaseballStatus(match.status)) continue;
      if (!baseballMatchHasNotStarted(match)) continue;
      byId[match.matchId] = match;
    }
  }

  final merged = byId.values.toList()
    ..sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));
  return merged;
});

bool _isFinishedBaseballStatus(String status) {
  final normalized = status.trim().toUpperCase();
  return normalized == 'FT' ||
      normalized == 'FINISHED' ||
      normalized == 'FIN' ||
      normalized == 'FINISH';
}

/// Hides cards whose scheduled start time has passed (still NS / not finished).
bool baseballMatchHasNotStarted(BaseballAnalysisCard card) {
  if (_isFinishedBaseballStatus(card.status)) return false;
  return card.matchTimestamp.toLocal().isAfter(DateTime.now());
}

final filteredBaseballAnalysisProvider =
    Provider<AsyncValue<List<BaseballAnalysisCard>>>((ref) {
  final matchesAsync = ref.watch(baseballAnalysisMatchesProvider);
  final selectedLeague = ref.watch(selectedBaseballLeagueProvider);
  final selectedDate = ref.watch(baseballAnalysisDateProvider);

  return matchesAsync.whenData((matches) {
    var filtered = matches
        .where(baseballMatchHasNotStarted)
        .where((match) => baseballMatchIsOnDate(match, selectedDate))
        .toList();
    if (selectedLeague != null && selectedLeague.isNotEmpty) {
      final code = selectedLeague.toUpperCase();
      filtered =
          filtered.where((match) => match.league.toUpperCase() == code).toList();
    }
    return filtered;
  });
});

List<BaseballAnalysisCard> filterBaseballAnalysisMatches({
  required List<BaseballAnalysisCard> matches,
  required String dateStr,
  String? selectedLeague,
}) {
  var filtered = matches
      .where(baseballMatchHasNotStarted)
      .where((match) => baseballMatchIsOnDate(match, dateStr))
      .toList();
  if (selectedLeague != null && selectedLeague.isNotEmpty) {
    final code = selectedLeague.toUpperCase();
    filtered =
        filtered.where((match) => match.league.toUpperCase() == code).toList();
  }
  return filtered;
}

String baseballLeagueIconId(String league) {
  final upper = league.trim().toUpperCase();
  for (final chip in baseballAnalysisLeagueChips) {
    if (chip.code?.toUpperCase() == upper && chip.iconId != null) {
      return chip.iconId!;
    }
  }
  return upper.toLowerCase();
}

String formatBaseballCardDate(BaseballAnalysisCard card) {
  final parsed = DateTime.tryParse(card.matchDate);
  if (parsed != null) {
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '$month.$day';
  }
  final local = card.matchTimestamp.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$month.$day';
}

String formatBaseballMatchTimeKst(BaseballAnalysisCard card) {
  final local = card.matchTimestamp.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

bool baseballMatchIsToday(BaseballAnalysisCard card) {
  final local = card.matchTimestamp.toLocal();
  final today = DateTime.now();
  return local.year == today.year &&
      local.month == today.month &&
      local.day == today.day;
}
