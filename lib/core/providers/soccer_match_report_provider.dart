import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';
import 'package:trendsoccer/core/models/soccer_h2h_analysis_parsed.dart';
import 'package:trendsoccer/core/models/soccer_team_stats_parsed.dart';
import 'package:trendsoccer/core/utils/error_resolver.dart';

const _soccerPredictionCacheDuration = Duration(seconds: 60);

/// Keeps an autoDispose provider alive for [_soccerPredictionCacheDuration] on
/// success; releases immediately on failure so errors are not cached.
Future<T> _keepAliveOnSuccessOnly<T>(Ref ref, Future<T> Function() fetch) async {
  final link = ref.keepAlive();
  Timer? timer;
  try {
    final result = await fetch();
    timer = Timer(_soccerPredictionCacheDuration, link.close);
    ref.onDispose(timer.cancel);
    return result;
  } on Object {
    timer?.cancel();
    link.close();
    rethrow;
  }
}

/// True when every report section has failed with a transport error and none
/// have data — a total outage, not a partial endpoint failure.
bool soccerReportHasTotalTransportFailure(List<AsyncValue<dynamic>> sections) {
  if (sections.any((section) => section.hasValue)) return false;
  if (sections.any((section) => section.isLoading)) return false;
  if (!sections.every((section) => section.hasError)) return false;
  return sections.every((section) => isTransportFailure(section.error));
}

Object? soccerReportTransportFailureError(List<AsyncValue<dynamic>> sections) {
  for (final section in sections) {
    if (section.hasError && isTransportFailure(section.error)) {
      return section.error;
    }
  }
  return null;
}

final soccerReportScreenFailureProvider =
    Provider.autoDispose.family<bool, SoccerAnalysisParams>((ref, params) {
  return soccerReportHasTotalTransportFailure([
    ref.watch(soccerPredictionProvider(params)),
    ref.watch(homeTeamStatsProvider(params)),
    ref.watch(awayTeamStatsProvider(params)),
    ref.watch(soccerH2HAnalysisProvider(params)),
  ]);
});

final soccerReportTransportFailureErrorProvider =
    Provider.autoDispose.family<Object?, SoccerAnalysisParams>((ref, params) {
  return soccerReportTransportFailureError([
    ref.watch(soccerPredictionProvider(params)),
    ref.watch(homeTeamStatsProvider(params)),
    ref.watch(awayTeamStatsProvider(params)),
    ref.watch(soccerH2HAnalysisProvider(params)),
  ]);
});

class SoccerAnalysisParams {
  const SoccerAnalysisParams({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.leagueCode,
    this.homeTeamId,
    this.awayTeamId,
    this.homeOdds,
    this.drawOdds,
    this.awayOdds,
    this.commenceTime,
  });

  final int matchId;
  final String homeTeam;
  final String awayTeam;
  final String leagueCode;
  final int? homeTeamId;
  final int? awayTeamId;
  final double? homeOdds;
  final double? drawOdds;
  final double? awayOdds;
  final String? commenceTime;

  factory SoccerAnalysisParams.fromHeader(MatchHeaderData header) {
    return SoccerAnalysisParams(
      matchId: header.matchId,
      homeTeam: header.homeTeam,
      awayTeam: header.awayTeam,
      leagueCode: header.leagueCode?.trim().toUpperCase() ?? '',
      homeTeamId: header.homeTeamId,
      awayTeamId: header.awayTeamId,
      homeOdds: header.homeOdds,
      drawOdds: header.drawOdds,
      awayOdds: header.awayOdds,
      commenceTime: header.commenceTime,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SoccerAnalysisParams &&
            matchId == other.matchId &&
            homeTeam == other.homeTeam &&
            awayTeam == other.awayTeam &&
            leagueCode == other.leagueCode &&
            homeTeamId == other.homeTeamId &&
            awayTeamId == other.awayTeamId &&
            homeOdds == other.homeOdds &&
            drawOdds == other.drawOdds &&
            awayOdds == other.awayOdds &&
            commenceTime == other.commenceTime;
  }

  @override
  int get hashCode => Object.hash(
        matchId,
        homeTeam,
        awayTeam,
        leagueCode,
        homeTeamId,
        awayTeamId,
        homeOdds,
        drawOdds,
        awayOdds,
        commenceTime,
      );
}

final soccerPredictionProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, SoccerAnalysisParams>((ref, params) async {
  final homeTeamId = params.homeTeamId;
  final awayTeamId = params.awayTeamId;
  final homeOdds = params.homeOdds;
  final drawOdds = params.drawOdds;
  final awayOdds = params.awayOdds;

  if (homeTeamId == null ||
      awayTeamId == null ||
      params.leagueCode.isEmpty ||
      homeOdds == null ||
      drawOdds == null ||
      awayOdds == null) {
    throw StateError('Missing metadata for predict-v2 request');
  }

  return _keepAliveOnSuccessOnly(
    ref,
    () => ref.read(soccerServiceProvider).getMatchPrediction(
          homeTeam: params.homeTeam,
          awayTeam: params.awayTeam,
          homeTeamId: homeTeamId,
          awayTeamId: awayTeamId,
          leagueCode: params.leagueCode,
          homeOdds: homeOdds,
          drawOdds: drawOdds,
          awayOdds: awayOdds,
          matchId: params.matchId,
          commenceTime: params.commenceTime,
        ),
  );
});

final soccerH2HProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, SoccerAnalysisParams>((ref, params) async {
  final homeTeamId = params.homeTeamId;
  final awayTeamId = params.awayTeamId;
  if (homeTeamId == null || awayTeamId == null) {
    throw StateError('Missing team IDs for H2H lookup');
  }
  return ref.read(soccerServiceProvider).getMatchH2H(
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
      );
});

final soccerH2HAnalysisProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, SoccerAnalysisParams>((ref, params) async {
  ref.watch(soccerPredictionProvider(params));
  return ref.read(soccerServiceProvider).getMatchH2HAnalysis(
        homeTeam: params.homeTeam,
        awayTeam: params.awayTeam,
      );
});

final homeTeamStatsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, SoccerAnalysisParams>((ref, params) async {
  ref.watch(soccerPredictionProvider(params));
  final teamId = params.homeTeamId;
  if (teamId == null || params.leagueCode.isEmpty) {
    return {};
  }
  return ref.read(soccerServiceProvider).getTeamStats(
        teamName: params.homeTeam,
        leagueCode: params.leagueCode,
        teamId: teamId,
      );
});

final awayTeamStatsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, SoccerAnalysisParams>((ref, params) async {
  ref.watch(soccerPredictionProvider(params));
  final teamId = params.awayTeamId;
  if (teamId == null || params.leagueCode.isEmpty) {
    return {};
  }
  return ref.read(soccerServiceProvider).getTeamStats(
        teamName: params.awayTeam,
        leagueCode: params.leagueCode,
        teamId: teamId,
      );
});

/// Every [FutureProvider.autoDispose.family] the soccer match report screen
/// fetches. Add new report endpoints here and in [invalidateSoccerMatchReport].
void invalidateSoccerMatchReport(WidgetRef ref, SoccerAnalysisParams params) {
  ref.invalidate(soccerPredictionProvider(params));
  ref.invalidate(homeTeamStatsProvider(params));
  ref.invalidate(awayTeamStatsProvider(params));
  ref.invalidate(soccerH2HAnalysisProvider(params));
}

Future<void> waitForSoccerMatchReport(WidgetRef ref, SoccerAnalysisParams params) {
  return Future.wait<void>([
    ref.read(soccerPredictionProvider(params).future),
    ref.read(homeTeamStatsProvider(params).future),
    ref.read(awayTeamStatsProvider(params).future),
    ref.read(soccerH2HAnalysisProvider(params).future),
  ]);
}

Future<void> refreshSoccerMatchReport(WidgetRef ref, SoccerAnalysisParams params) async {
  invalidateSoccerMatchReport(ref, params);
  try {
    await waitForSoccerMatchReport(ref, params);
  } on Object {
    // RefreshIndicator must complete normally; failure UI comes from provider state.
  }
}

void invalidateTeamStatsProviders(WidgetRef ref, SoccerAnalysisParams params) {
  ref.invalidate(homeTeamStatsProvider(params));
  ref.invalidate(awayTeamStatsProvider(params));
}

Future<void> waitForTeamStatsProviders(WidgetRef ref, SoccerAnalysisParams params) {
  return Future.wait<void>([
    ref.read(homeTeamStatsProvider(params).future),
    ref.read(awayTeamStatsProvider(params).future),
  ]);
}

Future<void> refreshTeamStatsProviders(WidgetRef ref, SoccerAnalysisParams params) async {
  invalidateTeamStatsProviders(ref, params);
  try {
    await waitForTeamStatsProviders(ref, params);
  } on Object {
    // Retry boundary must complete normally; failure UI comes from provider state.
  }
}

Future<void> refreshH2HAnalysis(WidgetRef ref, SoccerAnalysisParams params) async {
  ref.invalidate(soccerH2HAnalysisProvider(params));
  try {
    await ref.read(soccerH2HAnalysisProvider(params).future);
  } on Object {
    // Retry boundary must complete normally; failure UI comes from provider state.
  }
}

Future<void> refreshPrediction(WidgetRef ref, SoccerAnalysisParams params) async {
  ref.invalidate(soccerPredictionProvider(params));
  try {
    await ref.read(soccerPredictionProvider(params).future);
  } on Object {
    // Retry boundary must complete normally; failure UI comes from provider state.
  }
}

class MatchReportRetryButton {
  const MatchReportRetryButton({
    required this.inProgress,
    required this.onPressed,
  });

  final bool inProgress;
  final void Function() onPressed;

  String get label => inProgress ? 'Retrying…' : 'Retry';
  void Function()? get action => inProgress ? null : onPressed;
}

final homeTeamStatsParsedProvider = Provider.autoDispose
    .family<AsyncValue<SoccerTeamStatsParsed>, SoccerAnalysisParams>(
  (ref, params) {
    return ref
        .watch(homeTeamStatsProvider(params))
        .whenData(parseSoccerTeamStats);
  },
);

final awayTeamStatsParsedProvider = Provider.autoDispose
    .family<AsyncValue<SoccerTeamStatsParsed>, SoccerAnalysisParams>(
  (ref, params) {
    return ref
        .watch(awayTeamStatsProvider(params))
        .whenData(parseSoccerTeamStats);
  },
);

final soccerH2HAnalysisParsedProvider = Provider.autoDispose
    .family<AsyncValue<SoccerH2HAnalysisParsed>, SoccerAnalysisParams>(
  (ref, params) {
    return ref
        .watch(soccerH2HAnalysisProvider(params))
        .whenData(parseSoccerH2HAnalysis);
  },
);
