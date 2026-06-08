/// SOCCER API KOREAN TEXT FIELD REPORT
/// Generated for developer handoff — identifies API response fields
/// that contain Korean text and need English alternatives.
///
/// Scanned: soccer_analysis_parser.dart, soccer_premium_parser.dart,
/// soccer_team_stats_parser.dart, and soccer standard/premium widgets.
///
/// Legend:
/// - HIGH: API string shown verbatim in UI (needs `language` param or EN field)
/// - MED:  Shown when parser cannot map to l10n template (fallback path)
/// - LOW:  Parsed but not currently displayed, or numeric-only after formatting
/// - OK:   Mapped to l10n labels or formatted numbers only
///
/// ---------------------------------------------------------------------------
/// SOURCE: POST /api/predict-v2
/// Parser: lib/features/analysis/models/soccer_analysis_parser.dart
/// UI:     lib/features/analysis/widgets/soccer/standard/
/// ---------------------------------------------------------------------------
///
/// STANDARD TAB — Analysis Result (AnalysisResultSection)
/// - prediction.recommendation.pick / direction → prediction cell → OK
///   Mapped via _formatPickDisplay() to l10n (soccerPickHomeWin / Draw / AwayWin).
///   API sends codes like HOME/DRAW/AWAY, not Korean prose.
/// - prediction.finalProb.{home,draw,away} → winProbability cell → OK
///   Numeric percent only.
/// - prediction.homePower / awayPower → powerDiff cell → OK
///   Absolute numeric difference only.
/// - prediction.recommendation.grade → grade badge → OK
///   Normalized to pick/good/pass enum; badge labels are l10n.
/// - prediction.patternStats.totalMatches → analysisMatchCount → OK
///   Comma-formatted integer.
/// - prediction.pattern (string) → patternMatchCount → MED
///   If API sends a descriptive string, shown raw in pattern cell.
///   If absent, falls back to patternStats rates as "H-D-A" digits (e.g. 3-2-5).
///   Example: Korean trend label in pattern field would display as-is.
///
/// STANDARD TAB — Reasoning (ReasoningSection)
/// - prediction.recommendation.reasons[] (`List<String>`) → reasoning rows → MED/HIGH
///   Each string parsed by _parseReasonString(). Known English patterns
///   (power diff, prob edge, pattern, first goal) map to l10n labels.
///   Unrecognized strings use label=l10n.soccerReasonBasis and value=raw reason → HIGH
///   Example: "선득점: 홈팀 유리" or free-form Korean rationale passes through verbatim.
///   Strings starting with "data:" are skipped entirely.
///
/// STANDARD TAB — Odds (OddsSection)
/// - match.odds.{home,draw,away} → odds values → OK (numeric)
///
/// STANDARD TAB — Power Index (PowerIndexSection)
/// - prediction.homePower / awayPower → bar labels → OK (numeric)
///
/// STANDARD TAB — Team Statistics (TeamStatisticsSection)
/// - prediction.debug.homeStats / awayStats → stat values → OK
///   homeFirstGoalWinRate, homeComebackRate, form — all formatted as % or decimal.
/// - prediction.homePA.all / awayPA.all → goal-difference ratio → OK (numeric)
/// - Row labels (first goal rate, comeback, form, goal diff) → OK (l10n via ParserLabels)
///
/// STANDARD TAB — 3-Method Analysis (ThreeMethodAnalysisSection)
/// - prediction.method1/2/3.{win,draw,lose} → bar percentages → OK (numeric)
/// - Method row labels → OK (l10n: soccerMethodPaCompare, MinMax, FirstGoal)
///
/// STANDARD TAB — Match header (MatchHeader, via parsed homeTeam/awayTeam)
/// - match.homeTeam.name / awayTeam.name (or flat homeTeamName) → team names → HIGH
///   Team names from API may be Korean (K-League). Header uses locale helper
///   when KO/EN pair available from fixture list; predict-v2 path may lack EN alias.
///
/// MATCH HEADER — date
/// - match.matchDate + matchTime → matchDateDisplay → client-side Korean format
///   _formatMatchDateDisplay() uses "N월 N일 HH:MM" when only timestamp available.
///   Not an API field issue — client formatting; separate from API i18n.
///
/// NOT DISPLAYED (parsed or present in API but unused in Standard UI)
/// - prediction.recommendation.reason (singular) → not read by parser
/// - prediction.recommendation.summary → not read
/// - prediction.insights[] → not parsed in standard flow
/// - prediction.analysis / analysisText → not displayed
/// - prediction.trendDescription → not displayed
/// - prediction.method*.description / text / comment → not displayed
///
/// ---------------------------------------------------------------------------
/// SOURCE: GET /api/h2h-analysis
/// Parser: lib/features/analysis/models/soccer_premium_parser.dart
/// UI:     lib/features/analysis/widgets/soccer/premium/h2h_section.dart
/// ---------------------------------------------------------------------------
///
/// PREMIUM TAB — H2H section (H2HSection)
/// - data.overall.{totalMatches,homeWins,draws,awayWins,...} → counts/rates → OK
/// - data.recentMatches[].{homeScore,awayScore,result} → score boxes → OK
///   Scores and W/L/D codes only; team names from recentMatches not shown in boxes.
/// - data.scorePatterns.mostCommon[].score → max-score labels → OK
///   Score strings like "1-0", "2-1" (not prose).
/// - data.scorePatterns.{avgHomeGoals,over25Rate,bttsRate} → stats cards → OK
/// - data.insights[] (`List<String>`) → InsightsCard comments → HIGH
///   Shown verbatim in H2H insights block.
///   Example: "최근 5경기 홈팀 우세", "양팀 득점 경향이 뚜렷함"
///
/// PARSED BUT NOT DISPLAYED (h2h-analysis)
/// - data.recent5.trend → not bound to any widget
/// - data.recent5.trendDescription → parsed in H2HRecent5, no UI reference → LOW
/// - data.analysis / analysisSummary / summary → not parsed or displayed → LOW
///
/// ---------------------------------------------------------------------------
/// SOURCE: GET /api/team-stats (home + away, Premium tab)
/// Parser: lib/features/analysis/models/soccer_team_stats_parser.dart
/// UI:     lib/features/analysis/widgets/soccer/premium/team_analysis_section.dart
/// ---------------------------------------------------------------------------
///
/// PREMIUM TAB — Team Analysis (TeamAnalysisSection, per team)
/// - data.recentForm.last10.{wins,draws,losses} → circle badges → OK
/// - data.recentMatches[].{goalsFor,goalsAgainst,result} → form score boxes → OK
/// - data.homeStats / awayStats.{wins,draws,losses,winRate} → record row → OK
/// - data.markets.{over25Rate,bttsRate,cleanSheetRate,scorelessRate} → market cards → OK
/// - data.strengths[] (`List<String>`) → teamInsights (InsightsCard) → HIGH
///   Combined with weaknesses, first 3 items shown as insight bullets.
///   Example: "홈 경기 득점력 우수", "최근 5연승"
/// - data.weaknesses[] (`List<String>`) → teamInsights (InsightsCard) → HIGH
///   Example: "원정 수비 불안", "후반 실점 많음"
/// - data.recentMatches[].opponentKo → lose-emblem initial only → LOW
///   First character of Korean opponent name on loss score box; not full text.
/// - data.recentMatches[].opponent → logo lookup key only → LOW
///
/// ---------------------------------------------------------------------------
/// SOURCE: POST /api/analysis (markdown — alternate Standard path)
/// UI:     SoccerStandardMarkdownTab (soccer_standard_tab.dart)
/// ---------------------------------------------------------------------------
///
/// - response body (markdown string) → SelectableText full body → HIGH
///   Entire AI analysis rendered as raw markdown; primary Korean text surface
///   when this endpoint is used instead of structured predict-v2 sections.
///
/// ---------------------------------------------------------------------------
/// PRIORITY SUMMARY FOR BACKEND `language` PARAM
/// ---------------------------------------------------------------------------
///
/// 1. HIGH — add EN variants or language-aware responses for:
///    - /api/h2h-analysis → data.insights[]
///    - /api/team-stats → data.strengths[], data.weaknesses[]
///    - /api/predict-v2 → prediction.recommendation.reasons[] (unmapped strings)
///    - /api/analysis → full markdown body
///    - Team names when only Korean name provided (fixture + predict-v2 match blocks)
///
/// 2. MED — conditional raw display:
///    - /api/predict-v2 → prediction.pattern (when string, not rate tuple)
///
/// 3. LOW — already parsed but unused; safe to add EN fields before future UI:
///    - /api/h2h-analysis → recent5.trendDescription, analysis/summary fields
///
/// 4. OK — no API text i18n needed (numbers, codes mapped to l10n, or UI labels):
///    - finalProb, power values, odds, grade badge, method probabilities,
///      team stat percentages, H2H counts, score patterns
library;
