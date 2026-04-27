import '../../core/models/report_models.dart';

const String _kLoremThreeParagraphs = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Integer facilisis lorem eget sapien efficitur, at dignissim odio tincidunt.

Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat duis aute irure dolor in reprehenderit.

Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Curabitur non nulla sit amet nisl tempus convallis quis ac lectus.''';

/// Local dummy data for the Report feature until the API is wired.
class ReportDummyData {
  ReportDummyData._();

  static List<SoccerReport> get soccerReports => _soccerReports;
  static List<BaseballNews> get baseballNews => _baseballNews;

  static final List<SoccerReport> _soccerReports = <SoccerReport>[
    SoccerReport(
      id: 'sr-01',
      title: 'UCL Final Preview: Real Madrid vs Bayern Munich',
      thumbnailUrl: '',
      leagueId: 'ucl',
      publishedAt: DateTime.utc(2026, 4, 24, 12, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-02',
      title: 'EPL Matchweek 35 — Key Battles to Watch',
      thumbnailUrl: '',
      leagueId: 'epl',
      publishedAt: DateTime.utc(2026, 4, 23, 9, 30),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-03',
      title: 'La Liga Title Race: Who Has the Edge?',
      thumbnailUrl: '',
      leagueId: 'laliga',
      publishedAt: DateTime.utc(2026, 4, 22, 15, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-04',
      title: 'K League - Key Prediction',
      thumbnailUrl: '',
      leagueId: 'kleague',
      publishedAt: DateTime.utc(2026, 4, 21, 18, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-05',
      title: 'UCL Semis Tactical Notes: High Press and Transitions',
      thumbnailUrl: '',
      leagueId: 'ucl',
      publishedAt: DateTime.utc(2026, 4, 24, 8, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-06',
      title: 'EPL Relegation Watch: What the Table Says',
      thumbnailUrl: '',
      leagueId: 'epl',
      publishedAt: DateTime.utc(2026, 4, 23, 11, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-07',
      title: 'La Liga Form Guide: Momentum into the Run-In',
      thumbnailUrl: '',
      leagueId: 'laliga',
      publishedAt: DateTime.utc(2026, 4, 22, 12, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-08',
      title: 'K League: Derby Weekend — Storylines to Follow',
      thumbnailUrl: '',
      leagueId: 'kleague',
      publishedAt: DateTime.utc(2026, 4, 21, 9, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-09',
      title: 'UCL Squad Depth: Who Steps Up on Short Rest?',
      thumbnailUrl: '',
      leagueId: 'ucl',
      publishedAt: DateTime.utc(2026, 4, 24, 7, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-10',
      title: 'EPL set-piece trends — Why margins stay thin',
      thumbnailUrl: '',
      leagueId: 'epl',
      publishedAt: DateTime.utc(2026, 4, 23, 14, 30),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-11',
      title: 'UCL Knockout Route: Injury Report and Availability',
      thumbnailUrl: '',
      leagueId: 'ucl',
      publishedAt: DateTime.utc(2026, 4, 23, 17, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-12',
      title: 'EPL: Pressing intensity and transition threat',
      thumbnailUrl: '',
      leagueId: 'epl',
      publishedAt: DateTime.utc(2026, 4, 22, 10, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-13',
      title: 'La Liga: Wide overloads and cutback patterns',
      thumbnailUrl: '',
      leagueId: 'laliga',
      publishedAt: DateTime.utc(2026, 4, 21, 14, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-14',
      title: 'K League: Pressing traps in the final third',
      thumbnailUrl: '',
      leagueId: 'kleague',
      publishedAt: DateTime.utc(2026, 4, 24, 9, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-15',
      title: 'UCL: Rest advantage and travel load',
      thumbnailUrl: '',
      leagueId: 'ucl',
      publishedAt: DateTime.utc(2026, 4, 22, 18, 30),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-16',
      title: 'EPL: Goal threat from set plays — zone breakdown',
      thumbnailUrl: '',
      leagueId: 'epl',
      publishedAt: DateTime.utc(2026, 4, 21, 11, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-17',
      title: 'La Liga: Possession value and final-third entries',
      thumbnailUrl: '',
      leagueId: 'laliga',
      publishedAt: DateTime.utc(2026, 4, 24, 13, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-18',
      title: 'K League: Defensive line height and offside line',
      thumbnailUrl: '',
      leagueId: 'kleague',
      publishedAt: DateTime.utc(2026, 4, 23, 7, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-19',
      title: 'UCL: What the xG models might be missing this round',
      thumbnailUrl: '',
      leagueId: 'ucl',
      publishedAt: DateTime.utc(2026, 4, 22, 20, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
    SoccerReport(
      id: 'sr-20',
      title: 'EPL: Midfield control — who wins the second ball?',
      thumbnailUrl: '',
      leagueId: 'epl',
      publishedAt: DateTime.utc(2026, 4, 21, 19, 0),
      content: _kLoremThreeParagraphs.trim(),
    ),
  ];

  static final List<BaseballNews> _baseballNews = <BaseballNews>[
    BaseballNews(
      id: 'bn-01',
      title: 'MLB Weekly Roundup: Top Performances',
      thumbnailUrl: '',
      source: 'ESPN',
      publishedAt: DateTime.utc(2026, 4, 23, 10, 0),
      url: 'https://example.com/news/bn-01',
    ),
    BaseballNews(
      id: 'bn-02',
      title: 'KBO 2026 Season Preview — Early Leaders',
      thumbnailUrl: '',
      source: 'KBO Official',
      publishedAt: DateTime.utc(2026, 4, 22, 8, 0),
      url: 'https://example.com/news/bn-02',
    ),
    BaseballNews(
      id: 'bn-03',
      title: 'NPB Opening Month Highlights',
      thumbnailUrl: '',
      source: 'NPB News',
      publishedAt: DateTime.utc(2026, 4, 22, 12, 0),
      url: 'https://example.com/news/bn-03',
    ),
    BaseballNews(
      id: 'bn-04',
      title: 'MLB: Pitching Staff Notes After Week Three',
      thumbnailUrl: '',
      source: 'ESPN',
      publishedAt: DateTime.utc(2026, 4, 22, 16, 0),
      url: 'https://example.com/news/bn-04',
    ),
    BaseballNews(
      id: 'bn-05',
      title: 'KBO: Weekend Series Takeaways and Standings',
      thumbnailUrl: '',
      source: 'KBO Official',
      publishedAt: DateTime.utc(2026, 4, 23, 6, 0),
      url: 'https://example.com/news/bn-05',
    ),
  ];
}
