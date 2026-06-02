import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/soccer_models.dart';
import 'package:trendsoccer/core/services/web_api_client.dart';

final soccerServiceProvider = Provider<SoccerService>((ref) {
  return SoccerService(ref.watch(webDioProvider));
});

class SoccerService {
  SoccerService(this._dio);

  final Dio _dio;

  static const _analysisTimeout = Duration(seconds: 20);

  static const Map<String, int> leagueIdMap = {
    'PL': 39,
    'PD': 140,
    'BL1': 78,
    'SA': 135,
    'FL1': 61,
    'PPL': 94,
    'DED': 88,
    'CL': 2,
    'UCL': 2,
    'EL': 3,
    'UEL': 3,
    'WC': 1,
    'ELC': 40,
    'KL': 292,
    'KL1': 292,
    'KL2': 293,
    'J1': 98,
    'MLS': 253,
  };

  static const analysisLeagueCodes = [
    'PL', // EPL (Premier League)
    'PD', // La Liga
    'BL1', // Bundesliga
    'SA', // Serie A
    'FL1', // Ligue 1
    'DED', // Eredivisie
    'MLS', // MLS
    'KL', // K League
    'KL1', // K League 1 (alternate code)
    'KL2', // K League 2
    'J1', // J League
    'UCL', // Champions League
    'UEL', // Europa League
    'CL', // Champions League (alternate)
    'EL', // Europa League (alternate)
  ];

  static final Set<String> _analysisLeagueCodeSet =
      analysisLeagueCodes.map((code) => code.toUpperCase()).toSet();

  // TODO: Replace with /api/v1/mobile/soccer/matches when available
  Future<List<SoccerAnalysisCard>> getMatches({
    String? date,
    String? league,
  }) async {
    debugPrint('[SOCCER] getMatches called with date: $date');
    try {
      final queryParameters = <String, String>{};
      if (date != null && date.isNotEmpty) {
        queryParameters['date'] = date;
      }
      final response = await _dio.get<dynamic>(
        '/api/odds-from-db',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final raw = response.data;
      debugPrint('[SOCCER] Raw response type: ${raw.runtimeType}');
      if (raw is Map) {
        debugPrint('[SOCCER] Raw response keys: ${raw.keys.toList()}');
      } else {
        debugPrint('[SOCCER] Raw response keys: not a map');
      }
      if (raw is Map && raw.containsKey('data')) {
        debugPrint('[SOCCER] data is List: ${raw['data'] is List}');
        debugPrint('[SOCCER] data length: ${(raw['data'] as List?)?.length}');
        if (raw['data'] is List && (raw['data'] as List).isNotEmpty) {
          final first = (raw['data'] as List).first;
          if (first is Map) {
            debugPrint('[SOCCER] First item keys: ${first.keys.toList()}');
            debugPrint(
              '[SOCCER] First item sample: home_team=${first['home_team']}, away_team=${first['away_team']}',
            );
          }
        }
      }
      if (raw is List) {
        debugPrint('[SOCCER] Response is direct List, length: ${raw.length}');
        if (raw.isNotEmpty && raw.first is Map) {
          debugPrint('[SOCCER] First item keys: ${(raw.first as Map).keys.toList()}');
        }
      }
      final cards = _filterAnalysisLeagueCards(_adaptToAnalysisCards(raw));
      if (league == null || league.isEmpty) return cards;
      return cards.where((card) => _matchesLeague(card, league)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getMatchPrediction({
    required String homeTeam,
    required String awayTeam,
    required int homeTeamId,
    required int awayTeamId,
    required String leagueCode,
    required double homeOdds,
    required double drawOdds,
    required double awayOdds,
    int? matchId,
    String? commenceTime,
  }) async {
    debugPrint('[SOCCER] POST /api/predict-v2 for $homeTeam vs $awayTeam');
    final normalizedCode = leagueCode.trim().toUpperCase();
    debugPrint(
      '[SOCCER] predict-v2 request body: matchId=$matchId, leagueCode=$normalizedCode, odds={home:$homeOdds, draw:$drawOdds, away:$awayOdds}',
    );
    try {
      final body = <String, dynamic>{
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'homeTeamId': homeTeamId,
        'awayTeamId': awayTeamId,
        'leagueId': leagueIdMap[normalizedCode] ?? 39,
        'leagueCode': normalizedCode,
        'season': '2025',
        'homeOdds': homeOdds,
        'drawOdds': drawOdds,
        'awayOdds': awayOdds,
        'matchId': ?matchId,
        if (commenceTime != null && commenceTime.isNotEmpty)
          'commenceTime': commenceTime,
      };

      final response = await _dio.post<dynamic>(
        '/api/predict-v2',
        data: body,
        options: Options(
          receiveTimeout: _analysisTimeout,
          sendTimeout: _analysisTimeout,
        ),
      );
      final adapted = _adaptToMap(response.data);
      debugPrint('[SOCCER] predict-v2 response keys: ${adapted.keys.toList()}');
      if (adapted['prediction'] != null) {
        final pred = adapted['prediction'];
        if (pred is Map) {
          debugPrint('[SOCCER] prediction keys: ${pred.keys.toList()}');
          debugPrint('[SOCCER] prediction.recommendation: ${pred['recommendation']}');
          debugPrint('[SOCCER] prediction.finalProb: ${pred['finalProb']}');
          debugPrint('[SOCCER] prediction.homePower: ${pred['homePower']}');
          debugPrint('[SOCCER] prediction.awayPower: ${pred['awayPower']}');
          debugPrint('[SOCCER] prediction.patternStats: ${pred['patternStats']}');
          final patternStats = pred['patternStats'];
          if (patternStats is Map) {
            debugPrint(
              '[SOCCER] patternStats keys: ${patternStats.keys.toList()}',
            );
          }
          for (final key in pred.keys) {
            if (![
              'recommendation',
              'finalProb',
              'homePower',
              'awayPower',
              'patternStats',
            ].contains(key)) {
              debugPrint(
                '[SOCCER] prediction.$key type: ${pred[key].runtimeType}',
              );
              if (pred[key] is Map) {
                debugPrint(
                  '[SOCCER] prediction.$key keys: ${(pred[key] as Map).keys.toList()}',
                );
              }
            }
          }
        }
      }
      return adapted;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMatchH2H({
    required int homeTeamId,
    required int awayTeamId,
    int last = 10,
  }) async {
    debugPrint('[SOCCER] GET /api/h2h-enhanced for $homeTeamId vs $awayTeamId');
    try {
      final response = await _dio.get<dynamic>(
        '/api/h2h-enhanced',
        queryParameters: <String, dynamic>{
          'team1': homeTeamId,
          'team2': awayTeamId,
          'last': last,
        },
      );
      return _adaptToMap(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMatchH2HAnalysis({
    required String homeTeam,
    required String awayTeam,
  }) async {
    debugPrint('[SOCCER] GET /api/h2h-analysis for $homeTeam vs $awayTeam');
    try {
      final response = await _dio.get<dynamic>(
        '/api/h2h-analysis',
        queryParameters: <String, String>{
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
        },
      );
      final data = response.data;
      debugPrint('[SOCCER] h2h-analysis response type: ${data.runtimeType}');
      debugPrint(
        '[SOCCER] h2h-analysis keys: ${data is Map ? data.keys.toList() : "not map"}',
      );
      if (data is Map) {
        for (final key in data.keys) {
          final val = data[key];
          debugPrint('[SOCCER] h2h-analysis.$key type: ${val.runtimeType}');
          if (val is Map) {
            debugPrint('[SOCCER] h2h-analysis.$key keys: ${val.keys.toList()}');
          }
          if (val is List) {
            debugPrint('[SOCCER] h2h-analysis.$key length: ${val.length}');
          }
        }
      }
      return _adaptToMap(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTeamStats({
    required String teamName,
    required String leagueCode,
    required int teamId,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/team-stats',
        queryParameters: <String, dynamic>{
          'team': teamName,
          'league': leagueCode,
          'teamId': teamId,
        },
      );
      final data = response.data;
      debugPrint(
        '[SOCCER] team-stats for $teamName ($teamId): source=${data is Map ? data['source'] : null}',
      );
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      debugPrint('[SOCCER] team-stats error for $teamName: $e');
      return {};
    }
  }

  // TODO: Replace with /api/v1/mobile/soccer/premium-picks when available
  Future<List<SoccerAnalysisCard>> getPremiumPicks({
    required String date,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/premium-picks',
        queryParameters: <String, String>{'date': date},
      );
      return _adaptToAnalysisCards(response.data)
          .map(
            (card) => card.copyWith(
              grade: card.grade ?? 'PREMIUM_PICK',
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // TODO: Replace with /api/v1/mobile/soccer/premium-picks/stats when available
  Future<Map<String, dynamic>> getPremiumPickStats({int days = 30}) async {
    debugPrint('[SOCCER] getPremiumPickStats days=$days');
    try {
      final response = await _dio.get<dynamic>(
        '/api/premium-picks/stats',
        queryParameters: <String, int>{'days': days},
      );
      final raw = response.data;
      debugPrint(
        '[SOCCER] getPremiumPickStats raw response type: ${raw.runtimeType}',
      );
      debugPrint(
        '[SOCCER] getPremiumPickStats raw keys: ${raw is Map ? raw.keys.toList() : "not map"}',
      );
      if (raw is Map<String, dynamic>) return raw;
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return <String, dynamic>{};
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getPremiumPickHistory() async {
    try {
      final response = await _dio.get<dynamic>('/api/premium-picks/history');
      final raw = response.data;
      final history = raw is Map<String, dynamic>
          ? raw
          : raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{};
      return history;
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> calculateRecentStats(
    Map<String, dynamic> historyResponse, {
    int windowSize = 30,
  }) {
    final picks = _extractHistoryPicks(historyResponse);
    if (picks.isEmpty) return {};

    final teamLogos = _extractTeamLogosFromHistoryPicks(picks);

    final settled = picks.where((pick) {
      final result = _readPickResult(pick)?.toUpperCase();
      return result == 'WIN' || result == 'LOSE';
    }).toList();

    settled.sort((a, b) {
      final aTime = _readCommenceTime(a);
      final bTime = _readCommenceTime(b);
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    final window = settled.take(windowSize).toList();
    if (window.isEmpty) return {};

    var wins = 0;
    var losses = 0;
    for (final pick in window) {
      if (_readPickResult(pick)?.toUpperCase() == 'WIN') {
        wins++;
      } else {
        losses++;
      }
    }

    final total = window.length;
    final winRate = total > 0 ? ((wins / total) * 100).round() : 0;

    var streak = 0;
    for (final pick in window) {
      if (_readPickResult(pick)?.toUpperCase() == 'WIN') {
        streak++;
      } else {
        break;
      }
    }

    final recentResults =
        window.take(7).map(_toRecentResultEntry).toList(growable: false);

    debugPrint(
      '[SOCCER] calculateRecentStats: winRate=$winRate, streak=$streak, total=$total',
    );

    return {
      'winRate': winRate,
      'wins': wins,
      'losses': losses,
      'streak': streak,
      'streakType': streak > 0 ? 'winning' : 'losing',
      'total': total,
      'recentResults': recentResults,
      if (teamLogos.isNotEmpty) 'teamLogos': teamLogos,
    };
  }

  Map<String, String> _extractTeamLogosFromHistoryPicks(
    List<Map<String, dynamic>> picks,
  ) {
    final logos = <String, String>{};
    for (final pick in picks) {
      _registerHistoryPickTeamLogo(logos, pick, isHome: true);
      _registerHistoryPickTeamLogo(logos, pick, isHome: false);
    }
    return logos;
  }

  void _registerHistoryPickTeamLogo(
    Map<String, String> logos,
    Map<String, dynamic> pick, {
    required bool isHome,
  }) {
    final teamId = _readHistoryPickTeamId(
      pick,
      isHome
          ? const ['home_team_id', 'homeTeamId']
          : const ['away_team_id', 'awayTeamId'],
    );
    if (teamId == null) return;

    final logoUrl = 'https://media.api-sports.io/football/teams/$teamId.png';
    final names = _historyPickTeamNames(pick, isHome: isHome);
    for (final name in names) {
      _addTeamLogoNameVariants(logos, name, logoUrl);
    }
  }

  Set<String> _historyPickTeamNames(
    Map<String, dynamic> pick, {
    required bool isHome,
  }) {
    final names = <String>{};
    final nameKeys = isHome
        ? const ['home_team', 'homeTeam', 'home']
        : const ['away_team', 'awayTeam', 'away'];

    for (final key in nameKeys) {
      final value = pick[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        names.add(value.toString().trim());
      }
    }

    final matchRaw = pick['match'];
    if (matchRaw is String && matchRaw.contains(' vs ')) {
      final parts = matchRaw.split(RegExp(r'\s+vs\s+', caseSensitive: false));
      if (parts.length >= 2) {
        names.add(
          isHome
              ? parts.first.trim()
              : parts.sublist(1).join(' vs ').trim(),
        );
      }
    }

    return names;
  }

  int? _readHistoryPickTeamId(
    Map<String, dynamic> pick,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = pick[key];
      if (value == null) continue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String? _footballTeamLogoUrl(Object? teamId) {
    if (teamId == null) return null;
    final int? id;
    if (teamId is int) {
      id = teamId;
    } else if (teamId is num) {
      id = teamId.toInt();
    } else if (teamId is String) {
      id = int.tryParse(teamId.trim());
    } else {
      id = null;
    }
    if (id == null || id <= 0) return null;
    return 'https://media.api-sports.io/football/teams/$id.png';
  }

  void _addTeamLogoNameVariants(
    Map<String, String> logos,
    String name,
    String logoUrl,
  ) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    logos[trimmed] = logoUrl;

    final lowered = trimmed.toLowerCase();
    logos[lowered] = logoUrl;

    final stripped = _stripDiacriticsForLogo(lowered);
    if (stripped != lowered) {
      logos[stripped] = logoUrl;
    }

    logos[_normalizeTeamNameForLogo(trimmed)] = logoUrl;
  }

  String _normalizeTeamNameForLogo(String input) {
    var normalized = input.toLowerCase().trim();
    normalized = _stripDiacriticsForLogo(normalized);
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  String _stripDiacriticsForLogo(String input) {
    const diacriticMap = {
      'ä': 'a',
      'ö': 'o',
      'ü': 'u',
      'ß': 'ss',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    return input.split('').map((c) => diacriticMap[c] ?? c).join();
  }

  String? _readHistoryPickString(
    Map<String, dynamic> pick,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = pick[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _extractHistoryPicks(
    Map<String, dynamic> response,
  ) {
    for (final key in const [
      'picks',
      'data',
      'history',
      'results',
      'items',
    ]) {
      final value = response[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const [];
  }

  String? _readPickResult(Map<String, dynamic> pick) {
    for (final key in const ['result', 'outcome', 'status']) {
      final value = pick[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  DateTime? _readCommenceTime(Map<String, dynamic> pick) {
    for (final key in const [
      'commence_time',
      'commenceTime',
      'kickoff',
      'kickoff_time',
      'date',
      'matchDate',
      'match_date',
    ]) {
      final value = pick[key];
      if (value == null) continue;
      if (value is DateTime) return value.toUtc();
      if (value is num) {
        final timestamp = value > 1e12 ? value.toInt() : (value * 1000).toInt();
        return DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
      }
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed.toUtc();
      }
    }
    return null;
  }

  Map<String, dynamic> _toRecentResultEntry(Map<String, dynamic> pick) {
    final homeLogo = _footballTeamLogoUrl(
          pick['home_team_id'] ?? pick['homeTeamId'],
        ) ??
        _readHistoryPickString(
          pick,
          const ['home_team_logo', 'homeTeamLogo', 'homeLogo', 'home_logo'],
        );
    final awayLogo = _footballTeamLogoUrl(
          pick['away_team_id'] ?? pick['awayTeamId'],
        ) ??
        _readHistoryPickString(
          pick,
          const ['away_team_logo', 'awayTeamLogo', 'awayLogo', 'away_logo'],
        );

    final match = pick['match'];
    if (match is String && match.isNotEmpty) {
      return {
        'match': match,
        'predicted': pick['predicted'] ??
            pick['prediction'] ??
            pick['pick'] ??
            pick['direction'],
        'score': pick['score'],
        'result': pick['result'],
        'date': pick['date'] ?? pick['commence_time'] ?? pick['commenceTime'],
        'homeTeamLogo': ?homeLogo,
        'awayTeamLogo': ?awayLogo,
      };
    }

    final home = pick['homeTeam'] ?? pick['home_team'] ?? pick['home'];
    final away = pick['awayTeam'] ?? pick['away_team'] ?? pick['away'];
    final matchLabel = (home != null && away != null) ? '$home vs $away' : '';

    return {
      if (matchLabel.isNotEmpty) 'match': matchLabel,
      if (home is String && home.isNotEmpty) 'homeTeam': home,
      if (away is String && away.isNotEmpty) 'awayTeam': away,
      'homeTeamLogo': ?homeLogo,
      'awayTeamLogo': ?awayLogo,
      'predicted': pick['predicted'] ??
          pick['prediction'] ??
          pick['pick'] ??
          pick['direction'],
      'score': pick['score'],
      'result': pick['result'],
      'date': pick['date'] ?? pick['commence_time'] ?? pick['commenceTime'],
    };
  }

  List<SoccerAnalysisCard> _filterAnalysisLeagueCards(
    List<SoccerAnalysisCard> cards,
  ) {
    final excludedCodes = <String>{};
    final filtered = cards.where((card) {
      final code = card.match.league.code?.toUpperCase();
      if (code == null || !_analysisLeagueCodeSet.contains(code)) {
        if (code != null && code.isNotEmpty) {
          excludedCodes.add(code);
        }
        return false;
      }
      return true;
    }).toList();

    if (excludedCodes.isNotEmpty) {
      debugPrint(
        '[SOCCER] Filtered non-analysis league codes: ${excludedCodes.toList()}',
      );
    }
    debugPrint(
      '[SOCCER] Analysis league filter: ${cards.length} -> ${filtered.length} cards',
    );
    return filtered;
  }

  List<SoccerAnalysisCard> _adaptToAnalysisCards(dynamic data) {
    final items = _extractList(data);
    debugPrint('[SOCCER] Parsing ${items.length} items into SoccerAnalysisCard');
    final cards = items
        .whereType<Map<String, dynamic>>()
        .map(SoccerAnalysisCard.fromJson)
        .toList();
    if (cards.isNotEmpty) {
      final card = cards.first;
      debugPrint(
        '[SOCCER] Parsed card: home=${card.match.homeTeam.name}, away=${card.match.awayTeam.name}, league=${card.match.league.name}',
      );
    }
    if (items.isNotEmpty && cards.isEmpty) {
      debugPrint('[SOCCER] WARNING: Data exists but parsed 0 cards');
    }
    return cards;
  }

  Map<String, dynamic> _adaptToMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'data': data};
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in const [
        'matches',
        'data',
        'items',
        'results',
        'picks',
        'premiumPicks',
        'premium_picks',
      ]) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    if (data is Map) {
      return _extractList(Map<String, dynamic>.from(data));
    }
    return const [];
  }

  bool _matchesLeague(SoccerAnalysisCard card, String league) {
    final normalized = league.trim().toLowerCase();
    final info = card.match.league;
    return info.code?.toLowerCase() == normalized ||
        info.name.toLowerCase() == normalized ||
        info.id.toString() == normalized;
  }
}
