import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/services/fixture_service.dart';
import 'package:trendsoccer/core/utils/baseball_status.dart';

String fixtureDateString(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String fixtureTodayDateString() => fixtureDateString(DateTime.now());

/// Date chips: today − 2 through today + 3 (6 days).
List<DateTime> fixtureDateChipDates([DateTime? anchor]) {
  final today = anchor ?? DateTime.now();
  final todayDay = DateTime(today.year, today.month, today.day);
  return List.generate(6, (index) => todayDay.add(Duration(days: index - 2)));
}

bool matchIsOnDate(FixtureMatch match, String dateStr) {
  final local = match.matchTimestamp.toLocal();
  return fixtureDateString(local) == dateStr;
}

/// Baseball poll merge only: also match display date when timestamps differ.
bool _matchIsOnDateForBaseballMerge(FixtureMatch match, String dateStr) {
  if (matchIsOnDate(match, dateStr)) return true;

  final segments = dateStr.split('-');
  if (segments.length == 3) {
    final expectedDisplay =
        '${segments[1].padLeft(2, '0')}.${segments[2].padLeft(2, '0')}';
    if (match.matchDate == expectedDisplay) return true;
  }
  return false;
}

String _baseballFixtureMergeKey(FixtureMatch match) {
  if (match.matchId != 0) return 'mid:${match.matchId}';
  if (match.apiMatchId != null && match.apiMatchId != 0) {
    return 'api:${match.apiMatchId}';
  }
  return 'teams:${match.homeTeam}|${match.awayTeam}|'
      '${match.leagueKey}|${match.matchDate}|${match.matchTime}';
}

const _baseballMergeLeagueCodes = {'MLB', 'KBO', 'NPB', 'CPBL'};

bool _isBaseballMergeLeague(FixtureMatch match) =>
    _baseballMergeLeagueCodes.contains(match.leagueKey.toUpperCase());

bool _shouldReplaceInBaseballMerge(
  FixtureMatch match,
  Set<String> freshKeys,
  String todayStr,
) {
  if (!_isBaseballMergeLeague(match)) return false;
  final key = _baseballFixtureMergeKey(match);
  return freshKeys.contains(key) ||
      _matchIsOnDateForBaseballMerge(match, todayStr);
}

bool fixtureIsTodayDate(String dateStr) =>
    dateStr == fixtureTodayDateString();

String? _fixtureLogoOrFallback(String? preferred, String? fallback) {
  if (preferred != null && preferred.isNotEmpty) return preferred;
  return fallback;
}

LiveMatchData? _liveDataForFixture(
  FixtureMatch match,
  Map<String, LiveMatchData> liveMap,
) {
  final byMatchId = liveMap[match.matchId.toString()];
  if (byMatchId != null) return byMatchId;
  final apiMatchId = match.apiMatchId;
  if (apiMatchId != null) {
    return liveMap[apiMatchId.toString()];
  }
  return null;
}

/// Replaces today's matches in [existing] with [todayFresh] from a live poll.
List<FixtureMatch> mergeBaseballTodayFixtures(
  List<FixtureMatch> existing,
  List<FixtureMatch> todayFresh,
  String todayStr,
) {
  final freshKeys = todayFresh.map(_baseballFixtureMergeKey).toSet();

  final existingByKey = <String, FixtureMatch>{};
  for (final match in existing) {
    if (!_shouldReplaceInBaseballMerge(match, freshKeys, todayStr)) continue;
    existingByKey[_baseballFixtureMergeKey(match)] = match;
  }

  final todayFreshPreserved = todayFresh.map((fresh) {
    final prior = existingByKey[_baseballFixtureMergeKey(fresh)];
    if (prior == null) return fresh;
    return fresh.copyWith(
      homeTeamLogo:
          _fixtureLogoOrFallback(fresh.homeTeamLogo, prior.homeTeamLogo),
      awayTeamLogo:
          _fixtureLogoOrFallback(fresh.awayTeamLogo, prior.awayTeamLogo),
      leagueLogo: _fixtureLogoOrFallback(fresh.leagueLogo, prior.leagueLogo),
    );
  }).toList();

  final kept = existing
      .where((match) => !_shouldReplaceInBaseballMerge(match, freshKeys, todayStr))
      .toList();

  final merged = [...kept, ...todayFreshPreserved]
    ..sort((a, b) => a.matchTimestamp.compareTo(b.matchTimestamp));
  return merged;
}

/// Latest baseball fixture list after live polling; `null` uses [baseballFixturesProvider].
final baseballPolledFixturesProvider =
    StateProvider<List<FixtureMatch>?>((ref) => null);

/// Latest soccer fixture list after live FT patches; `null` uses [soccerFixturesProvider].
final soccerPolledFixturesProvider =
    StateProvider<List<FixtureMatch>?>((ref) => null);

List<FixtureMatch> mergeSoccerFinishedFromLive(
  List<FixtureMatch> existing,
  Map<String, LiveMatchData> liveMap,
) {
  if (liveMap.isEmpty) return existing;

  return existing.map((match) {
    final live = _liveDataForFixture(match, liveMap);
    if (live != null && live.isFinished) {
      return match.copyWithLive(live);
    }
    return match;
  }).toList();
}

class FixtureLeagueOption {
  const FixtureLeagueOption({
    required this.code,
    required this.name,
    this.nameEn,
    this.logo,
  });

  final String code;
  final String name;
  final String? nameEn;
  final String? logo;
}

final fixtureSelectedSportProvider =
    StateProvider<String>((ref) => 'soccer');

final fixtureSelectedDateProvider = StateProvider<String>(
  (ref) => fixtureTodayDateString(),
);

final fixtureLiveFilterProvider = StateProvider<bool>((ref) => false);

/// `null` = 전체.
final fixtureSelectedLeagueProvider = StateProvider<String?>((ref) => null);

final liveMatchesProvider =
    StateProvider<Map<String, LiveMatchData>>((ref) => {});

final soccerFixturesProvider =
    FutureProvider.autoDispose<List<FixtureMatch>>((ref) async {
  final service = ref.read(fixtureServiceProvider);
  return service.getSoccerFixtures();
});

final baseballFixturesProvider =
    FutureProvider.autoDispose<List<FixtureMatch>>((ref) async {
  final service = ref.read(fixtureServiceProvider);
  return service.getBaseballFixturesRange();
});

/// Lazily loaded baseball fixtures merged from per-date fetches (Fixture tab).
final baseballLazyFixturesProvider =
    StateProvider<List<FixtureMatch>>((ref) => []);

final baseballFixturesLoadingProvider = StateProvider<bool>((ref) => false);

void clearBaseballFixtureLazyCache(WidgetRef ref) {
  ref.read(baseballPolledFixturesProvider.notifier).state = null;
  ref.read(baseballLazyFixturesProvider.notifier).state = [];
  ref.read(baseballFixturesLoadingProvider.notifier).state = false;
}

final rawFixturesProvider = Provider<AsyncValue<List<FixtureMatch>>>((ref) {
  final sport = ref.watch(fixtureSelectedSportProvider);

  if (sport == 'baseball') {
    final polled = ref.watch(baseballPolledFixturesProvider);
    if (polled != null) {
      return AsyncValue.data(polled);
    }
    final lazy = ref.watch(baseballLazyFixturesProvider);
    final loading = ref.watch(baseballFixturesLoadingProvider);
    if (loading && lazy.isEmpty) {
      return const AsyncValue.loading();
    }
    return AsyncValue.data(lazy);
  }
  final polled = ref.watch(soccerPolledFixturesProvider);
  if (polled != null) {
    return AsyncValue.data(polled);
  }
  return ref.watch(soccerFixturesProvider);
});

List<FixtureMatch> _scopeMatchesForFilters(
  List<FixtureMatch> matches, {
  required String selectedDate,
  required bool liveFilter,
  required String sport,
  Map<String, LiveMatchData> liveMap = const {},
}) {
  var filtered = matches
      .where((match) => matchIsOnDate(match, selectedDate))
      .toList();

  if (!liveFilter) {
    return filtered;
  }

  if (sport == 'baseball') {
    return filtered
        .where(
          (match) =>
              BaseballStatus.isLive(match.rawStatus) ||
              BaseballStatus.isInterrupted(match.rawStatus),
        )
        .toList();
  }
  return filtered
      .where((match) {
        final live = _liveDataForFixture(match, liveMap);
        return live != null && live.isLive;
      })
      .toList();
}

List<FixtureMatch> _mergeFixturesWithLive(
  List<FixtureMatch> matches,
  Map<String, LiveMatchData> liveMap,
) {
  final logosByMatchId = <int, (String?, String?)>{
    for (final match in matches)
      if (match.matchId != 0)
        match.matchId: (match.homeTeamLogo, match.awayTeamLogo),
  };
  final logosByApiId = <int, (String?, String?)>{
    for (final match in matches)
      if (match.apiMatchId != null && match.apiMatchId != 0)
        match.apiMatchId!: (match.homeTeamLogo, match.awayTeamLogo),
  };

  final merged = <FixtureMatch>[];
  for (final match in matches) {
    final live = _liveDataForFixture(match, liveMap);
    var updated = live != null ? match.copyWithLive(live) : match;
    final catalog = logosByMatchId[match.matchId] ??
        (match.apiMatchId != null ? logosByApiId[match.apiMatchId] : null);
    if (catalog != null) {
      updated = updated.copyWith(
        homeTeamLogo:
            _fixtureLogoOrFallback(updated.homeTeamLogo, catalog.$1),
        awayTeamLogo:
            _fixtureLogoOrFallback(updated.awayTeamLogo, catalog.$2),
      );
    }
    merged.add(updated);
  }
  return merged;
}

List<FixtureMatch> _applyFixtureFilters({
  required List<FixtureMatch> matches,
  required String selectedDate,
  required bool liveFilter,
  required String sport,
  required Map<String, LiveMatchData> liveMap,
  String? selectedLeague,
}) {
  var filtered = _scopeMatchesForFilters(
    matches,
    selectedDate: selectedDate,
    liveFilter: liveFilter,
    sport: sport,
    liveMap: liveMap,
  );

  if (!liveFilter && selectedLeague != null && selectedLeague.isNotEmpty) {
    filtered = filtered
        .where((match) => match.leagueKey == selectedLeague)
        .toList();
  }

  return _mergeFixturesWithLive(filtered, liveMap);
}

final fixtureAvailableLeaguesProvider =
    Provider<List<FixtureLeagueOption>>((ref) {
  final selectedDate = ref.watch(fixtureSelectedDateProvider);
  final sport = ref.watch(fixtureSelectedSportProvider);
  final liveMap = ref.watch(liveMatchesProvider);

  return ref.watch(rawFixturesProvider).maybeWhen(
        data: (matches) => _extractLeagueOptions(
          _applyFixtureFilters(
            matches: matches,
            selectedDate: selectedDate,
            liveFilter: false,
            sport: sport,
            liveMap: liveMap,
          ),
        ),
        orElse: () => const [],
      );
});

List<FixtureLeagueOption> _extractLeagueOptions(List<FixtureMatch> matches) {
  final byCode = <String, FixtureLeagueOption>{};
  for (final match in matches) {
    if (match.leagueKey == 'unknown') continue;
    final existing = byCode[match.leagueKey];
    byCode[match.leagueKey] = FixtureLeagueOption(
      code: match.leagueKey,
      name: match.leagueName.isNotEmpty ? match.leagueName : match.leagueKey,
      nameEn: match.leagueNameEn ?? existing?.nameEn,
      logo: match.leagueLogo ?? existing?.logo,
    );
  }
  final options = byCode.values.toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return options;
}

final filteredFixturesProvider =
    Provider<AsyncValue<List<FixtureMatch>>>((ref) {
  final rawAsync = ref.watch(rawFixturesProvider);
  final selectedDate = ref.watch(fixtureSelectedDateProvider);
  final selectedLeague = ref.watch(fixtureSelectedLeagueProvider);
  final liveFilter = ref.watch(fixtureLiveFilterProvider);
  final sport = ref.watch(fixtureSelectedSportProvider);
  final liveMap = ref.watch(liveMatchesProvider);

  return rawAsync.whenData((matches) {
    final filtered = _applyFixtureFilters(
      matches: matches,
      selectedDate: selectedDate,
      liveFilter: liveFilter,
      sport: sport,
      liveMap: liveMap,
      selectedLeague: selectedLeague,
    );
    return filtered;
  });
});

final fixturesWithLiveProvider = filteredFixturesProvider;

final allFixturesWithLiveProvider =
    Provider<AsyncValue<List<FixtureMatch>>>((ref) {
  final rawAsync = ref.watch(rawFixturesProvider);
  final liveMap = ref.watch(liveMatchesProvider);

  return rawAsync.whenData((matches) {
    return _mergeFixturesWithLive(matches, liveMap);
  });
});

final fixtureLeagueGroupsProvider =
    Provider<AsyncValue<List<FixtureLeagueGroup>>>((ref) {
  return ref.watch(fixturesWithLiveProvider).whenData(groupMatchesByLeague);
});

void invalidateFixtureData(WidgetRef ref) {
  final sport = ref.read(fixtureSelectedSportProvider);

  if (sport == 'baseball') {
    clearBaseballFixtureLazyCache(ref);
  } else {
    ref.read(soccerPolledFixturesProvider.notifier).state = null;
    ref.invalidate(soccerFixturesProvider);
  }
}

String fixtureMatchTimeKst(FixtureMatch match) {
  final local = match.matchTimestamp.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}