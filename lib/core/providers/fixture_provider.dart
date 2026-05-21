import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:trendsoccer/core/models/fixture_models_v2.dart';
import 'package:trendsoccer/core/services/fixture_service.dart';

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

final soccerFixturesProvider =
    FutureProvider.autoDispose<List<FixtureMatch>>((ref) async {
  final service = ref.read(fixtureServiceProvider);
  return service.getSoccerFixtures();
});

final baseballFixturesProvider =
    FutureProvider.family<List<FixtureMatch>, String>((ref, date) async {
  final service = ref.read(fixtureServiceProvider);
  return service.getBaseballFixtures(date: date);
});

final liveFixturesProvider =
    FutureProvider.autoDispose<List<FixtureMatch>>((ref) async {
  final service = ref.read(fixtureServiceProvider);
  return service.getLiveMatches();
});

final rawFixturesProvider = Provider<AsyncValue<List<FixtureMatch>>>((ref) {
  final sport = ref.watch(fixtureSelectedSportProvider);

  if (sport == 'baseball') {
    final date = ref.watch(fixtureSelectedDateProvider);
    return ref.watch(baseballFixturesProvider(date));
  }
  return ref.watch(soccerFixturesProvider);
});

List<FixtureMatch> _scopeMatchesForFilters(
  List<FixtureMatch> matches, {
  required String sport,
  required String selectedDate,
  required bool liveFilter,
}) {
  if (liveFilter) {
    return matches.where((match) => match.status == 'live').toList();
  }
  if (sport == 'soccer') {
    return matches
        .where((match) => matchIsOnDate(match, selectedDate))
        .toList();
  }
  return matches;
}

final fixtureAvailableLeaguesProvider =
    Provider<List<FixtureLeagueOption>>((ref) {
  final sport = ref.watch(fixtureSelectedSportProvider);
  final selectedDate = ref.watch(fixtureSelectedDateProvider);
  final liveFilter = ref.watch(fixtureLiveFilterProvider);

  return ref.watch(rawFixturesProvider).maybeWhen(
        data: (matches) => _extractLeagueOptions(
          _scopeMatchesForFilters(
            matches,
            sport: sport,
            selectedDate: selectedDate,
            liveFilter: liveFilter,
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
  final sport = ref.watch(fixtureSelectedSportProvider);
  final selectedDate = ref.watch(fixtureSelectedDateProvider);
  final selectedLeague = ref.watch(fixtureSelectedLeagueProvider);
  final liveFilter = ref.watch(fixtureLiveFilterProvider);

  return rawAsync.whenData((matches) {
    var filtered = _scopeMatchesForFilters(
      matches,
      sport: sport,
      selectedDate: selectedDate,
      liveFilter: liveFilter,
    );

    if (selectedLeague != null && selectedLeague.isNotEmpty) {
      filtered = filtered
          .where((match) => match.leagueKey == selectedLeague)
          .toList();
    }

    return filtered;
  });
});

final fixtureLeagueGroupsProvider =
    Provider<AsyncValue<List<FixtureLeagueGroup>>>((ref) {
  return ref.watch(filteredFixturesProvider).whenData(groupMatchesByLeague);
});

void invalidateFixtureData(WidgetRef ref) {
  final sport = ref.read(fixtureSelectedSportProvider);
  final date = ref.read(fixtureSelectedDateProvider);

  if (sport == 'baseball') {
    ref.invalidate(baseballFixturesProvider(date));
  } else {
    ref.invalidate(soccerFixturesProvider);
  }
}

String fixtureMatchTimeKst(FixtureMatch match) {
  final local = match.matchTimestamp.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
