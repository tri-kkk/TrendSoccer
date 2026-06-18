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
      'TrendSoccer predicts match flow with AI-powered real-time analysis. From the Premier League to the Champions League, experience every big match with expert-level insights.';

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
  String get aboutFeatureOddsDesc => 'Market monitoring based on odds movement';

  @override
  String get aboutFeatureOddsTitle => 'Real-time odds analysis';

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
  String get alarmSecondHalf => '2nd Half Start';

  @override
  String get analysisAiAnalyzing => 'AI analysis in progress...';

  @override
  String get analysisAiWaitHint => 'Please wait (about 5–10 seconds)';

  @override
  String get analysisCardView => 'View analysis';

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
  String get analysisPremiumPick => 'Premium Analysis';

  @override
  String get analysisTabBaseball => 'Baseball Analysis';

  @override
  String get analysisTabSoccer => 'Soccer Analysis';

  @override
  String get analysisToday => 'Today';

  @override
  String get analyzeButton => 'Analyze';

  @override
  String get appName => 'TrendSoccer';

  @override
  String get apply => 'Apply';

  @override
  String get back => 'Back';

  @override
  String get baseballAiLoadFailed => 'Could not load premium analysis.';

  @override
  String get baseballAiLoading => 'Loading premium analysis...';

  @override
  String get baseballAiLoadingHint => 'First analysis may take 10–30 seconds.';

  @override
  String get baseballAiMatchAnalysis => 'AI match analysis';

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
      'AI-based win probability analysis.';

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
  String get baseballEventGameEnd => 'Game End';

  @override
  String get baseballEventHomerun => 'Home Run';

  @override
  String get baseballEventInningChange => 'Inning Change';

  @override
  String get baseballEventScore => 'Score';

  @override
  String get baseballH2hLoading => 'Loading head-to-head data...';

  @override
  String get baseballH2hNoData => 'No head-to-head data available.';

  @override
  String get baseballHomeAwayRecord => 'Home & away record';

  @override
  String get baseballHomeAwayWinRate => 'Win rate (last 10)';

  @override
  String get baseballOddsBaseline => 'Line';

  @override
  String get baseballOverUnder => 'Over/under';

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
  String get baseballSectionOdds => 'Odds';

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
  String get baseballWinProbability => 'Win probability';

  @override
  String baseballWinsLosses(int wins, int losses) {
    return '${wins}W ${losses}L';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get cardCheckPick => 'Check today\'s pick →';

  @override
  String get cardCheckPickShort => 'Check now →';

  @override
  String get cardComboCheck => 'Check today\'s combo →';

  @override
  String get cardComboCount => 'Combos';

  @override
  String get cardComboDefaultSubtitle => 'Check today\'s AI combo.';

  @override
  String get cardComboLeagueHint => 'Daily AI combos for top leagues';

  @override
  String cardComboTodayCount(int count) {
    return '$count combos today';
  }

  @override
  String get cardHitRate => 'Hit rate';

  @override
  String get cardNextUpdate => 'Next update in';

  @override
  String get cardPickCount => 'Picks';

  @override
  String get cardStreak => 'Current streak';

  @override
  String get cardTodayCombo => 'Today\'s combo';

  @override
  String get cardTodayPick => 'Today\'s pick';

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
  String get comboAvgOdds => 'Avg. odds';

  @override
  String get comboComboCount => 'Combos';

  @override
  String get comboDashboardToday => 'Today';

  @override
  String comboFoldCount(int count) {
    return '$count COMBO';
  }

  @override
  String get comboHighOdds => 'High odds';

  @override
  String get comboMatchFail => 'Miss';

  @override
  String get comboMatchHit => 'Hit';

  @override
  String get comboMatchPending => 'Pending';

  @override
  String comboPicksCompleted(int count) {
    return '$count AI combos analyzed';
  }

  @override
  String get comboReliability => 'Reliability';

  @override
  String comboResultHitCount(int count) {
    return '$count hit';
  }

  @override
  String comboResultInProgressCount(int count) {
    return '$count in progress';
  }

  @override
  String comboResultMissCount(int count) {
    return '$count miss';
  }

  @override
  String comboResultPartialCount(int count) {
    return '$count partial';
  }

  @override
  String get comboSafe => 'Safe';

  @override
  String get comboSafeHitRate => 'Safe hit rate';

  @override
  String get comboStatusHit => 'Hit';

  @override
  String get comboStatusInProgress => 'In progress';

  @override
  String get comboStatusMiss => 'Miss';

  @override
  String get comboStatusPartial => 'Partial';

  @override
  String get comboTotalOdds => 'Total odds';

  @override
  String get comboTypeHigh => 'High odds';

  @override
  String get comboTypeSafe => 'Safe';

  @override
  String get comboWin => 'Win';

  @override
  String get confidenceAccuracy => 'Accuracy';

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
  String get emptyPremiumPickTitle => 'No picks for today.';

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
  String get exitMessage => 'Are you sure you want to exit TrendSoccer?';

  @override
  String get exitTitle => 'Exit App';

  @override
  String get exitToastMessage => 'Press back again to exit';

  @override
  String get filterAll => 'All';

  @override
  String get fixtureCancelled => 'Cancelled';

  @override
  String get fixtureEmpty => 'No fixtures available.';

  @override
  String get fixtureInterrupted => 'Interrupted';

  @override
  String get statusPostponed => 'PPD';

  @override
  String get statusInterrupted => 'SUSP';

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
  String get fixtureNoMatches => 'No matches';

  @override
  String get fixtureNoMatchesOnDate => 'No matches scheduled on this date.';

  @override
  String get fixturePostponed => 'Postponed';

  @override
  String get matchCancelled => 'Cancelled';

  @override
  String get matchPostponed => 'Postponed';

  @override
  String get fixtureStatusFinal => 'FT';

  @override
  String get fixtureViewAllMatches => 'View all matches';

  @override
  String get forceUpdateButton => 'Update';

  @override
  String get forceUpdateMessage =>
      'An update with new features and stability improvements is available.';

  @override
  String get forceUpdateSkip => 'Skip';

  @override
  String get forceUpdateTitle => 'Update Required';

  @override
  String get formInvalidEmail => 'Please enter a valid email address';

  @override
  String get formRequired => 'This field is required';

  @override
  String get goBack => 'Go back';

  @override
  String get guestBannerCta => 'Start your free Premium trial →';

  @override
  String get guestBannerSubtitle => 'Analysis cards, Premium Picks, and more';

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
  String get labelOdds => 'Odds';

  @override
  String get labelPrediction => 'Prediction';

  @override
  String get labelRecommend => 'Pick';

  @override
  String get labelOver => 'Over';

  @override
  String get labelUnder => 'Under';

  @override
  String get labelWin => 'Win';

  @override
  String get labelWinShort => 'W';

  @override
  String get languageSettingsTitle => 'Language';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get maintenanceTitle => 'Under Maintenance';

  @override
  String get maintenanceSubtitle => 'Please try again later.';

  @override
  String get legalLoadError => 'Could not load content.';

  @override
  String liveMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get loadMatchesFailed => 'Could not load matches.';

  @override
  String get loginAppBarTitle => 'Log In';

  @override
  String get loginGoogle => 'Continue with Google';

  @override
  String get loginNaver => 'Continue with Naver';

  @override
  String get loginNaverFailed => 'Naver sign-in failed. Please try again.';

  @override
  String get loginSheetDesc =>
      'From H2H records to in-depth team analysis, explore the data to complete your predictions.';

  @override
  String get loginSheetTitle => 'The smarter choice starts here.';

  @override
  String get loginStart => 'Get Started';

  @override
  String get loginSubtitle =>
      'AI-powered soccer and baseball analysis.\nElevate your predictions with precision data.';

  @override
  String get loginSuccess => 'Signed in successfully';

  @override
  String get loginTitle => 'Better Data,\nSmarter Picks,\nFor Your Choice.';

  @override
  String get matchAlarmDisabledGoSettings => 'Go to Settings';

  @override
  String get matchAlarmDisabledMessage =>
      'Match alerts are turned off.\nEnable them in Menu > Notification Settings.';

  @override
  String get matchAlarmDisabledTitle => 'Match Alerts Disabled';

  @override
  String get matchAlarmSettingsTitle => 'Match alert settings';

  @override
  String get matchReportTitle => 'Match report';

  @override
  String get menuAbout => 'About';

  @override
  String get menuAppVersion => 'App Version';

  @override
  String get menuDeleteAccount => 'Delete Account';

  @override
  String get menuExplore => 'Explore';

  @override
  String get menuExploreSection => 'Explore';

  @override
  String get menuHelpCenter => 'Help Center';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuMatchPreview => 'Match Preview';

  @override
  String get menuNotification => 'Notification';

  @override
  String get menuOthers => 'Others';

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
  String get menuSubscribe => 'Subscribe';

  @override
  String get menuSubscribeFree => 'Start Subscription';

  @override
  String get menuSubscribeInfoSection => 'Subscription';

  @override
  String get menuSubscribeManage => 'Manage Subscription';

  @override
  String get menuSubscribeManageTitle => 'Manage Subscription';

  @override
  String get menuSubscribePrompt => 'Subscribe now to unlock premium data.';

  @override
  String get menuSubscribeTitle => 'Subscribe';

  @override
  String get menuSubscribeTrial => 'Trial Active';

  @override
  String get menuTermsOfService => 'Terms of Service';

  @override
  String get menuTheme => 'Theme';

  @override
  String get menuTrialExpired => 'Trial expired';

  @override
  String menuTrialRemaining(int hours, int minutes) {
    return '${hours}h ${minutes}m remaining';
  }

  @override
  String get networkErrorMessage => 'Please check your network connection.';

  @override
  String get noMatchInfo => 'Match information unavailable';

  @override
  String get notificationAppGeneral => 'App Notifications';

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
  String get notificationSettings => 'Notification';

  @override
  String get notificationGeneral => 'General';

  @override
  String get notificationSoccer => 'Soccer';

  @override
  String get notificationBaseball => 'Baseball';

  @override
  String get notificationAppAlerts => 'App Notifications';

  @override
  String get alarmKickoff => 'Kick-off';

  @override
  String get alarmGoal => 'Goal';

  @override
  String get alarmHalftime => 'Half-time';

  @override
  String get alarmSecondHalfStart => '2nd Half Start';

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
  String get pickDirectionAway => 'Away';

  @override
  String get pickDirectionDraw => 'Draw';

  @override
  String get pickDirectionHome => 'Home';

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
  String planTicketTrialRemaining(int hours, int minutes) {
    return '${hours}h ${minutes}m remaining';
  }

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
  String get premiumBenefit24h => '24-hour priority analysis access';

  @override
  String get premiumBenefitBaseballAi => 'Baseball AI Analysis';

  @override
  String get premiumBenefitPremiumPick => 'Unlimited PREMIUM PICK';

  @override
  String get premiumBenefitsTitle => 'Premium benefits';

  @override
  String get premiumComboLoadFailed => 'Could not load baseball AI combos.';

  @override
  String get premiumExclusiveContent =>
      'This content is for Premium members only.';

  @override
  String get premiumExclusiveShort => 'Premium only';

  @override
  String get premiumNoHighConfidence => 'No high-confidence picks today';

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
      'AI Analysis, PREMIUM PICK, Baseball Combos\nAd-free experience';

  @override
  String get premiumNonSubscriberTitle => 'Premium Content';

  @override
  String get premiumPickLoadFailed => 'Could not load premium picks.';

  @override
  String get premiumSubscribeAfter => 'Available after subscribing.';

  @override
  String get premiumSubscribeBenefitsLine1 =>
      'PREMIUM PICK and baseball AI combo analysis';

  @override
  String get premiumSubscribeNow => 'Subscribe Now';

  @override
  String get subscribeNow => 'Subscribe now';

  @override
  String get subscribeToUnlock => 'Subscribe to unlock full predictions';

  @override
  String get premiumSubscribeSheetBaseballDesc =>
      'Try AI analysis data including win probability, over/under, and season stats.';

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
  String get reportPremiumOnlyMessage =>
      'Subscribe to view AI analysis results';

  @override
  String get reportPremiumOnlyTitle => 'Premium members only';

  @override
  String get reportTabAiAnalysis => 'AI Analysis';

  @override
  String get reportTabPremium => 'Premium';

  @override
  String get reportTabStandard => 'Standard';

  @override
  String get retry => 'Retry';

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
  String get signOutConfirm => 'Sign Out';

  @override
  String get signOutMessage => 'Are you sure you want to sign out?';

  @override
  String get signOutSuccess => 'Signed out successfully.';

  @override
  String get signOutTitle => 'Sign Out';

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
  String get signupCompleteFreeBenefit1 =>
      'Analysis opens 2 hours before kickoff';

  @override
  String get signupCompleteFreeBenefit2 => 'Basic analysis data';

  @override
  String get signupCompleteFreeBenefit3 => 'Live scores and fixtures';

  @override
  String get signupCompleteFreeBenefitsHeader => 'Free benefits';

  @override
  String get signupCompleteGoHome => 'Go to Home';

  @override
  String get signupCompletePremiumBenefit1 =>
      '24-hour priority analysis access';

  @override
  String get signupCompletePremiumBenefit2 => 'Unlimited PREMIUM PICK';

  @override
  String get signupCompletePremiumBenefit3 => 'Baseball AI Analysis';

  @override
  String get signupCompletePremiumBenefitsHeader => 'Premium benefits';

  @override
  String get signupCompletePremiumUpgrade => 'Upgrade to Premium';

  @override
  String get signupCompleteStartPrompt => 'Start exploring TrendSoccer now.';

  @override
  String get signupCompleteSubtitle =>
      'Your 48-hour premium trial has started.';

  @override
  String get signupCompleteSuccessToast =>
      'Sign-up complete! Your premium trial has started.';

  @override
  String get signupCompleteTitle => 'Welcome!';

  @override
  String get signupCompleteTrialBanner =>
      'Your 48-hour free Premium trial has started!';

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
  String get signupPrivacyRequired => 'Privacy Policy';

  @override
  String get signupRequired => '[Required]';

  @override
  String get signupSubmit => 'Sign Up';

  @override
  String get signupTermsHeadingLine1 => 'To use the service,';

  @override
  String get signupTermsHeadingLine2 => 'please agree to the terms.';

  @override
  String get signupTermsHint =>
      'Sign-up completes when you agree to the required items.';

  @override
  String get signupTermsRequired => 'Terms of Service';

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
  String get soccerEventGoal => 'Goal';

  @override
  String get soccerEventHalftime => 'Half-time';

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
  String get soccerReasonFirstGoalAway => 'Away first-goal win rate';

  @override
  String get soccerReasonFirstGoalHome => 'Home first-goal win rate';

  @override
  String get soccerSeasonAway => 'Season away record';

  @override
  String get soccerSeasonHome => 'Season home record';

  @override
  String get soccerStatAnalyzedMatches => 'Matches analyzed';

  @override
  String get soccerStatComebackRate => 'Comeback rate';

  @override
  String get soccerStatFirstGoalRate => 'First-goal win rate';

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
  String get soccerStatPowerDiff => 'Power diff.';

  @override
  String get soccerStatTeamInsights => 'Team insights';

  @override
  String get soccerStatTeamStats => 'Team statistics';

  @override
  String get soccerStatWinProb => 'Win probability';

  @override
  String get soccerStatWinRate => 'Win rate';

  @override
  String get soccerStatWins => 'W';

  @override
  String get sportBaseball => 'Baseball';

  @override
  String get sportSoccer => 'Soccer';

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
  String get subscribeFailMessage => 'Payment failed.';

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
  String get subscribePlanPremium => 'Premium';

  @override
  String get subscribePlanQuarterly => '3 Months';

  @override
  String get subscribePremiumActive => 'Premium Active';

  @override
  String get subscribePremiumBenefit1 =>
      '24-hour priority access to all analysis';

  @override
  String get subscribePremiumBenefit2 => 'Unlimited soccer Premium Picks';

  @override
  String get subscribePremiumBenefit3 => 'Full baseball AI analysis';

  @override
  String get subscribePremiumBenefit4 => 'Baseball combo picks';

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
  String get tabAnalysis => 'Analysis';

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
  String get todayCombination => 'Today\'s Combination';

  @override
  String get todayPremiumPick => 'Today\'s Pick';

  @override
  String get trendBaseballAnalysis => 'Baseball Analysis';

  @override
  String get trendEmptySubtitle1 =>
      'Official leagues are currently on a break.';

  @override
  String get trendEmptySubtitle2 =>
      'Stay tuned for our smarter picks when the season resumes.';

  @override
  String get trendEmptyTitle => 'Awaiting the Next Match';

  @override
  String get trendNoBaseballScheduled => 'No baseball games scheduled.';

  @override
  String get trendNoSoccerScheduled => 'No soccer matches scheduled.';

  @override
  String get trendPremiumAnalysis => 'Premium Analysis';

  @override
  String get trendSoccerAnalysis => 'Soccer Analysis';

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
}
