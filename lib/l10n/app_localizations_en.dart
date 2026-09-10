// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutContactEmail => 'tikilab2025@gmail.com';

  @override
  String get aboutContactSection => 'Contact & Support';

  @override
  String get aboutContactWebsite => 'trendsoccer.com';

  @override
  String get aboutDescription =>
      'TrendSoccer analyzes match flow with AI-powered real-time insights. From the Premier League to the Champions League, experience every big match with expert-level analysis.';

  @override
  String get aboutFeatureAiDesc =>
      'Built on four seasons of extensive match data';

  @override
  String get aboutFeatureAiTitle => 'AI-powered analysis';

  @override
  String get aboutFeatureLeaguesDesc =>
      'Comprehensive data for the top six leagues';

  @override
  String get aboutFeatureLeaguesTitle => 'Global league coverage';

  @override
  String get aboutFeatureOddsDesc =>
      'Market monitoring based on index movement';

  @override
  String get aboutFeatureOddsTitle => 'Real-time index analysis';

  @override
  String get aboutFeaturesSection => 'Key features';

  @override
  String get aboutTagline => 'Reading the Flow of Football Through Data';

  @override
  String get aboutVisionSection => 'Vision';

  @override
  String get aboutVisionText =>
      'We help football fans understand and enjoy matches more deeply.';

  @override
  String get accessLockLoginRequired => 'Log in to view.';

  @override
  String get accessLockOpens24HoursBefore => 'Opens 24 hours before kickoff.';

  @override
  String get accessLockOpensOneHourBefore => 'Opens 1 hour before kickoff.';

  @override
  String get accessLockPremium24h =>
      'Premium subscribers can view from 24 hours before kickoff.';

  @override
  String accessUnlockDaysHours(int days, int hours) {
    return 'Opens in ${days}d ${hours}h';
  }

  @override
  String accessUnlockHoursMinutes(int hours, int minutes) {
    return 'Opens in ${hours}h ${minutes}m';
  }

  @override
  String accessUnlockMinutes(int minutes) {
    return 'Opens in ${minutes}m';
  }

  @override
  String get accessUnlockViewAnalysis => 'View analysis';

  @override
  String get alarmToggleTitle => 'Receive Alerts';

  @override
  String alarmEnabledToast(String homeTeam, String awayTeam) {
    return 'Match alerts enabled for $homeTeam vs $awayTeam';
  }

  @override
  String alarmDisabledToast(String homeTeam, String awayTeam) {
    return 'Match alerts disabled for $homeTeam vs $awayTeam';
  }

  @override
  String get alarmSecondHalf => 'Second half';

  @override
  String get analysisAiAnalyzing => 'AI analysis in progress...';

  @override
  String get analysisAiWaitHint => 'Please wait (about 5–10 seconds)';

  @override
  String get analysisCardViewAnalysis => 'Analyze';

  @override
  String get analysisEmpty => 'No analysis data available.';

  @override
  String get analysisLoadFailed => 'Could not load analysis data.';

  @override
  String get analysisLoadMatchesFailed => 'Could not load matches.';

  @override
  String get analysisMatchInfoLoadFailed => 'Could not load match information.';

  @override
  String get analysisMatchInfoLoading => 'Loading match information...';

  @override
  String get analysisNoBaseballScheduled => 'No baseball games scheduled.';

  @override
  String get analysisNoMatches => 'No matches';

  @override
  String get analysisNoMatchesFilterHint =>
      'No games today or no matches match your filters.';

  @override
  String get analysisNoResult => 'No analysis result available.';

  @override
  String get analysisPremiumPick => 'Premium Report';

  @override
  String get analysisTabBaseball => 'Baseball Analysis';

  @override
  String get analysisTabSoccer => 'Soccer Analysis';

  @override
  String get reportsAnalysisNoLeagueBody =>
      'Try another league or view all analysis.';

  @override
  String get reportsAnalysisNoLeagueTitle => 'Analysis isn\'t ready yet';

  @override
  String get reportsAnalysisViewAll => 'View all analysis';

  @override
  String get feedPreviewNoLeagueTitle => 'No previews for this league';

  @override
  String get feedPreviewNoLeagueBody =>
      'Try another league or view all previews.';

  @override
  String get feedPreviewViewAll => 'View all previews';

  @override
  String get feedPreviewEmptyTitle => 'No previews yet';

  @override
  String get feedPreviewEmptyBody =>
      'Match previews are published before kickoff.';

  @override
  String get highlightsLoadError => 'Could not load highlights';

  @override
  String get newsLoadError => 'Could not load news';

  @override
  String get feedNewsSportAll => 'All';

  @override
  String get feedNewsSportSoccer => 'Soccer';

  @override
  String get feedNewsSportBaseball => 'Baseball';

  @override
  String get feedNewsLabel => 'News';

  @override
  String get feedTabHighlights => 'Highlights';

  @override
  String get feedTabNews => 'News';

  @override
  String get feedTabPreview => 'Preview';

  @override
  String get homeAccuracyBaselineThreeWay =>
      'Baseline 33% — random guess across three results';

  @override
  String get homeAccuracyBaselineTwoWay =>
      'Baseline 50% — random guess between two teams';

  @override
  String get homeAccuracyEmptyDescription =>
      'Try a longer window, or check back when the season resumes.';

  @override
  String get homeAccuracyEmptyTitle => 'No settled reports in this period';

  @override
  String get homeAccuracyRecent => 'Recent';

  @override
  String homeAccuracySampleCount(int total) {
    return 'Based on $total reports';
  }

  @override
  String get homeAccuracyTitle => 'Analysis accuracy';

  @override
  String get homeAccuracyViewReports => 'View reports';

  @override
  String get homeComboTypeAggressive => 'Aggressive';

  @override
  String homeComboAccuracyLast14Days(String accuracy) {
    return '$accuracy accuracy · last 14 days';
  }

  @override
  String get homeComboAccuracyUnavailable => 'Accuracy not available yet';

  @override
  String get homeComboTodayCountCaption => 'multi-match today';

  @override
  String get homeComboViewAnalyses => 'View multi-match analyses';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeTodayMatchesTitle => 'Today\'s Matches';

  @override
  String get homeUnlockHeadline => 'Unlock full analysis';

  @override
  String get homeUnlockSubline => 'Reports, multi-match analysis';

  @override
  String get highlightPlaybackFailedTitle => 'Can\'t play this clip';

  @override
  String get highlightPlaybackFailedBody => 'Try again in a moment';

  @override
  String get reportsPremiumEmptyBody =>
      'Premium reports are published selectively. Every match is available in Analysis.';

  @override
  String get reportsPremiumEmptyTitle => 'No premium reports right now';

  @override
  String get reportsPremiumGoToAnalysis => 'Go to Analysis';

  @override
  String get reportsPremiumNoLeagueBody =>
      'Curation is strict.\nCheck other leagues or view all picks.';

  @override
  String get reportsPremiumNoLeagueTitle => 'No premium pick for this league';

  @override
  String get reportsPremiumViewAll => 'View all picks';

  @override
  String get reportsComboTypeStable => 'Stable';

  @override
  String get reportsComboTypeHighIndex => 'High index';

  @override
  String get reportsComboEmptyTitle => 'No multi-match picks for this day';

  @override
  String get reportsComboEmptyBody => 'Try another date from the strip above.';

  @override
  String get reportsComboNoLeagueTitle => 'No picks for this league';

  @override
  String get reportsComboNoLeagueBody =>
      'Try another league or view all picks.';

  @override
  String get reportsComboViewAll => 'View all picks';

  @override
  String get reportsComboLockedTitle => 'Premium members only';

  @override
  String get reportsComboLockedBody => 'Subscribe to see the full combination.';

  @override
  String get reportsComboDetailTitle => 'Multi-match analysis';

  @override
  String get reportsTabAnalysis => 'Analysis';

  @override
  String get reportsTabMultiMatch => 'Multi-Match';

  @override
  String get reportsTabPremium => 'Premium';

  @override
  String get comboNotFound => 'No combination picks are available.';

  @override
  String get analyzeButton => 'Analyze';

  @override
  String get appName => 'TrendSoccer';

  @override
  String get appBarTierFree => 'FREE';

  @override
  String get appBarTierPremium => 'PREMIUM';

  @override
  String get appBarTierTrial => 'TRIAL';

  @override
  String get authLogIn => 'Log in';

  @override
  String get bottomNavTabFeed => 'Feed';

  @override
  String get bottomNavTabHome => 'Home';

  @override
  String get bottomNavTabMatches => 'Matches';

  @override
  String get bottomNavTabMenu => 'Menu';

  @override
  String get bottomNavTabReports => 'Reports';

  @override
  String get appGateMaintenanceRetryToast =>
      'Still under maintenance. Please try again shortly.';

  @override
  String get appGateMaintenanceSubtitle =>
      'We are working on it. Please try again shortly.';

  @override
  String get appGateMaintenanceTitle => 'Under maintenance';

  @override
  String get appGateUpdateButton => 'Update now';

  @override
  String get appGateUpdateSubtitle =>
      'A new version is available.\nUpdate to keep using TrendSoccer.';

  @override
  String get appGateUpdateTitle => 'Update required';

  @override
  String get apply => 'Apply';

  @override
  String get back => 'Back';

  @override
  String get billingLoadingSubtitle =>
      'Do not close the app.\nThis may take a moment.';

  @override
  String get billingLoadingTitle => 'Processing payment';

  @override
  String get baseballAiLoadFailed => 'Could not load premium analysis.';

  @override
  String get baseballAiLoading => 'Loading premium analysis...';

  @override
  String get baseballAiLoadingHint => 'First analysis may take 10–30 seconds.';

  @override
  String get baseballAiMatchAnalysis => 'AI match analysis';

  @override
  String get baseballAnalysisHeldUntilStarters =>
      'Analysis will be available once starting pitchers are announced.';

  @override
  String get baseballAiPremiumHint =>
      'In-depth AI analysis is available with a Premium subscription.';

  @override
  String get baseballAiSummary => 'AI analysis summary';

  @override
  String get baseballAiSummaryDefault => 'AI analysis data';

  @override
  String get baseballAiTabLoadFailed => 'Could not load AI analysis.';

  @override
  String get baseballAiTabLoading => 'Loading AI analysis...';

  @override
  String get baseballAiTabLoadingHint =>
      'First analysis may take about 10–15 seconds.';

  @override
  String get baseballAiWinProbabilityHint =>
      'AI-based win likelihood analysis.';

  @override
  String get baseballBaseline => 'Line';

  @override
  String get baseballBaselineDash => 'Line -';

  @override
  String baseballBaselineValue(String line) {
    return 'Line $line';
  }

  @override
  String get baseballConfidenceHigh => 'High';

  @override
  String get baseballConfidenceLow => 'Low';

  @override
  String get baseballConfidenceMedium => 'Medium';

  @override
  String get baseballEventFirstPitch => 'First Pitch';

  @override
  String get baseballEventInningChange => 'Inning Change';

  @override
  String get baseballH2hLastFive => 'Last 5 meetings';

  @override
  String get baseballH2hLoading => 'Loading head-to-head data...';

  @override
  String get baseballH2hNoData => 'No head-to-head data available.';

  @override
  String get baseballHomeAwayRecord => 'Home & away record';

  @override
  String get baseballHomeAwayWinRate => 'Strength (last 10)';

  @override
  String get baseballOddsBaseline => 'Line';

  @override
  String get baseballOverUnder => 'Score analysis';

  @override
  String baseballProductionBatterEdge(String team, String value) {
    return '$team batting edge ($value pts/game)';
  }

  @override
  String baseballProductionDefenseEdge(String team, String value) {
    return '$team pitching edge ($value runs/game)';
  }

  @override
  String get baseballPitcherAnalysis => 'Pitcher analysis';

  @override
  String get baseballPitcherAnalysisNoData =>
      'Pitcher analysis data unavailable.';

  @override
  String get baseballPitcherMatchup => 'Pitcher matchup analysis';

  @override
  String get baseballPitcherGeneric => 'Pitcher';

  @override
  String get baseballPitcherLeftHand => 'Left-handed pitcher';

  @override
  String get baseballPitcherRightHand => 'Right-handed pitcher';

  @override
  String get baseballRecent10 => 'Last 10 games';

  @override
  String get baseballRecentFormWinRate => 'Win rate';

  @override
  String get baseballStatAvg => 'AVG';

  @override
  String get baseballStatEra => 'ERA';

  @override
  String get baseballStatIp => 'IP';

  @override
  String get baseballStatK9 => 'K/9';

  @override
  String get baseballStatOps => 'OPS';

  @override
  String get baseballStatStrikeouts => 'K';

  @override
  String get baseballStatWhip => 'WHIP';

  @override
  String get baseballStatWinLoss => 'W-L';

  @override
  String get baseballStartingPitchersVersus => 'VS';

  @override
  String get baseballRelatedMatches => 'Related matches';

  @override
  String get baseballReliability => 'Reliability';

  @override
  String get baseballSeasonStats => 'Season team stats';

  @override
  String get baseballSeasonStatsNoData => 'Season stats unavailable.';

  @override
  String get baseballStatHits => 'Hits';

  @override
  String get baseballStatRunsAllowed => 'Runs allowed';

  @override
  String get baseballStatRunsScored => 'Runs scored';

  @override
  String get baseballSectionH2h => 'Head to Head';

  @override
  String get baseballSectionPitchers => 'Starting Pitchers';

  @override
  String get baseballSectionPitchersKo => 'Starting pitchers';

  @override
  String get baseballStrength => 'Strengths';

  @override
  String get baseballTeamProductivity => 'Team production';

  @override
  String get baseballTeamBattingAvg => 'Team batting avg.';

  @override
  String get baseballTeamEra => 'Team ERA';

  @override
  String get baseballTeamOps => 'Team OPS';

  @override
  String get baseballTeamProductivityComment =>
      'Team offensive production over the last 10 games.';

  @override
  String get baseballTeamWhip => 'Team WHIP';

  @override
  String get baseballWeakness => 'Weaknesses';

  @override
  String baseballWinsLosses(int wins, int losses) {
    return '${wins}W ${losses}L';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get cardCheckPick => 'Check analysis report →';

  @override
  String get cardCheckPickShort => 'Check now →';

  @override
  String get cardComboCheck => 'Check multi-match analysis →';

  @override
  String get cardComboCount => 'Matches';

  @override
  String get cardComboDefaultSubtitle => 'Check AI multi-match analysis.';

  @override
  String get cardComboLeagueHint => 'Daily AI multi-match for top leagues';

  @override
  String cardComboTodayCount(int count) {
    return '$count multi-match today';
  }

  @override
  String get cardHitRate => 'Accuracy';

  @override
  String get cardNextUpdate => 'Next update in';

  @override
  String get cardPickCount => 'Reports';

  @override
  String get cardStreak => 'Match streak';

  @override
  String get cardTodayCombo => 'Multi-match analysis';

  @override
  String get cardTodayPick => 'Today\'s featured match';

  @override
  String get cardUpdateLabel => 'Update';

  @override
  String get cardUpdating => 'Updating...';

  @override
  String get checkNow => 'Check Now';

  @override
  String get close => 'Close';

  @override
  String get comboAiDisclaimer =>
      'AI analysis is for reference only; results are not guaranteed.';

  @override
  String get comboAiSummary => 'Summary';

  @override
  String get comboAiWarning => 'Caution';

  @override
  String get comboAvgOdds => 'Average index';

  @override
  String comboFoldCount(int count) {
    return '$count matches';
  }

  @override
  String get comboFooterEstAccuracyCaption => 'Est. accuracy';

  @override
  String get comboFooterResultCaption => 'Result';

  @override
  String get comboMatchFail => 'Mismatch';

  @override
  String get comboMatchHit => 'Match';

  @override
  String get comboMatchPending => 'Pending';

  @override
  String comboPicksCompleted(int count) {
    return '$count multi-match analyses done';
  }

  @override
  String comboResultHitCount(int count) {
    return '$count match';
  }

  @override
  String comboResultInProgressCount(int count) {
    return '$count in progress';
  }

  @override
  String comboResultMissCount(int count) {
    return '$count mismatch';
  }

  @override
  String comboResultPartialCount(int count) {
    return '$count partial match';
  }

  @override
  String get comboSafeHitRate => 'Stable accuracy';

  @override
  String get comboStatusInProgress => 'In progress';

  @override
  String get comboStatusMiss => 'Mismatch';

  @override
  String get comboStatusPartial => 'Partial';

  @override
  String get comboTotalOdds => 'Total index';

  @override
  String comboLegPickWin(String team) {
    return '$team win';
  }

  @override
  String get comboLoadError => 'Could not load combinations';

  @override
  String get confidenceAccuracy => 'Match rate';

  @override
  String get confirm => 'OK';

  @override
  String get deleteAccountConfirm => 'Delete';

  @override
  String get deleteAccountHint => 'Type \'DELETE\' to confirm.';

  @override
  String get deleteAccountMessage =>
      'Deleting your account will permanently remove all data and cannot be undone.';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get emptyChangeDate => 'Change date';

  @override
  String get emptyDataSubtitle => 'Please check again later.';

  @override
  String get emptyDataTitle => 'No data available.';

  @override
  String get emptyPremiumPickSubtitle => 'Check again at 6 AM or 6 PM.';

  @override
  String get emptyPremiumPickTitle => 'No reports for today.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get errorLogin => 'Login failed.';

  @override
  String get errorNetwork => 'Please check your network connection.';

  @override
  String get errorPayment => 'Payment failed.';

  @override
  String get errorContactFailed => 'Failed to send inquiry';

  @override
  String errorCooldownActive(int daysLeft) {
    return 'Please try again in $daysLeft days';
  }

  @override
  String get errorDeleteConfirmation => 'Account deletion failed';

  @override
  String get errorAccountDeleted =>
      'This account was deleted. Please sign in with another account.';

  @override
  String get errorEmailRequired => 'Email is required';

  @override
  String get errorNaverLoginFailed => 'Naver login failed. Please try again.';

  @override
  String get errorNetworkTimeout => 'Please check your network connection';

  @override
  String get errorNotFound => 'Requested information not found';

  @override
  String get errorPaymentPending =>
      'Payment processing. Please try again shortly';

  @override
  String get errorPurchaseVerifyFailed => 'Payment verification failed';

  @override
  String get errorRateLimited => 'Too many requests. Please try again later';

  @override
  String get errorServerError => 'Server error. Please try again later';

  @override
  String get errorSubscriptionRequired => 'Premium subscription required';

  @override
  String get errorUnauthorized => 'Login required';

  @override
  String get errorUnknown => 'An error occurred';

  @override
  String get exitConfirm => 'Exit';

  @override
  String get exitDialogConfirm => 'Exit';

  @override
  String get exitDialogMessage => 'Are you sure you want to exit TrendSoccer?';

  @override
  String get exitDialogTitle => 'Exit App';

  @override
  String get fixtureEmpty => 'No fixtures available.';

  @override
  String get fixtureInterrupted => 'Interrupted';

  @override
  String get statusPostponed => 'PPD';

  @override
  String get statusInterrupted => 'SUSP';

  @override
  String get statusHalfTime => 'HT';

  @override
  String get statusCancelled => 'CANC';

  @override
  String baseballInningTop(int inning) {
    return 'Top $inning';
  }

  @override
  String baseballInningBottom(int inning) {
    return 'Bot $inning';
  }

  @override
  String get fixtureLive => 'LIVE';

  @override
  String get fixtureLiveEmpty => 'No live matches.';

  @override
  String get fixtureNoLiveMatches => 'No live matches in progress.';

  @override
  String get fixtureLiveEmptyAction => 'View Today\'s Matches';

  @override
  String get fixtureLoadFailed => 'Could not load fixtures.';

  @override
  String get fixtureNoMatchesOnDate => 'No matches scheduled on this date.';

  @override
  String get fixtureLeagueNoReportToast =>
      'This league does not provide match reports.';

  @override
  String get fixtureMatchReportScheduledOnlyToast =>
      'Match reports are only available for scheduled matches.';

  @override
  String get matchCancelled => 'Cancelled';

  @override
  String get matchPostponed => 'Postponed';

  @override
  String get fixtureStatusFinal => 'FT';

  @override
  String get fixtureViewAllMatches => 'View all matches';

  @override
  String get matchesEmptyLiveTitle => 'No live matches';

  @override
  String get matchesEmptyLiveBody => 'No matches are in progress right now.';

  @override
  String get matchesEmptyLiveAction => 'Browse all matches';

  @override
  String matchesEmptyDateTitle(String date) {
    return 'No matches on $date';
  }

  @override
  String get matchesEmptyDateAction => 'View other dates';

  @override
  String get matchesLeagueAiBadge => 'AI';

  @override
  String get formInvalidEmail => 'Please enter a valid email address';

  @override
  String get formRequired => 'This field is required';

  @override
  String get goBack => 'Go back';

  @override
  String get guestBannerCta => 'Start your free Premium trial →';

  @override
  String get guestBannerSubtitle => 'Analysis cards, Premium Reports, and more';

  @override
  String get guestBannerTitle => 'Sign up now for a 48-hour free trial';

  @override
  String get helpCenterEmail => 'Email';

  @override
  String get helpCenterIntro =>
      'Leave your inquiry and we will reply by email.';

  @override
  String get helpCenterMessage => 'Message';

  @override
  String get helpCenterName => 'Name';

  @override
  String get helpCenterSend => 'Send inquiry';

  @override
  String get helpCenterSubject => 'Subject';

  @override
  String get helpCenterSubmit => 'Submit';

  @override
  String get helpCenterSubmitFail => 'Failed to send. Please try again.';

  @override
  String get helpCenterSubmitSuccess => 'Your inquiry was sent successfully.';

  @override
  String get helpCenterSuccess => 'Your inquiry has been submitted.';

  @override
  String get helpCenterTitle => 'Help Center';

  @override
  String get helpScreenIntro =>
      'Tell us what you need help with. We usually reply within one business day.';

  @override
  String get helpInquirySentToast => 'Your inquiry has been sent.';

  @override
  String get helpEmailInvalid => 'Enter a valid email address';

  @override
  String get labelAway => 'Away';

  @override
  String get labelAwayShort => 'A';

  @override
  String get labelDraw => 'Draw';

  @override
  String get labelDrawShort => 'D';

  @override
  String get labelHome => 'Home';

  @override
  String get labelHomeShort => 'H';

  @override
  String get labelOdds => 'Index';

  @override
  String get labelPrediction => 'Analysis';

  @override
  String get labelRecommend => 'Analysis';

  @override
  String get labelOver => 'Over';

  @override
  String get labelUnder => 'Under';

  @override
  String get labelWin => 'Win';

  @override
  String get labelWinShort => 'W';

  @override
  String get resultDotLoss => 'L';

  @override
  String get languageSettingsTitle => 'Language';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get legalLoadError => 'Could not load content.';

  @override
  String liveMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get lockGuestSubtitle => 'Log in to continue';

  @override
  String get lockGuestTitle => 'Members only';

  @override
  String get lockPremiumAction => 'View plans';

  @override
  String loginErrorAccountDeleted(int days) {
    return 'This account was deleted. You can sign up again in $days days.';
  }

  @override
  String get loginErrorNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get loginErrorProfileLoadFailed =>
      'Signed in, but the profile could not load.';

  @override
  String get loginErrorTimeout => 'Sign-in timed out. Please try again.';

  @override
  String get loginErrorTryAgain => 'Sign-in failed. Please try again.';

  @override
  String get loginGuestButton => 'Continue as guest';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginNaver => 'Continue with Naver';

  @override
  String get loginNaverFailed => 'Naver sign-in failed. Please try again.';

  @override
  String get loginSheetDesc =>
      'From H2H records to in-depth team analysis, explore the data to complete your analysis.';

  @override
  String get loginSheetTitle => 'The smarter choice starts here.';

  @override
  String get loginStart => 'Get Started';

  @override
  String get loginSubtitle =>
      'AI-powered soccer and baseball analysis.\nElevate your analysis with precision data.';

  @override
  String get loginSuccess => 'Signed in successfully';

  @override
  String get loginTitle =>
      'Better Data,\nSmarter Analysis Reports,\nFor Your Choice.';

  @override
  String get matchAlarmDisabledMessage =>
      'Match alerts are turned off.\nEnable them in Menu > Notification Settings.';

  @override
  String get matchAlarmDisabledTitle => 'Match Alerts Disabled';

  @override
  String get matchAlarmSettingsTitle => 'Match alert settings';

  @override
  String get matchReportGradeGood => 'GOOD';

  @override
  String get matchReportGradePass => 'PASS';

  @override
  String get matchReportGradeReport => 'REPORT';

  @override
  String get matchReportLockLoginToView => 'Log in to view';

  @override
  String get matchReportLockPremiumContent => 'Premium content';

  @override
  String get matchReportPlaceholderHomeTeam => 'Home Team';

  @override
  String get matchReportTitle => 'Match Report';

  @override
  String get matchReportValueUnavailable => '-';

  @override
  String get menuAbout => 'About';

  @override
  String get menuAppVersion => 'App Version';

  @override
  String get menuDeleteAccount => 'Delete Account';

  @override
  String get menuDeleteAccountDialogMessage =>
      'All data is permanently removed. Type DELETE to confirm.';

  @override
  String get menuDeleteAccountDialogTitle => 'Delete account?';

  @override
  String get menuDeleteAccountErrorToast =>
      'Unable to delete account. Please try again.';

  @override
  String get menuDeleteAccountInputLabel => 'Confirmation';

  @override
  String get menuDeleteAccountSuccessToast => 'Account deleted successfully.';

  @override
  String get menuExplore => 'Explore';

  @override
  String get menuExploreSection => 'Explore';

  @override
  String get menuGuestBannerSubtitle =>
      'Sign up to unlock full analysis reports.';

  @override
  String get menuGuestBannerTitle => 'Start your 48-hour free trial';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuMatchPreview => 'Match Preview';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuOthers => 'Others';

  @override
  String get menuPlanFreeSubLabel => 'Basic analysis only';

  @override
  String get menuPlanPremiumActive => 'Premium active';

  @override
  String menuPlanPremiumCancelAccessUntil(String date) {
    return 'Cancellation pending · access until $date';
  }

  @override
  String menuPlanPremiumRenewsOn(String date) {
    return 'Renews on $date';
  }

  @override
  String menuPlanTrialSubLabel(int hours) {
    return 'Trial ends in $hours hours · billing unavailable during trial';
  }

  @override
  String get menuPlaySubscriptionsErrorToast =>
      'Unable to open Google Play subscriptions.';

  @override
  String menuPremiumExpiryDate(String date) {
    return 'Expires $date';
  }

  @override
  String get subscriptionCancelPending => 'Cancellation pending';

  @override
  String get subscriptionExpiryDate => 'Expiry date';

  @override
  String get subscriptionStartDate => 'Start date';

  @override
  String get subscriptionNextBilling => 'Next billing';

  @override
  String get menuPrivacyPolicy => 'Privacy Policy';

  @override
  String get menuProfile => 'Profile';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSettingsSection => 'Settings';

  @override
  String get menuSignOut => 'Sign Out';

  @override
  String get menuSignOutDialogMessage => 'You can sign back in anytime.';

  @override
  String get menuSignOutDialogTitle => 'Sign out?';

  @override
  String get menuSignOutErrorToast => 'Unable to sign out. Please try again.';

  @override
  String get menuSubscribe => 'Subscribe';

  @override
  String get menuSubscribeFree => 'Start Subscription';

  @override
  String get menuSubscribeInfoSection => 'Subscription';

  @override
  String get menuSubscribeManage => 'Manage Subscription';

  @override
  String get menuSubscribePrompt => 'Subscribe now to unlock premium data.';

  @override
  String get menuSubscribeTrial => 'Trial Active';

  @override
  String get menuTermsOfService => 'Terms of Service';

  @override
  String get menuTheme => 'Theme';

  @override
  String get menuThemeDark => 'Dark';

  @override
  String get menuThemeLight => 'Light';

  @override
  String get menuThemeSystem => 'System';

  @override
  String get menuTrialExpired => 'Trial expired';

  @override
  String menuTrialRemaining(int hours, int minutes) {
    return '${hours}h ${minutes}m remaining';
  }

  @override
  String get noMatchInfo => 'Match information unavailable';

  @override
  String get notificationAppGeneralDesc =>
      'Updates, announcements, service notices';

  @override
  String get notificationDisabledSnack =>
      'Notifications are disabled. Please enable them in Settings.';

  @override
  String get notificationMarketing => 'Marketing';

  @override
  String get notificationMarketingDesc => 'Promotions, events, discounts';

  @override
  String get notificationMatchEvents => 'Match Alerts';

  @override
  String get notificationMatchEventsDesc => 'Match event push notifications';

  @override
  String get notificationPermissionGoSettings => 'Go to Settings';

  @override
  String get notificationPermissionMessage =>
      'Notification permission is required.\nPlease enable it in Settings.';

  @override
  String get notificationPermissionMessageMatch =>
      'Notification permission is required to receive match alerts.\nPlease enable it in Settings.';

  @override
  String get notificationPermissionDisabledBanner =>
      'Notifications are disabled. Please enable them in Settings.';

  @override
  String get notificationPermissionTitle => 'Permission Required';

  @override
  String get notificationGeneral => 'General';

  @override
  String get notificationSettingsAnnouncements => 'Announcements';

  @override
  String get notificationSettingsAppAlerts => 'App alerts';

  @override
  String get notificationSettingsSportSubtitle =>
      'Applies to matches you turn alerts on for from now.';

  @override
  String get notificationAppAlerts => 'App Notifications';

  @override
  String get alarmKickoff => 'Kick-off';

  @override
  String get alarmGoal => 'Goal';

  @override
  String get alarmHalftime => 'Half-time';

  @override
  String get alarmFulltime => 'Full-time';

  @override
  String get alarmYellowCard => 'Yellow Card';

  @override
  String get alarmRedCard => 'Red Card';

  @override
  String get alarmSubstitution => 'Substitution';

  @override
  String get alarmGameStart => 'Game Start';

  @override
  String get alarmScore => 'Score';

  @override
  String get alarmHomerun => 'Home Run';

  @override
  String get alarmInningEnd => 'Inning End';

  @override
  String get alarmGameEnd => 'Game End';

  @override
  String get notificationTitle => 'Notification Settings';

  @override
  String get pitcherTbd => 'TBD';

  @override
  String planTicketExpiryDate(String date) {
    return 'Expiry date : $date';
  }

  @override
  String planTicketExpiryPendingDate(String date) {
    return 'Expiry date : $date';
  }

  @override
  String get planTicketFree => 'Free plan';

  @override
  String get planTicketFreeTitle => 'Free Plan';

  @override
  String get planTicketPremium => 'Premium plan';

  @override
  String get planTicketPremiumTitle => 'Premium Plan';

  @override
  String get planTicketManage => 'Manage subscription';

  @override
  String get planTicketRenew => 'Renew subscription';

  @override
  String get planTicketStart => 'Start subscription';

  @override
  String get planTicketTrialEnded => 'Trial ended';

  @override
  String planTicketStartDate(String date) {
    return 'Start date : $date';
  }

  @override
  String get planTicketTrial => 'Free trial plan';

  @override
  String planTicketTrialStartDate(String date) {
    return 'Trial start : $date';
  }

  @override
  String get planTicketTrialTitle => 'Trial Plan';

  @override
  String get planTicketUpgrade => 'Upgrade subscription';

  @override
  String get planTicketActionUpgrade => 'Upgrade';

  @override
  String get planTicketActionManage => 'Manage';

  @override
  String get stackBarWins => 'Wins';

  @override
  String get stackBarDraws => 'Draws';

  @override
  String get premiumBenefit24h => '24-hour priority analysis access';

  @override
  String get premiumBenefitBaseballAi => 'Baseball AI Analysis';

  @override
  String get premiumBenefitPremiumPick => 'Unlimited Premium Reports';

  @override
  String get premiumBenefitsTitle => 'Premium benefits';

  @override
  String get premiumComboLoadFailed =>
      'Could not load baseball AI multi-match analysis.';

  @override
  String get premiumExclusiveContent =>
      'This content is for Premium members only.';

  @override
  String get premiumExclusiveShort => 'Premium only';

  @override
  String get premiumNoHighConfidence => 'No high-confidence reports today';

  @override
  String get parserReasonBasis => 'Basis';

  @override
  String parserReasonPatternMatches(int count) {
    return 'Based on $count matches';
  }

  @override
  String parserReasonPowerDiffPoints(String value) {
    return '$value pts';
  }

  @override
  String get parserReasonProbEdge => 'Probability edge';

  @override
  String get premiumNonSubscriberSubtitle =>
      'AI Analysis, Premium Reports, Baseball Multi-Match\nAd-free experience';

  @override
  String get premiumNonSubscriberTitle => 'Premium Content';

  @override
  String get premiumPickLoadFailed => 'Could not load premium reports.';

  @override
  String get premiumSubscribeAfter => 'Available after subscribing.';

  @override
  String get premiumSubscribeBenefitsLine1 =>
      'Premium Reports and baseball multi-match analysis';

  @override
  String get premiumSubscribeNow => 'Subscribe Now';

  @override
  String get subscribeNow => 'Subscribe now';

  @override
  String get subscribeToUnlock => 'Subscribe to unlock full analysis';

  @override
  String get premiumSubscribeSheetBaseballDesc =>
      'Try AI data including win likelihood, score analysis, and season stats.';

  @override
  String get premiumSubscribeSheetSoccerDesc =>
      'Enjoy premium benefits such as H2H records and in-depth team analysis.';

  @override
  String get reportAuthorRole => 'Football data analyst';

  @override
  String get reportDetailLoadError => 'Could not load match preview.';

  @override
  String get reportEmptySubtitle =>
      'New previews will appear here when published.';

  @override
  String get reportEmptyTitle => 'No match previews yet.';

  @override
  String get reportListLoadError => 'Could not load match previews.';

  @override
  String get reportNotFoundSubtitle => 'Please select again from the list.';

  @override
  String get reportNotFoundTitle => 'Report not found.';

  @override
  String get retry => 'Retry';

  @override
  String get retryInProgress => 'Retrying…';

  @override
  String get save => 'Save';

  @override
  String get seasonCurrent => 'This season';

  @override
  String get seasonPrevious => 'Previous season';

  @override
  String get seeMore => 'See more →';

  @override
  String get selectMatchFromAnalysis => 'Select a match from the Analysis tab.';

  @override
  String get signOutMessage => 'Are you sure you want to sign out?';

  @override
  String get signOutSuccess => 'Signed out successfully.';

  @override
  String get signupAgreeAll => 'Agree to All';

  @override
  String get signupTermsAgree => 'Terms of Service Agreement';

  @override
  String get signupPrivacyAgree => 'Privacy Policy Agreement';

  @override
  String get signupMarketingAgree => 'Marketing Email Agreement';

  @override
  String get signupRequiredBadge => 'Required';

  @override
  String get signupOptionalBadge => 'Optional';

  @override
  String get signupFreeBenefit1 => 'View basic analysis data';

  @override
  String get signupFreeBenefit2 => 'Live scores and match schedules';

  @override
  String get signupFreeBenefit3 => 'Browse baseball Standard analysis';

  @override
  String get signupTrialBannerSubtitle =>
      '48-hour premium trial starts immediately after sign-up';

  @override
  String get signupWhatsNextBenefit1 =>
      'Auto switch to free plan after 48-hour trial';

  @override
  String get signupWhatsNextBenefit2 => 'Subscribe to premium for full access';

  @override
  String get signupCompleteAppBarTitle => 'Sign-up complete';

  @override
  String signupCompleteCountdown(int seconds) {
    return 'Redirecting to home in ${seconds}s';
  }

  @override
  String get signupCompleteBenefitAdFree => 'Ad-free experience';

  @override
  String get signupCompleteBenefitComboReports =>
      'Multi-match analysis reports';

  @override
  String get signupCompleteBenefitSoccerBaseball =>
      'Soccer and baseball premium analysis';

  @override
  String get signupCompleteFreeBenefit1 =>
      'Analysis opens 2 hours before kickoff';

  @override
  String get signupCompleteFreeBenefit2 => 'Basic analysis data';

  @override
  String get signupCompleteFreeBenefitsHeader => 'Free benefits';

  @override
  String signupCompleteHomeCountdown(int seconds) {
    return 'Moving to home in ${seconds}s';
  }

  @override
  String get signupCompletePremiumUpgrade => 'Upgrade to Premium';

  @override
  String get signupCompleteStartButton => 'Start now';

  @override
  String get signupCompleteStartPrompt => 'Start exploring TrendSoccer now.';

  @override
  String get signupCompleteSubtitle =>
      'Your 48-hour premium trial has started.';

  @override
  String get signupCompleteTrialSubtitle =>
      'Your 48-hour free trial has started';

  @override
  String get signupCompleteSuccessToast =>
      'Sign-up complete! Your premium trial has started.';

  @override
  String get signupCompleteTitle => 'Welcome!';

  @override
  String get signupCompleteTrialBanner =>
      'Your 48-hour free Premium trial has started!';

  @override
  String get signupCompleteWelcomeTitle => 'Welcome to TrendSoccer';

  @override
  String get signupErrorProcessing =>
      'An error occurred while processing sign-up.';

  @override
  String get signupMarketingOptional => 'Marketing Emails';

  @override
  String get signupOptional => '[Optional]';

  @override
  String get signupPageTitle => 'Sign up';

  @override
  String get signupRequired => '[Required]';

  @override
  String get signupSubmit => 'Sign Up';

  @override
  String get signupTermsAppBarTitle => 'Terms';

  @override
  String get signupTermsConsentMarketing => '[Optional] Marketing messages';

  @override
  String get signupTermsConsentPrivacy => '[Required] Privacy policy';

  @override
  String get signupTermsConsentTerms => '[Required] Terms of service';

  @override
  String get signupTermsContinueButton => 'Continue';

  @override
  String get signupTermsExitDialogLeave => 'Leave';

  @override
  String get signupTermsExitDialogMessage =>
      'Your account will not be activated until you agree to the terms.';

  @override
  String get signupTermsExitDialogStay => 'Stay';

  @override
  String get signupTermsExitDialogTitle => 'Leave sign-up?';

  @override
  String get signupTermsHeadingLine1 => 'To use the service,';

  @override
  String get signupTermsHeadingLine2 => 'please agree to the terms.';

  @override
  String get signupTermsHeadline => 'Agree to terms\nto get started';

  @override
  String get signupTermsHint =>
      'Sign-up completes when you agree to the required items.';

  @override
  String get signupTermsSubmitErrorToast =>
      'Unable to complete sign-up. Please try again.';

  @override
  String get signupTermsTitle => 'Terms & Conditions';

  @override
  String get signupView => 'View';

  @override
  String get skip => 'Skip';

  @override
  String get soccerAiPremiumOnly => 'Premium-only analysis';

  @override
  String get soccerAiPremiumSubscribeHint =>
      'In-depth H2H and team insights require Premium.';

  @override
  String get soccerAnalysisReasoning => 'Reasoning';

  @override
  String get soccerExtendedNoDataTitle => 'No data';

  @override
  String get soccerExtendedNoMarketIndicators =>
      'No market indicators reported for either team in this match.';

  @override
  String get soccerExtendedNoRecentForm =>
      'No recent form data reported for either team in this match.';

  @override
  String get soccerExtendedNoTeamInsights =>
      'No strengths or weaknesses reported for either team in this match.';

  @override
  String get soccerExtendedNoTeamStatistics =>
      'No team statistics reported for this match.';

  @override
  String get soccerPredictBlockPrediction => 'Prediction';

  @override
  String get soccerPredictBlockThreeMethod => '3-Method';

  @override
  String get soccerAnalysisResult => 'Analysis result';

  @override
  String get soccerAwayPower => 'Away power';

  @override
  String soccerAwayWinPct(int percent) {
    return 'Away $percent%';
  }

  @override
  String get soccerDraw => 'Draw';

  @override
  String get soccerEventFulltime => 'Full-time';

  @override
  String get soccerEventKickoff => 'Kick-off';

  @override
  String get soccerEventRedCard => 'Red Card';

  @override
  String get soccerEventSubstitution => 'Substitution';

  @override
  String get soccerEventYellowCard => 'Yellow Card';

  @override
  String get soccerFinalProbability => 'Final probability';

  @override
  String get soccerH2h => 'H2H';

  @override
  String get soccerH2hAllTime => 'All-time record';

  @override
  String get soccerH2hAvgGoals => 'Avg. goals';

  @override
  String get soccerH2hInsights => 'Match insights';

  @override
  String get soccerH2hLoading => 'Loading H2H analysis...';

  @override
  String get soccerH2hMaxScore => 'Highest score';

  @override
  String get soccerH2hRecent => 'Recent meetings';

  @override
  String soccerH2hMatchCount(int count) {
    return '($count matches)';
  }

  @override
  String get soccerH2hStatistics => 'Statistics';

  @override
  String get soccerHomePower => 'Home power';

  @override
  String soccerHomeWinPct(int percent) {
    return 'Home $percent%';
  }

  @override
  String get soccerMarketBtts => 'BTTS';

  @override
  String get soccerMarketCs => 'CS';

  @override
  String get soccerMarketFts => 'FTS';

  @override
  String get soccerMarketIndicators => 'Market indicators (last 10)';

  @override
  String get soccerMethod3 => '3-method analysis';

  @override
  String get soccerMethodFirstGoal => 'First goal';

  @override
  String get soccerMethodMinMax => 'MIN-MAX';

  @override
  String get soccerMethodPaCompare => 'P/A compare';

  @override
  String get soccerOddsAway => 'Away win';

  @override
  String get soccerOddsDraw => 'Draw';

  @override
  String get soccerOddsHome => 'Home win';

  @override
  String get soccerPowerDiff => 'Power diff.';

  @override
  String get soccerPowerIndex => 'Power index';

  @override
  String get soccerPremiumOnly => 'Premium only';

  @override
  String get soccerRecent10 => 'Last 10 games';

  @override
  String get soccerRecentForm => 'Recent form';

  @override
  String get soccerReasonFirstGoalAway => 'Away first-goal strength';

  @override
  String get soccerReasonFirstGoalHome => 'Home first-goal strength';

  @override
  String get soccerSeasonAway => 'Season away record';

  @override
  String get soccerSeasonHome => 'Season home record';

  @override
  String get soccerStatAnalyzedMatches => 'Matches analyzed';

  @override
  String get soccerStatComebackRate => 'Comeback rate';

  @override
  String get soccerStatFirstGoalRate => 'First-goal strength';

  @override
  String get soccerStatGoalDifference => 'Goal difference';

  @override
  String get soccerStatGoalLine => 'Goal line';

  @override
  String get soccerStatLosses => 'L';

  @override
  String get soccerStatOver15 => 'O 1.5';

  @override
  String get soccerStatOver25 => 'O 2.5';

  @override
  String get soccerStatOver35 => 'O 3.5';

  @override
  String get soccerStatPattern => 'Pattern stats';

  @override
  String get soccerStatTeamInsights => 'Team insights';

  @override
  String get soccerStatTeamStats => 'Team statistics';

  @override
  String get soccerStatWinProb => 'Win likelihood';

  @override
  String get soccerStatWinRate => 'Strength analysis';

  @override
  String get soccerStatWins => 'W';

  @override
  String get subscribeAlreadyOwned =>
      'You are already subscribed. Checking your subscription.';

  @override
  String get subscribeBack => 'Go back';

  @override
  String get subscribeDiscount => '33% OFF';

  @override
  String get subscribeFailAttemptAmount => 'Attempted amount';

  @override
  String get subscribeFailDescription =>
      'Please try again or use another payment method.';

  @override
  String get subscribeFailErrorCode => 'Error code';

  @override
  String get subscribeFailRetry => 'Try Again';

  @override
  String get subscribeFailTitle => 'Payment Failed';

  @override
  String get subscribeFreeBenefit1 =>
      'Analysis cards open 2 hours before kickoff';

  @override
  String get subscribeFreeBenefit2 => 'Basic match analysis and stats';

  @override
  String get subscribeFreeBenefit3 => 'Live scores and fixtures';

  @override
  String get subscribeFreeBenefit4 => 'Includes ads';

  @override
  String get subscribeGoHome => 'Back to home';

  @override
  String get subscribeHeader => 'Get Full Access To The AI Assistant';

  @override
  String get subscribeHeaderLine1 => 'Get Full Access To';

  @override
  String get subscribeHeaderLine2 => 'The AI Assistant !';

  @override
  String get subscribeIapCannotStart => 'Could not start Google Play billing.';

  @override
  String get subscribeIapPreparing => 'Preparing Google Play billing...';

  @override
  String get subscribeIapProcessing => 'Processing Google Play payment...';

  @override
  String get subscribeIapRestoring => 'Checking existing subscription...';

  @override
  String get subscribeIapUnavailable => 'Google Play billing is unavailable.';

  @override
  String get subscribeIapVerifyPending =>
      'Payment completed but verification is pending. Please restart the app shortly.';

  @override
  String get subscribeManageOnPlay => 'Manage on Google Play';

  @override
  String subscribePeriodMonths(int months) {
    return '$months months';
  }

  @override
  String get subscribePlanFree => 'Free';

  @override
  String get subscribePlanMonthly => '1 Month';

  @override
  String get subscribePlanQuarterly => '3 Months';

  @override
  String get subscribePremiumActive => 'Premium Active';

  @override
  String get subscribePremiumBenefit1 =>
      '24-hour priority access to all analysis';

  @override
  String get subscribePremiumBenefit2 => 'Unlimited soccer Premium Reports';

  @override
  String get subscribePremiumBenefit3 => 'Full baseball AI analysis';

  @override
  String get subscribePremiumBenefit4 => 'Baseball multi-match';

  @override
  String get subscribePremiumBenefit5 => 'Ad-free experience';

  @override
  String subscribePremiumExpiry(String date) {
    return 'Expires: $date';
  }

  @override
  String get subscribePremiumMessage =>
      'You are currently subscribed to Premium.';

  @override
  String get subscribePriceMonthly => '₩4,900';

  @override
  String get subscribePriceQuarterly => '₩9,900';

  @override
  String get subscribeReceiptAmount => 'Amount paid';

  @override
  String get subscribeReceiptPlan => 'Plan';

  @override
  String get subscribeSelectProduct => 'Choose a plan';

  @override
  String get subscribeStartPremium => 'Start Premium';

  @override
  String get subscribeStartPremiumArrow => 'Start Premium →';

  @override
  String get subscribeSuccessCTA => 'Start Premium Analysis';

  @override
  String get subscribeSuccessComplete => 'Subscription complete.';

  @override
  String get subscribeSuccessSubtitle => 'Start enjoying Premium benefits now.';

  @override
  String get subscribeSuccessTitle => 'Payment Complete';

  @override
  String get subscribeTrialActive => '48-Hour Premium Trial Active';

  @override
  String get subscribeTrialMessage => 'Subscribe after your trial ends.';

  @override
  String subscribeTrialRemaining(int hours, int minutes) {
    return 'Remaining: ${hours}h ${minutes}m';
  }

  @override
  String get subscribeTrialRemainingZero => 'Remaining: 0h 0m';

  @override
  String get subscribeUpdating => 'Updating subscription...';

  @override
  String get tabFixture => 'Fixture';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabPremium => 'Premium';

  @override
  String get tabTrend => 'Trend';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeSettingsTitle => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get today => 'Today';

  @override
  String get trendEmptySubtitle1 =>
      'Official leagues are currently on a break.';

  @override
  String get trendEmptySubtitle2 =>
      'Stay tuned for smarter analysis when the season resumes.';

  @override
  String get trendEmptyTitle => 'Awaiting the Next Match';

  @override
  String get trendNoSoccerScheduled => 'No soccer matches scheduled.';

  @override
  String get trendPremiumAnalysis => 'Premium Analysis';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get matchReportBlockLoadError => 'Could not load';

  @override
  String get matchReportBlockUnavailable =>
      'This section is unavailable right now';
}
