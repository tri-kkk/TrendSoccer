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

final baseballAnalysisMatchesProvider =
    FutureProvider.autoDispose<List<BaseballAnalysisCard>>((ref) async {
  final service = ref.read(baseballServiceProvider);
  final matches = await service.getUpcomingMatches();
  return matches.where((match) => !_isFinishedBaseballStatus(match.status)).toList();
});

bool _isFinishedBaseballStatus(String status) {
  final normalized = status.trim().toUpperCase();
  return normalized == 'FT' ||
      normalized == 'FINISHED' ||
      normalized == 'FIN' ||
      normalized == 'FINISH';
}

final filteredBaseballAnalysisProvider =
    Provider<AsyncValue<List<BaseballAnalysisCard>>>((ref) {
  final matchesAsync = ref.watch(baseballAnalysisMatchesProvider);
  final selectedLeague = ref.watch(selectedBaseballLeagueProvider);

  return matchesAsync.whenData((matches) {
    if (selectedLeague == null || selectedLeague.isEmpty) return matches;
    final code = selectedLeague.toUpperCase();
    return matches
        .where((match) => match.league.toUpperCase() == code)
        .toList();
  });
});

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
