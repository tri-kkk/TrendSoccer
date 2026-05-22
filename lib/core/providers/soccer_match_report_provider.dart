import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';

class SoccerAnalysisParams {
  const SoccerAnalysisParams({
    required this.matchId,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.time,
    this.homeTeamId,
    this.awayTeamId,
  });

  final int matchId;
  final String league;
  final String homeTeam;
  final String awayTeam;
  final String date;
  final String time;
  final int? homeTeamId;
  final int? awayTeamId;

  factory SoccerAnalysisParams.fromHeader(MatchHeaderData header) {
    return SoccerAnalysisParams(
      matchId: header.matchId,
      league: header.apiLeagueName,
      homeTeam: header.homeTeam,
      awayTeam: header.awayTeam,
      date: header.apiDate,
      time: header.apiTime,
      homeTeamId: header.homeTeamId,
      awayTeamId: header.awayTeamId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SoccerAnalysisParams &&
            matchId == other.matchId &&
            league == other.league &&
            homeTeam == other.homeTeam &&
            awayTeam == other.awayTeam &&
            date == other.date &&
            time == other.time &&
            homeTeamId == other.homeTeamId &&
            awayTeamId == other.awayTeamId;
  }

  @override
  int get hashCode => Object.hash(
        matchId,
        league,
        homeTeam,
        awayTeam,
        date,
        time,
        homeTeamId,
        awayTeamId,
      );
}

final soccerAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, SoccerAnalysisParams>(
        (ref, params) async {
  return ref.read(soccerServiceProvider).getMatchAnalysis(
        league: params.league,
        homeTeam: params.homeTeam,
        awayTeam: params.awayTeam,
        date: params.date,
        time: params.time,
      );
});

final soccerH2HProvider =
    FutureProvider.family<Map<String, dynamic>, SoccerAnalysisParams>(
        (ref, params) async {
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

final soccerH2HAnalysisProvider =
    FutureProvider.family<Map<String, dynamic>, SoccerAnalysisParams>(
        (ref, params) async {
  return ref.read(soccerServiceProvider).getMatchH2HAnalysis(
        homeTeam: params.homeTeam,
        awayTeam: params.awayTeam,
      );
});
