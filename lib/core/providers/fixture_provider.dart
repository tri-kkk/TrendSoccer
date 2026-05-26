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

class FixtureLeagueOption {
  const FixtureLeagueOption({
    required this.code,
    required this.name,
    this.logo,
  });

  final String code;
  final String name;
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

final rawFixturesProvider = Provider<AsyncValue<List<FixtureMatch>>>((ref) {
  final sport = ref.watch(fixtureSelectedSportProvider);

  if (sport == 'baseball') {
    return ref.watch(baseballFixturesProvider);
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
  if (liveFilter) {
    if (sport == 'baseball') {
      return matches
          .where(
            (match) =>
                BaseballStatus.isLive(match.rawStatus) ||
                BaseballStatus.isInterrupted(match.rawStatus),
          )
          .toList();
    }
    return matches
        .where((match) {
          final live = liveMap[match.matchId.toString()];
          return live != null && live.isLive;
        })
        .toList();
  }
  return matches
      .where((match) => matchIsOnDate(match, selectedDate))
      .toList();
}

List<FixtureMatch> _mergeFixturesWithLive(
  List<FixtureMatch> matches,
  Map<String, LiveMatchData> liveMap,
) {
  final merged = <FixtureMatch>[];
  for (final match in matches) {
    final live = liveMap[match.matchId.toString()];
    merged.add(live != null ? match.copyWithLive(live) : match);
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

  if (selectedLeague != null && selectedLeague.isNotEmpty) {
    filtered = filtered
        .where((match) => match.leagueKey == selectedLeague)
        .toList();
  }

  return _mergeFixturesWithLive(filtered, liveMap);
}

final fixtureAvailableLeaguesProvider =
    Provider<List<FixtureLeagueOption>>((ref) {
  final selectedDate = ref.watch(fixtureSelectedDateProvider);
  final liveFilter = ref.watch(fixtureLiveFilterProvider);
  final sport = ref.watch(fixtureSelectedSportProvider);
  final liveMap = ref.watch(liveMatchesProvider);

  return ref.watch(rawFixturesProvider).maybeWhen(
        data: (matches) => _extractLeagueOptions(
          _applyFixtureFilters(
            matches: matches,
            selectedDate: selectedDate,
            liveFilter: liveFilter,
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
    byCode[match.leagueKey] = FixtureLeagueOption(
      code: match.leagueKey,
      name: match.leagueName.isNotEmpty ? match.leagueName : match.leagueKey,
      logo: match.leagueLogo,
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
    return _applyFixtureFilters(
      matches: matches,
      selectedDate: selectedDate,
      liveFilter: liveFilter,
      sport: sport,
      liveMap: liveMap,
      selectedLeague: selectedLeague,
    );
  });
});

final fixturesWithLiveProvider = filteredFixturesProvider;

final allFixturesWithLiveProvider =
    Provider<AsyncValue<List<FixtureMatch>>>((ref) {
  final rawAsync = ref.watch(rawFixturesProvider);
  final liveMap = ref.watch(liveMatchesProvider);

  return rawAsync.whenData(
    (matches) => _mergeFixturesWithLive(matches, liveMap),
  );
});

final fixtureLeagueGroupsProvider =
    Provider<AsyncValue<List<FixtureLeagueGroup>>>((ref) {
  return ref.watch(fixturesWithLiveProvider).whenData(groupMatchesByLeague);
});

void invalidateFixtureData(WidgetRef ref) {
  final sport = ref.read(fixtureSelectedSportProvider);

  if (sport == 'baseball') {
    ref.invalidate(baseballFixturesProvider);
  } else {
    ref.invalidate(soccerFixturesProvider);
  }
}

String fixtureMatchTimeKst(FixtureMatch match) {
  final local = match.matchTimestamp.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}