import 'package:trendsoccer/l10n/app_localizations.dart';

/// UI labels used when parsing analysis API responses into display models.
class ParserLabels {
  const ParserLabels(this.l10n);

  factory ParserLabels.from(AppLocalizations l10n) => ParserLabels(l10n);

  final AppLocalizations l10n;

  String get labelHome => l10n.labelHome;
  String get labelAway => l10n.labelAway;

  String get soccerPickHomeWin => l10n.soccerOddsHome;
  String get soccerPickDraw => l10n.soccerDraw;
  String get soccerPickAwayWin => l10n.soccerOddsAway;

  String get soccerMethodPaCompare => l10n.soccerMethodPaCompare;
  String get soccerMethodMinMax => l10n.soccerMethodMinMax;
  String get soccerMethodFirstGoal => l10n.soccerMethodFirstGoal;

  String get soccerReasonPowerDiff => l10n.soccerPowerDiff;
  String get soccerReasonProbEdge => l10n.parserReasonProbEdge;
  String get soccerReasonPattern => l10n.soccerStatPattern;
  String get soccerReasonFirstGoalHome => l10n.soccerReasonFirstGoalHome;
  String get soccerReasonFirstGoalAway => l10n.soccerReasonFirstGoalAway;
  String get soccerReasonBasis => l10n.parserReasonBasis;

  String soccerReasonPowerDiffPoints(String value) =>
      l10n.parserReasonPowerDiffPoints(value);

  String soccerReasonPatternMatches(int count) =>
      l10n.parserReasonPatternMatches(count);

  String get soccerStatFirstGoalRate => l10n.soccerStatFirstGoalRate;
  String get soccerStatComebackRate => l10n.soccerStatComebackRate;
  String get soccerStatRecentForm => l10n.soccerRecentForm;
  String get soccerStatGoalDifference => l10n.soccerStatGoalDifference;

  String get baseballPitcherGeneric => l10n.baseballPitcherGeneric;
  String get baseballLeagueFallback => l10n.sportBaseball;
  String get baseballAiSummaryDefault => l10n.baseballAiSummaryDefault;
  String get baseballAiWinProbabilityHint => l10n.baseballAiWinProbabilityHint;
  String get baseballTeamProductivityComment => l10n.baseballTeamProductivityComment;

  String get baseballStatRunsScored => l10n.baseballStatRunsScored;
  String get baseballStatRunsAllowed => l10n.baseballStatRunsAllowed;
  String get baseballStatHits => l10n.baseballStatHits;
  String get baseballTeamBattingAvg => l10n.baseballTeamBattingAvg;
  String get baseballTeamOps => l10n.baseballTeamOps;
  String get baseballTeamEra => l10n.baseballTeamEra;
  String get baseballTeamWhip => l10n.baseballTeamWhip;

  String get baseballConfidenceHigh => l10n.baseballConfidenceHigh;
  String get baseballConfidenceMedium => l10n.baseballConfidenceMedium;
  String get baseballConfidenceLow => l10n.baseballConfidenceLow;

  String baseballWinsLosses(int wins, int losses) =>
      l10n.baseballWinsLosses(wins, losses);

  String baseballProductionBatterEdge(String team, String value) =>
      l10n.baseballProductionBatterEdge(team, value);

  String baseballProductionDefenseEdge(String team, String value) =>
      l10n.baseballProductionDefenseEdge(team, value);
}
