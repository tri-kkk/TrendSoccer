import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/match_header_data.dart';
import 'package:trendsoccer/core/services/soccer_service.dart';

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

final soccerPredictionProvider =
    FutureProvider.family<Map<String, dynamic>, SoccerAnalysisParams>(
        (ref, params) async {
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

  return ref.read(soccerServiceProvider).getMatchPrediction(
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

final homeTeamStatsProvider =
    FutureProvider.family<Map<String, dynamic>, SoccerAnalysisParams>(
        (ref, params) async {
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

final awayTeamStatsProvider =
    FutureProvider.family<Map<String, dynamic>, SoccerAnalysisParams>(
        (ref, params) async {
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
