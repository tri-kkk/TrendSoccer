/// Fixture list payload: leagues, matches, and team rows (scores/schedules).
class FixtureTeam {
  const FixtureTeam({
    required this.name,
    this.logoUrl,
  });

  final String name;
  final String? logoUrl;

  Map<String, dynamic> toJson() => {
        'name': name,
        'logoUrl': logoUrl,
      };

  factory FixtureTeam.fromJson(Map<String, dynamic> json) {
    return FixtureTeam(
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  FixtureTeam copyWith({
    String? name,
    String? logoUrl,
  }) {
    return FixtureTeam(
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}

class FixtureMatch {
  const FixtureMatch({
    required this.matchId,
    required this.leagueId,
    required this.leagueName,
    this.leagueLogoUrl,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDateTime,
    required this.status,
    this.homeScore,
    this.awayScore,
  });

  final String matchId;
  final String leagueId;
  final String leagueName;
  final String? leagueLogoUrl;
  final FixtureTeam homeTeam;
  final FixtureTeam awayTeam;
  final DateTime matchDateTime;
  /// Values such as `scheduled`, `live`, `finished` (lowercase, API-driven).
  final String status;
  final int? homeScore;
  final int? awayScore;

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'leagueId': leagueId,
        'leagueName': leagueName,
        'leagueLogoUrl': leagueLogoUrl,
        'homeTeam': homeTeam.toJson(),
        'awayTeam': awayTeam.toJson(),
        'matchDateTime': matchDateTime.toIso8601String(),
        'status': status,
        'homeScore': homeScore,
        'awayScore': awayScore,
      };

  factory FixtureMatch.fromJson(Map<String, dynamic> json) {
    return FixtureMatch(
      matchId: json['matchId'] as String,
      leagueId: json['leagueId'] as String,
      leagueName: json['leagueName'] as String,
      leagueLogoUrl: json['leagueLogoUrl'] as String?,
      homeTeam: FixtureTeam.fromJson(
        Map<String, dynamic>.from(json['homeTeam'] as Map),
      ),
      awayTeam: FixtureTeam.fromJson(
        Map<String, dynamic>.from(json['awayTeam'] as Map),
      ),
      matchDateTime: DateTime.parse(json['matchDateTime'] as String),
      status: json['status'] as String,
      homeScore: json['homeScore'] != null
          ? (json['homeScore'] as num).toInt()
          : null,
      awayScore: json['awayScore'] != null
          ? (json['awayScore'] as num).toInt()
          : null,
    );
  }

  FixtureMatch copyWith({
    String? matchId,
    String? leagueId,
    String? leagueName,
    String? leagueLogoUrl,
    FixtureTeam? homeTeam,
    FixtureTeam? awayTeam,
    DateTime? matchDateTime,
    String? status,
    int? homeScore,
    int? awayScore,
  }) {
    return FixtureMatch(
      matchId: matchId ?? this.matchId,
      leagueId: leagueId ?? this.leagueId,
      leagueName: leagueName ?? this.leagueName,
      leagueLogoUrl: leagueLogoUrl ?? this.leagueLogoUrl,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      matchDateTime: matchDateTime ?? this.matchDateTime,
      status: status ?? this.status,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
    );
  }
}

class FixtureLeague {
  const FixtureLeague({
    required this.leagueId,
    required this.leagueName,
    this.logoUrl,
    this.matches = const [],
  });

  final String leagueId;
  final String leagueName;
  final String? logoUrl;
  final List<FixtureMatch> matches;

  Map<String, dynamic> toJson() => {
        'leagueId': leagueId,
        'leagueName': leagueName,
        'logoUrl': logoUrl,
        'matches': matches.map((e) => e.toJson()).toList(),
      };

  factory FixtureLeague.fromJson(Map<String, dynamic> json) {
    return FixtureLeague(
      leagueId: json['leagueId'] as String,
      leagueName: json['leagueName'] as String,
      logoUrl: json['logoUrl'] as String?,
      matches: (json['matches'] as List<dynamic>?)
              ?.map(
                (e) => FixtureMatch.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          const [],
    );
  }

  FixtureLeague copyWith({
    String? leagueId,
    String? leagueName,
    String? logoUrl,
    List<FixtureMatch>? matches,
  }) {
    return FixtureLeague(
      leagueId: leagueId ?? this.leagueId,
      leagueName: leagueName ?? this.leagueName,
      logoUrl: logoUrl ?? this.logoUrl,
      matches: matches ?? this.matches,
    );
  }
}
