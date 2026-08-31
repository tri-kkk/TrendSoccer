import 'package:flutter_test/flutter_test.dart';
import 'package:trendsoccer/core/models/soccer_h2h_analysis_parsed.dart';
import 'package:trendsoccer/core/models/soccer_team_stats_parsed.dart';

void main() {
  group('extended report parsers', () {
    test('formats blocks 06-09 from live-shaped payloads', () {
      final home = parseSoccerTeamStats({
        'data': {
          'markets': {
            'over25Rate': 0.62,
            'bttsRate': 0.58,
            'cleanSheetRate': 0.25,
            'scorelessRate': 0.15,
          },
          'recentForm': {
            'last10': {
              'wins': 5,
              'draws': 2,
              'losses': 3,
              'goalsFor': 14,
              'goalsAgainst': 11,
            },
          },
          'homeStats': {'wins': 7, 'draws': 2, 'losses': 1, 'winRate': 70},
          'awayStats': {'wins': 3, 'draws': 2, 'losses': 5, 'winRate': 38},
          'strengths': <String>[],
          'weaknesses': ['Vulnerable on the counter'],
        },
      });
      final away = parseSoccerTeamStats({
        'data': {
          'markets': {
            'over25Rate': 55,
            'bttsRate': 0.61,
            'cleanSheetRate': 30,
            'scorelessRate': 0.12,
          },
          'recentForm': {
            'last10': {
              'wins': 6,
              'draws': 1,
              'losses': 3,
              'goalsFor': 18,
              'goalsAgainst': 9,
            },
          },
          'homeStats': {'wins': 8, 'draws': 1, 'losses': 1, 'winRate': 80},
          'awayStats': {'wins': 4, 'draws': 3, 'losses': 3, 'winRate': 50},
          'strengths': ['Strong pressing', 'Clinical finishing'],
          'weaknesses': <String>[],
        },
      });

      expect(home.markets.over25Rate, closeTo(0.62, 0.001));
      expect(away.markets.bttsRate, closeTo(0.61, 0.001));
      expect(home.homeStats.winRate, 70);
      expect(home.homeStats.winRateFraction, closeTo(0.7, 0.001));
      expect(away.awayStats.winRate, 50);
      expect(away.awayStats.winRateFraction, closeTo(0.5, 0.001));

      final insights = mergeTeamInsights(home: home, away: away);
      expect(insights, hasLength(3));

      final h2h = parseSoccerH2HAnalysis({
        'data': {
          'overall': {'homeWins': 3, 'draws': 1, 'awayWins': 6},
          'recentMatches': List.generate(
            10,
            (i) => {
              'date': '2025-01-${i + 1}',
              'homeTeam': 'Aston Villa',
              'awayTeam': 'Arsenal',
              'homeScore': 1,
              'awayScore': 2,
            },
          ),
          'insights': ['Insight 1', 'Insight 2', 'Insight 3'],
        },
      });

      expect(h2h.overall.homeWins, 3);
      expect(h2h.recentMatches, hasLength(10));
      expect(h2h.insights, hasLength(3));
    });

    test('venue winRate is an integer percentage used as-is', () {
      final villa = parseSoccerTeamStats({
        'data': {
          'homeStats': {
            'played': 1,
            'wins': 1,
            'draws': 0,
            'losses': 0,
            'winRate': 100,
          },
        },
      });
      final arsenal = parseSoccerTeamStats({
        'data': {
          'awayStats': {
            'played': 1,
            'wins': 0,
            'draws': 0,
            'losses': 1,
            'winRate': 0,
          },
        },
      });

      expect(villa.homeStats.winRate, 100);
      expect(villa.homeStats.winRateFraction, closeTo(1.0, 0.001));
      expect(arsenal.awayStats.winRate, 0);
      expect(arsenal.awayStats.winRateFraction, isNull);
    });

    test('empty team-stats maps to empty parsed model', () {
      final parsed = parseSoccerTeamStats({});
      expect(parsed.hasMarketData, isFalse);
      expect(parsed.hasFormData, isFalse);
      expect(parsed.hasInsightData, isFalse);
    });
  });
}
