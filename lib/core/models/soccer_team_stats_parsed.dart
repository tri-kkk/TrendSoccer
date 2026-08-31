// Pure-data parse of `GET /api/team-stats` for report blocks 06, 07, 09.

class SoccerTeamMarketsParsed {
  const SoccerTeamMarketsParsed({
    this.over25Rate,
    this.bttsRate,
    this.cleanSheetRate,
    this.scorelessRate,
  });

  final double? over25Rate;
  final double? bttsRate;
  final double? cleanSheetRate;
  final double? scorelessRate;

  bool get hasData =>
      over25Rate != null ||
      bttsRate != null ||
      cleanSheetRate != null ||
      scorelessRate != null;
}

class SoccerTeamLast10Parsed {
  const SoccerTeamLast10Parsed({
    this.wins,
    this.draws,
    this.losses,
    this.goalsFor,
    this.goalsAgainst,
  });

  final int? wins;
  final int? draws;
  final int? losses;
  final int? goalsFor;
  final int? goalsAgainst;

  int get played => (wins ?? 0) + (draws ?? 0) + (losses ?? 0);

  double? get winRateFraction {
    final total = played;
    if (total <= 0 || wins == null) return null;
    return wins! / total;
  }

  bool get hasData => played > 0;
}

class SoccerTeamVenueStatsParsed {
  const SoccerTeamVenueStatsParsed({
    this.wins,
    this.draws,
    this.losses,
    this.winRate,
    this.goalsFor,
    this.goalsAgainst,
  });

  final int? wins;
  final int? draws;
  final int? losses;
  final int? winRate;
  final int? goalsFor;
  final int? goalsAgainst;

  double? get winRateFraction {
    final rate = winRate;
    if (rate == null || rate <= 0) return null;
    return rate / 100.0;
  }

  bool get hasData =>
      wins != null ||
      draws != null ||
      losses != null ||
      winRate != null ||
      goalsFor != null ||
      goalsAgainst != null;
}

class SoccerTeamInsightEntry {
  const SoccerTeamInsightEntry({
    required this.isHomeTeam,
    required this.isStrength,
    required this.text,
  });

  final bool isHomeTeam;
  final bool isStrength;
  final String text;
}

class SoccerTeamStatsParsed {
  const SoccerTeamStatsParsed({
    required this.markets,
    required this.last10,
    required this.homeStats,
    required this.awayStats,
    required this.strengths,
    required this.weaknesses,
  });

  static const empty = SoccerTeamStatsParsed(
    markets: SoccerTeamMarketsParsed(),
    last10: SoccerTeamLast10Parsed(),
    homeStats: SoccerTeamVenueStatsParsed(),
    awayStats: SoccerTeamVenueStatsParsed(),
    strengths: [],
    weaknesses: [],
  );

  final SoccerTeamMarketsParsed markets;
  final SoccerTeamLast10Parsed last10;
  final SoccerTeamVenueStatsParsed homeStats;
  final SoccerTeamVenueStatsParsed awayStats;
  final List<String> strengths;
  final List<String> weaknesses;

  bool get hasMarketData => markets.hasData;

  bool get hasFormData => last10.hasData || homeStats.hasData || awayStats.hasData;

  bool get hasInsightData => strengths.isNotEmpty || weaknesses.isNotEmpty;
}

SoccerTeamStatsParsed parseSoccerTeamStats(Map<String, dynamic> raw) {
  final data = _readMap(raw, const ['data']) ?? raw;
  final markets = _readMap(data, const ['markets']) ?? {};
  final recentForm = _readMap(data, const ['recentForm', 'recent_form']) ?? {};
  final last10 = _readMap(recentForm, const ['last10', 'last_10']) ?? {};
  final homeStats = _readMap(data, const ['homeStats', 'home_stats']) ?? {};
  final awayStats = _readMap(data, const ['awayStats', 'away_stats']) ?? {};

  return SoccerTeamStatsParsed(
    markets: SoccerTeamMarketsParsed(
      over25Rate: _parseRate(
        markets['over25Rate'] ?? markets['over_25_rate'],
      ),
      bttsRate: _parseRate(markets['bttsRate'] ?? markets['btts_rate']),
      cleanSheetRate: _parseRate(
        markets['cleanSheetRate'] ?? markets['clean_sheet_rate'],
      ),
      scorelessRate: _parseRate(
        markets['scorelessRate'] ?? markets['scoreless_rate'],
      ),
    ),
    last10: SoccerTeamLast10Parsed(
      wins: _parseInt(last10['wins']),
      draws: _parseInt(last10['draws']),
      losses: _parseInt(last10['losses']),
      goalsFor: _parseInt(last10['goalsFor'] ?? last10['goals_for']),
      goalsAgainst: _parseInt(last10['goalsAgainst'] ?? last10['goals_against']),
    ),
    homeStats: _parseVenueStats(homeStats),
    awayStats: _parseVenueStats(awayStats),
    strengths: _parseStringList(data['strengths']),
    weaknesses: _parseStringList(data['weaknesses']),
  );
}

List<SoccerTeamInsightEntry> mergeTeamInsights({
  required SoccerTeamStatsParsed home,
  required SoccerTeamStatsParsed away,
}) {
  final entries = <SoccerTeamInsightEntry>[];
  for (final text in home.strengths) {
    entries.add(
      SoccerTeamInsightEntry(isHomeTeam: true, isStrength: true, text: text),
    );
  }
  for (final text in home.weaknesses) {
    entries.add(
      SoccerTeamInsightEntry(isHomeTeam: true, isStrength: false, text: text),
    );
  }
  for (final text in away.strengths) {
    entries.add(
      SoccerTeamInsightEntry(isHomeTeam: false, isStrength: true, text: text),
    );
  }
  for (final text in away.weaknesses) {
    entries.add(
      SoccerTeamInsightEntry(isHomeTeam: false, isStrength: false, text: text),
    );
  }
  return entries;
}

SoccerTeamVenueStatsParsed _parseVenueStats(Map<String, dynamic> json) {
  return SoccerTeamVenueStatsParsed(
    wins: _parseInt(json['wins']),
    draws: _parseInt(json['draws']),
    losses: _parseInt(json['losses']),
    winRate: _parseInt(json['winRate'] ?? json['win_rate']),
    goalsFor: _parseInt(json['goalsFor'] ?? json['goals_for']),
    goalsAgainst: _parseInt(json['goalsAgainst'] ?? json['goals_against']),
  );
}

double? _normalizeRate(double? value) {
  if (value == null) return null;
  return value <= 1 ? value : value / 100;
}

double? _parseRate(Object? value) => _normalizeRate(_parseDouble(value));

double? _parseDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll('%', '').trim());
  return null;
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

List<String> _parseStringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

Map<String, dynamic>? _readMap(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return null;
}
