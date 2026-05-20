import 'package:trendsoccer/features/analysis/widgets/soccer/premium/h2h_section.dart';
import 'package:trendsoccer/shared/widgets/premium/score_box.dart';

class H2HMatchRecord {
  const H2HMatchRecord({
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
  });

  final String date;
  final String homeTeam;
  final String awayTeam;
  final int? homeScore;
  final int? awayScore;

  String get scoreDisplay {
    if (homeScore != null && awayScore != null) {
      return '$homeScore-$awayScore';
    }
    return '-';
  }
}

class H2HStatsSummary {
  const H2HStatsSummary({
    required this.totalMatches,
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    this.avgGoals = '-',
    this.over25 = '-',
    this.over25Highlight = false,
    this.btts = '-',
    this.mostCommonScores = const [],
  });

  final int totalMatches;
  final int homeWins;
  final int draws;
  final int awayWins;
  final String avgGoals;
  final String over25;
  final bool over25Highlight;
  final String btts;
  final List<MostCommonScoreParsed> mostCommonScores;
}

class MostCommonScoreParsed {
  const MostCommonScoreParsed({
    required this.count,
    required this.score,
  });

  final int count;
  final String score;
}

class TeamDeepAnalysis {
  const TeamDeepAnalysis({
    required this.title,
    this.form,
    this.strengths = const [],
    this.weaknesses = const [],
    this.keyStats = const [],
    this.wins10 = 0,
    this.draws10 = 0,
    this.losses10 = 0,
    this.recentForm = const [],
    this.recordWins = '-',
    this.recordDraws = '-',
    this.recordLosses = '-',
    this.winRate = '-',
    this.goalLineO15 = '-',
    this.goalLineO15Highlight = false,
    this.goalLineO25 = '-',
    this.goalLineO25Highlight = false,
    this.goalLineO35 = '-',
    this.goalLineO35Highlight = false,
    this.marketO25 = '-',
    this.marketO25Highlight = false,
    this.marketBtts = '-',
    this.marketBttsHighlight = false,
    this.marketCs = '-',
    this.marketFts = '-',
    this.insights = const [],
  });

  final String title;
  final String? form;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> keyStats;

  final int wins10;
  final int draws10;
  final int losses10;
  final List<H2HMeeting> recentForm;

  final String recordWins;
  final String recordDraws;
  final String recordLosses;
  final String winRate;

  final String goalLineO15;
  final bool goalLineO15Highlight;
  final String goalLineO25;
  final bool goalLineO25Highlight;
  final String goalLineO35;
  final bool goalLineO35Highlight;

  final String marketO25;
  final bool marketO25Highlight;
  final String marketBtts;
  final bool marketBttsHighlight;
  final String marketCs;
  final String marketFts;

  final List<String> insights;

  String get last10Label => '$title 성적 (최근 10경기)';

  List<String> get teamInsights {
    final lines = <String>[];
    if (form != null && form!.isNotEmpty) {
      lines.add('최근 폼: $form');
    }
    for (final s in strengths) {
      lines.add('강점: $s');
    }
    for (final w in weaknesses) {
      lines.add('약점: $w');
    }
    for (final k in keyStats) {
      lines.add('핵심 지표: $k');
    }
    lines.addAll(insights);
    return lines.isEmpty ? const ['팀 분석 데이터가 없습니다.'] : lines;
  }
}

class SoccerPremiumParsed {
  const SoccerPremiumParsed({
    required this.h2h,
    required this.h2hStats,
    this.h2hInsight,
    required this.homeAnalysis,
    required this.awayAnalysis,
  });

  factory SoccerPremiumParsed.fromMap(Map<String, dynamic> map) {
    return parseSoccerPremium(map);
  }

  final List<H2HMatchRecord> h2h;
  final H2HStatsSummary h2hStats;
  final String? h2hInsight;
  final TeamDeepAnalysis homeAnalysis;
  final TeamDeepAnalysis awayAnalysis;

  List<H2HMeeting> get recentMeetings {
    return h2h
        .map(
          (m) => H2HMeeting(
            score: m.scoreDisplay,
            result: _inferResult(m),
          ),
        )
        .take(5)
        .toList();
  }

  List<String> get h2hInsights {
    final lines = <String>[];
    if (h2hInsight != null && h2hInsight!.trim().isNotEmpty) {
      lines.add(h2hInsight!.trim());
    }
    return lines.isEmpty ? const ['H2H 인사이트가 없습니다.'] : lines;
  }

  List<MostCommonScore> get mostCommonScoresForSection {
    return h2hStats.mostCommonScores
        .map((e) => MostCommonScore(count: e.count, score: e.score))
        .toList();
  }
}

SoccerPremiumParsed parseSoccerPremium(Map<String, dynamic> raw) {
  final h2hRoot = _readMap(raw, const ['h2h', 'headToHead', 'head_to_head']) ?? raw;
  final h2hList = _extractList(
    h2hRoot['matches'] ?? h2hRoot['meetings'] ?? h2hRoot['records'] ?? h2hRoot['history'] ?? h2hRoot['items'],
  );
  final h2hStatsMap = _readMap(h2hRoot, const [
        'stats',
        'summary',
        'h2hStats',
        'h2h_stats',
        'overall',
      ]) ??
      _readMap(raw, const ['h2hStats', 'h2h_stats', 'stats', 'summary']);

  final homeRoot = _readMap(raw, const [
        'homeAnalysis',
        'home_analysis',
        'homeTeamAnalysis',
        'home_team_analysis',
        'home',
      ]) ??
      const <String, dynamic>{};
  final awayRoot = _readMap(raw, const [
        'awayAnalysis',
        'away_analysis',
        'awayTeamAnalysis',
        'away_team_analysis',
        'away',
      ]) ??
      const <String, dynamic>{};

  final insight = _readString(raw, const [
        'h2hInsight',
        'h2h_insight',
        'insight',
        'aiInsight',
        'ai_insight',
      ]) ??
      _readString(h2hRoot, const ['insight', 'aiInsight', 'ai_insight', 'summary']);

  return SoccerPremiumParsed(
    h2h: _parseH2HRecords(h2hList),
    h2hStats: _parseH2HStats(h2hStatsMap, h2hList.length),
    h2hInsight: insight,
    homeAnalysis: _parseTeamAnalysis(homeRoot, title: '홈'),
    awayAnalysis: _parseTeamAnalysis(awayRoot, title: '원정'),
  );
}

List<H2HMatchRecord> _parseH2HRecords(List<dynamic> list) {
  return list
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        return H2HMatchRecord(
          date: _readString(map, const ['date', 'matchDate', 'match_date']) ?? '',
          homeTeam: _readString(map, const [
                'homeTeam',
                'home_team',
                'home',
                'homeTeamName',
                'home_team_name',
              ]) ??
              '',
          awayTeam: _readString(map, const [
                'awayTeam',
                'away_team',
                'away',
                'awayTeamName',
                'away_team_name',
              ]) ??
              '',
          homeScore: _parseInt(
            map['homeScore'] ?? map['home_score'] ?? map['homeGoals'] ?? map['home_goals'],
          ),
          awayScore: _parseInt(
            map['awayScore'] ?? map['away_score'] ?? map['awayGoals'] ?? map['away_goals'],
          ),
        );
      })
      .toList();
}

H2HStatsSummary _parseH2HStats(Map<String, dynamic>? stats, int recordCount) {
  if (stats == null) {
    return H2HStatsSummary(
      totalMatches: recordCount,
      homeWins: 0,
      draws: 0,
      awayWins: 0,
    );
  }

  return H2HStatsSummary(
    totalMatches: _parseInt(
          stats['totalMatches'] ??
              stats['total_matches'] ??
              stats['total'] ??
              stats['played'],
        ) ??
        recordCount,
    homeWins: _parseInt(
          stats['homeWins'] ?? stats['home_wins'] ?? stats['homeWin'] ?? stats['home_win'],
        ) ??
        0,
    draws: _parseInt(stats['draws'] ?? stats['draw']) ?? 0,
    awayWins: _parseInt(
          stats['awayWins'] ?? stats['away_wins'] ?? stats['awayWin'] ?? stats['away_win'],
        ) ??
        0,
    avgGoals: _formatPercentOrValue(
      stats['avgGoals'] ?? stats['avg_goals'] ?? stats['averageGoals'],
    ),
    over25: _formatPercentOrValue(
      stats['over25'] ?? stats['over_2_5'] ?? stats['over2_5'],
    ),
    over25Highlight: _parseBool(
      stats['over25Highlight'] ?? stats['over_2_5_highlight'],
    ),
    btts: _formatPercentOrValue(stats['btts'] ?? stats['bothTeamsScore']),
    mostCommonScores: _parseMostCommonScores(
      stats['mostCommonScores'] ??
          stats['most_common_scores'] ??
          stats['topScores'] ??
          stats['top_scores'],
    ),
  );
}

TeamDeepAnalysis _parseTeamAnalysis(
  Map<String, dynamic> map, {
  required String title,
}) {
  final formList = _extractList(map['form'] ?? map['recentForm'] ?? map['recent_form']);
  final recentForm = formList
      .whereType<Map>()
      .map(_parseFormMeeting)
      .whereType<H2HMeeting>()
      .toList();

  return TeamDeepAnalysis(
    title: _readString(map, const ['title', 'label']) ?? title,
    form: _readString(map, const ['form', 'formSummary', 'form_summary']),
    strengths: _parseStringList(map['strengths'] ?? map['strength']),
    weaknesses: _parseStringList(map['weaknesses'] ?? map['weakness']),
    keyStats: _parseStringList(
      map['keyStats'] ?? map['key_stats'] ?? map['stats'] ?? map['metrics'],
    ),
    wins10: _parseInt(map['wins10'] ?? map['wins'] ?? map['win']) ?? 0,
    draws10: _parseInt(map['draws10'] ?? map['draws'] ?? map['draw']) ?? 0,
    losses10: _parseInt(map['losses10'] ?? map['losses'] ?? map['lose']) ?? 0,
    recentForm: recentForm,
    recordWins: _formatValue(map['recordWins'] ?? map['record_wins'] ?? map['wins']),
    recordDraws: _formatValue(map['recordDraws'] ?? map['record_draws'] ?? map['draws']),
    recordLosses: _formatValue(map['recordLosses'] ?? map['record_losses'] ?? map['losses']),
    winRate: _formatPercentOrValue(map['winRate'] ?? map['win_rate']),
    goalLineO15: _formatPercentOrValue(map['goalLineO15'] ?? map['o15'] ?? map['over15']),
    goalLineO15Highlight: _parseBool(map['goalLineO15Highlight'] ?? map['o15Highlight']),
    goalLineO25: _formatPercentOrValue(map['goalLineO25'] ?? map['o25'] ?? map['over25']),
    goalLineO25Highlight: _parseBool(map['goalLineO25Highlight'] ?? map['o25Highlight']),
    goalLineO35: _formatPercentOrValue(map['goalLineO35'] ?? map['o35'] ?? map['over35']),
    goalLineO35Highlight: _parseBool(map['goalLineO35Highlight'] ?? map['o35Highlight']),
    marketO25: _formatPercentOrValue(map['marketO25'] ?? map['market_o25']),
    marketO25Highlight: _parseBool(map['marketO25Highlight']),
    marketBtts: _formatPercentOrValue(map['marketBtts'] ?? map['market_btts']),
    marketBttsHighlight: _parseBool(map['marketBttsHighlight']),
    marketCs: _formatPercentOrValue(map['marketCs'] ?? map['cleanSheet']),
    marketFts: _formatPercentOrValue(map['marketFts'] ?? map['failedToScore']),
    insights: _parseStringList(map['insights'] ?? map['comments'] ?? map['analysis']),
  );
}

H2HMeeting? _parseFormMeeting(Map item) {
  final map = Map<String, dynamic>.from(item);
  final score = _readString(map, const ['score', 'result', 'line']) ??
      _formatScore(map);
  final resultRaw = _readString(map, const ['outcome', 'resultType', 'result_type']);
  return H2HMeeting(
    score: score,
    result: _toScoreBoxResult(resultRaw),
  );
}

ScoreBoxResult _inferResult(H2HMatchRecord record) {
  if (record.homeScore == null || record.awayScore == null) {
    return ScoreBoxResult.draw;
  }
  if (record.homeScore! > record.awayScore!) return ScoreBoxResult.win;
  if (record.homeScore! < record.awayScore!) return ScoreBoxResult.lose;
  return ScoreBoxResult.draw;
}

ScoreBoxResult _toScoreBoxResult(String? raw) {
  if (raw == null) return ScoreBoxResult.draw;
  final value = raw.toLowerCase();
  if (value.contains('win') || value == 'w' || value.contains('승')) {
    return ScoreBoxResult.win;
  }
  if (value.contains('lose') || value == 'l' || value.contains('패')) {
    return ScoreBoxResult.lose;
  }
  return ScoreBoxResult.draw;
}

List<MostCommonScoreParsed> _parseMostCommonScores(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        return MostCommonScoreParsed(
          count: _parseInt(map['count'] ?? map['frequency']) ?? 0,
          score: _readString(map, const ['score', 'label', 'result']) ?? '-',
        );
      })
      .take(3)
      .toList();
}

List<String> _parseStringList(Object? value) {
  if (value is List) {
    return value
        .map((e) {
          if (e is String) return e;
          if (e is Map) {
            return _readString(
              Map<String, dynamic>.from(e),
              const ['text', 'label', 'value', 'name'],
            );
          }
          return e?.toString();
        })
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
  }
  if (value is String && value.isNotEmpty) return [value];
  return const [];
}

List<dynamic> _extractList(Object? value) {
  if (value is List) return value;
  return const [];
}

Map<String, dynamic>? _readMap(
  Map<String, dynamic>? json,
  List<String> keys,
) {
  if (json == null) return null;
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}

String? _readString(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool _parseBool(Object? value) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

String _formatValue(Object? value) {
  if (value == null) return '-';
  return value.toString();
}

String _formatPercentOrValue(Object? value) {
  if (value == null) return '-';
  if (value is num) {
    if (value <= 1) return '${(value * 100).round()}%';
    return '${value.round()}%';
  }
  return value.toString();
}

String _formatScore(Map<String, dynamic> map) {
  final home = _parseInt(map['homeScore'] ?? map['home_score'] ?? map['home']);
  final away = _parseInt(map['awayScore'] ?? map['away_score'] ?? map['away']);
  if (home != null && away != null) return '$home-$away';
  return '-';
}
