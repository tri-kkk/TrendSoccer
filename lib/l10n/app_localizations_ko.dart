// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get aboutContactEmail => 'tikilab2025@gmail.com';

  @override
  String get aboutContactSection => '컨택 & 서포트';

  @override
  String get aboutContactWebsite => 'trendsoccer.com';

  @override
  String get aboutDescription =>
      'TrendSoccer는 AI 기반 실시간 분석으로 경기 흐름을 예측합니다. 프리미어리그부터 챔피언스리그까지, 모든 빅매치를 전문가 수준의 인사이트로 경험하세요.';

  @override
  String get aboutFeatureAiDesc => '4시즌 방대한 경기 데이터를 기반으로 구축';

  @override
  String get aboutFeatureAiTitle => 'AI 기반 분석';

  @override
  String get aboutFeatureLeaguesDesc => '주요 6대 리그 종합 데이터 지원';

  @override
  String get aboutFeatureLeaguesTitle => '글로벌 리그 지원';

  @override
  String get aboutFeatureOddsDesc => '배당 무브먼트에 따른 마켓 모니터링';

  @override
  String get aboutFeatureOddsTitle => '실시간 배당 분석';

  @override
  String get aboutFeaturesSection => '주요 기능';

  @override
  String get aboutTagline => '데이터로 읽는 축구의 흐름';

  @override
  String get aboutVisionSection => '비전';

  @override
  String get aboutVisionText => '축구 팬들이 경기를 더 깊이 이해하고 즐길 수 있도록 돕습니다.';

  @override
  String get accessLockLoginRequired => '로그인 후 확인 가능합니다.';

  @override
  String get accessLockOpens24HoursBefore => '경기 시작 24시간 전에 오픈됩니다.';

  @override
  String get accessLockOpensOneHourBefore => '경기 시작 1시간 전에 오픈됩니다.';

  @override
  String get accessLockPremium24h => '프리미엄 구독 시 경기 시작 24시간 전부터 확인 가능합니다.';

  @override
  String accessUnlockDaysHours(int days, int hours) {
    return '$days일 $hours시간 후 오픈';
  }

  @override
  String accessUnlockHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분 후 오픈';
  }

  @override
  String accessUnlockMinutes(int minutes) {
    return '$minutes분 후 오픈';
  }

  @override
  String get accessUnlockViewAnalysis => '분석보기';

  @override
  String get alarmToggleTitle => '알림 받기';

  @override
  String alarmEnabledToast(String homeTeam, String awayTeam) {
    return '$homeTeam - $awayTeam의 경기 알림이 활성화 되었습니다';
  }

  @override
  String alarmDisabledToast(String homeTeam, String awayTeam) {
    return '$homeTeam - $awayTeam의 경기 알림이 비활성화 되었습니다';
  }

  @override
  String get alarmSecondHalf => '후반전 시작';

  @override
  String get analysisAiAnalyzing => 'AI 분석 중...';

  @override
  String get analysisAiWaitHint => '잠시만 기다려주세요 (약 5–10초)';

  @override
  String get analysisCardView => '분석보기';

  @override
  String get analysisCardViewAnalysis => '분석하기';

  @override
  String get analysisEmpty => '분석 데이터가 없습니다.';

  @override
  String get analysisLoadFailed => '분석 데이터를 불러오지 못했습니다.';

  @override
  String get analysisLoadMatchesFailed => '경기 목록을 불러오지 못했습니다.';

  @override
  String get analysisMatchInfoLoadFailed => '경기 정보를 불러오지 못했습니다.';

  @override
  String get analysisMatchInfoLoading => '경기 정보 로딩 중...';

  @override
  String get analysisNoBaseballScheduled => '예정된 야구 경기가 없습니다.';

  @override
  String get analysisNoMatches => '경기가 없습니다';

  @override
  String get analysisNoMatchesFilterHint =>
      '오늘 예정된 경기가 없거나 필터 조건에 맞는 경기가 없습니다.';

  @override
  String get analysisNoResult => '분석 결과가 없습니다.';

  @override
  String get analysisPremiumPick => '프리미엄 분석';

  @override
  String get analysisTabBaseball => '야구 분석';

  @override
  String get analysisTabSoccer => '축구 분석';

  @override
  String get analysisToday => '오늘';

  @override
  String get analyzeButton => 'Analyze';

  @override
  String get appName => '트렌드사커';

  @override
  String get apply => '적용하기';

  @override
  String get back => '뒤로';

  @override
  String get baseballAiLoadFailed => '프리미엄 분석을 불러오지 못했습니다.';

  @override
  String get baseballAiLoading => '프리미엄 분석 로딩 중...';

  @override
  String get baseballAiLoadingHint => '최초 분석 시 10–30초 정도 소요될 수 있습니다.';

  @override
  String get baseballAiMatchAnalysis => 'AI 경기 분석';

  @override
  String get baseballAiPremiumHint => 'AI 기반 심층 분석은 프리미엄 구독 후 이용할 수 있습니다.';

  @override
  String get baseballAiSummary => 'AI 분석 요약';

  @override
  String get baseballAiSummaryDefault => 'AI 분석 데이터';

  @override
  String get baseballAiTabLoadFailed => 'AI 분석을 불러오지 못했습니다.';

  @override
  String get baseballAiTabLoading => 'AI 분석 로딩 중...';

  @override
  String get baseballAiTabLoadingHint => '최초 분석 시 10–15초 정도 소요될 수 있습니다.';

  @override
  String get baseballAiWinProbabilityHint => 'AI 기반 승리 확률 분석입니다.';

  @override
  String get baseballBaseline => '기준선';

  @override
  String get baseballBaselineDash => '기준선 -';

  @override
  String baseballBaselineValue(String line) {
    return '기준선 $line';
  }

  @override
  String get baseballConfidenceHigh => '높음';

  @override
  String get baseballConfidenceLow => '낮음';

  @override
  String get baseballConfidenceMedium => '보통';

  @override
  String get baseballEventFirstPitch => '경기 시작';

  @override
  String get baseballEventGameEnd => '경기 종료';

  @override
  String get baseballEventHomerun => '홈런';

  @override
  String get baseballEventInningChange => '이닝 종료';

  @override
  String get baseballEventScore => '득점';

  @override
  String get baseballH2hLoading => '상대 전적 데이터를 불러오는 중...';

  @override
  String get baseballH2hNoData => '상대 전적 데이터가 없습니다.';

  @override
  String get baseballHomeAwayRecord => '홈&원정 성적';

  @override
  String get baseballHomeAwayWinRate => '최근 10경기 승률';

  @override
  String get baseballOddsBaseline => '기준점';

  @override
  String get baseballOverUnder => '오버&언더';

  @override
  String baseballProductionBatterEdge(String team, String value) {
    return '$team 타선 우세 ($value점/경기)';
  }

  @override
  String baseballProductionDefenseEdge(String team, String value) {
    return '$team 수비 우세 ($value실점/경기)';
  }

  @override
  String get baseballPitcherAnalysis => '투수 분석';

  @override
  String get baseballPitcherAnalysisNoData => '투수 분석 데이터를 불러올 수 없습니다.';

  @override
  String get baseballPitcherMatchup => '투수 매치업 분석';

  @override
  String get baseballPitcherGeneric => '투수';

  @override
  String get baseballPitcherLeftHand => '좌완 투수';

  @override
  String get baseballPitcherRightHand => '우완 투수';

  @override
  String get baseballRecent10 => '최근 10경기';

  @override
  String get baseballRelatedMatches => '관련 경기';

  @override
  String get baseballReliability => '신뢰도';

  @override
  String get baseballSeasonStats => '시즌 팀 통계';

  @override
  String get baseballSeasonStatsNoData => '시즌 통계 데이터를 불러올 수 없습니다.';

  @override
  String get baseballStatHits => '안타';

  @override
  String get baseballStatRunsAllowed => '실점';

  @override
  String get baseballStatRunsScored => '득점';

  @override
  String get baseballSectionH2h => 'Head to Head';

  @override
  String get baseballSectionOdds => 'Odds';

  @override
  String get baseballSectionPitchers => 'Starting Pitchers';

  @override
  String get baseballSectionPitchersKo => '선발 투수';

  @override
  String get baseballStrength => '강점';

  @override
  String get baseballTeamProductivity => '팀 생산성';

  @override
  String get baseballTeamBattingAvg => '팀 타율';

  @override
  String get baseballTeamEra => '팀 방어율';

  @override
  String get baseballTeamOps => '팀 OPS';

  @override
  String get baseballTeamProductivityComment => '최근 10경기 팀 공격 생산성 지표입니다.';

  @override
  String get baseballTeamWhip => '팀 WHIP';

  @override
  String get baseballWeakness => '약점';

  @override
  String get baseballWinProbability => '승리 확률';

  @override
  String baseballWinsLosses(int wins, int losses) {
    return '$wins승 $losses패';
  }

  @override
  String get cancel => '취소';

  @override
  String get cardCheckPick => '오늘의 픽 확인하기 →';

  @override
  String get cardCheckPickShort => '확인하기 →';

  @override
  String get cardComboCheck => '오늘의 조합 확인하기 →';

  @override
  String get cardComboCount => '조합 수';

  @override
  String get cardComboDefaultSubtitle => '오늘의 AI 조합을 확인하세요.';

  @override
  String get cardComboLeagueHint => '매일 3대 리그 AI 분석 조합 제공';

  @override
  String cardComboTodayCount(int count) {
    return '오늘 조합 $count개';
  }

  @override
  String get cardHitRate => '적중률';

  @override
  String get cardNextUpdate => '다음 업데이트까지';

  @override
  String get cardPickCount => '픽 개수';

  @override
  String get cardStreak => '현재 연승';

  @override
  String get cardTodayCombo => '오늘의 추천 조합';

  @override
  String get cardTodayPick => '오늘의 추천 경기';

  @override
  String get cardUpdateLabel => '업데이트';

  @override
  String get cardUpdating => '업데이트 중...';

  @override
  String get checkNow => '확인하기';

  @override
  String get close => '닫기';

  @override
  String get comboAiDisclaimer => 'AI 분석 결과는 참고용이며, 결과를 보장하지 않습니다.';

  @override
  String get comboAiSummary => '종합 평가';

  @override
  String get comboAiWarning => '주의사항';

  @override
  String get comboAvgOdds => '평균 배당';

  @override
  String get comboComboCount => '조합 수';

  @override
  String get comboDashboardToday => '오늘';

  @override
  String comboFoldCount(int count) {
    return '$count COMBO';
  }

  @override
  String get comboHighOdds => '고배당';

  @override
  String get comboMatchFail => '실패';

  @override
  String get comboMatchHit => '적중';

  @override
  String get comboMatchPending => '대기';

  @override
  String comboPicksCompleted(int count) {
    return '$count개 AI 조합 분석 완료';
  }

  @override
  String get comboReliability => '신뢰도';

  @override
  String comboResultHitCount(int count) {
    return '$count개 적중';
  }

  @override
  String comboResultInProgressCount(int count) {
    return '$count개 진행 중';
  }

  @override
  String comboResultMissCount(int count) {
    return '$count개 미적중';
  }

  @override
  String comboResultPartialCount(int count) {
    return '$count개 부분 적중';
  }

  @override
  String get comboSafe => '안전형';

  @override
  String get comboSafeHitRate => '안전형 적중률';

  @override
  String get comboStatusHit => '적중';

  @override
  String get comboStatusInProgress => '진행중';

  @override
  String get comboStatusMiss => '미적중';

  @override
  String get comboStatusPartial => '부분';

  @override
  String get comboTotalOdds => '총 배당';

  @override
  String get comboTypeHigh => '고배당';

  @override
  String get comboTypeSafe => '안전형';

  @override
  String get comboWin => '승';

  @override
  String get confidenceAccuracy => '정합도';

  @override
  String get confirm => '확인';

  @override
  String get deleteAccountConfirm => '계정삭제';

  @override
  String get deleteAccountHint => '\'DELETE\'를 입력하여 확인하세요.';

  @override
  String get deleteAccountMessage => '계정을 삭제하면 모든 데이터가 삭제되며 복구할 수 없습니다.';

  @override
  String get deleteAccountTitle => '계정 삭제';

  @override
  String get emptyChangeDate => '날짜 변경';

  @override
  String get emptyDataSubtitle => '나중에 다시 확인해 주세요.';

  @override
  String get emptyDataTitle => '데이터가 없습니다.';

  @override
  String get emptyPremiumPickSubtitle => '오전 6시 또는 오후 6시에 다시 확인해 주세요.';

  @override
  String get emptyPremiumPickTitle => '오늘의 픽이 없습니다.';

  @override
  String get errorGeneric => '오류가 발생했습니다.';

  @override
  String get errorLogin => '로그인에 실패했습니다.';

  @override
  String get errorNetwork => '네트워크 연결을 확인해주세요.';

  @override
  String get errorPayment => '결제에 실패했습니다.';

  @override
  String get errorContactFailed => '문의 전송에 실패했습니다';

  @override
  String errorCooldownActive(int daysLeft) {
    return '$daysLeft일 후 다시 시도해주세요';
  }

  @override
  String get errorDeleteConfirmation => '계정 삭제에 실패했습니다';

  @override
  String get errorAccountDeleted => '탈퇴한 계정입니다. 다른 계정으로 로그인해주세요.';

  @override
  String get errorEmailRequired => '이메일이 필요합니다';

  @override
  String get errorNaverLoginFailed => '네이버 로그인에 실패했습니다. 다시 시도해주세요.';

  @override
  String get errorNetworkTimeout => '네트워크 연결을 확인해주세요';

  @override
  String get errorNotFound => '요청한 정보를 찾을 수 없습니다';

  @override
  String get errorPaymentPending => '결제 처리 중입니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorPurchaseVerifyFailed => '결제 확인에 실패했습니다';

  @override
  String get errorRateLimited => '요청이 너무 많습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorServerError => '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get errorSubscriptionRequired => '프리미엄 구독이 필요합니다';

  @override
  String get errorUnauthorized => '로그인이 필요합니다';

  @override
  String get errorUnknown => '오류가 발생했습니다';

  @override
  String get exitConfirm => '종료하기';

  @override
  String get exitDialogConfirm => '종료';

  @override
  String get exitDialogMessage => 'TrendSoccer를 종료하시겠습니까?';

  @override
  String get exitDialogTitle => '앱 종료';

  @override
  String get exitMessage => 'TrendSoccer를 종료하시겠습니까?';

  @override
  String get exitTitle => '앱 종료';

  @override
  String get exitToastMessage => '한 번 더 누르면 종료됩니다';

  @override
  String get filterAll => '전체';

  @override
  String get fixtureCancelled => '취소';

  @override
  String get fixtureEmpty => '경기 일정이 없습니다.';

  @override
  String get fixtureInterrupted => '중단';

  @override
  String get statusPostponed => '연기';

  @override
  String get statusInterrupted => '중단';

  @override
  String baseballInningTop(int inning) {
    return '$inning회 초';
  }

  @override
  String baseballInningBottom(int inning) {
    return '$inning회 말';
  }

  @override
  String get fixtureLive => 'LIVE';

  @override
  String get fixtureLiveEmpty => '진행 중인 경기가 없습니다.';

  @override
  String get fixtureNoLiveMatches => '진행 중인 경기가 없습니다.';

  @override
  String get fixtureLiveEmptyAction => '오늘 경기 확인하기';

  @override
  String get fixtureLoadFailed => '경기 일정을 불러오지 못했습니다.';

  @override
  String get fixtureNoMatches => '경기가 없습니다';

  @override
  String get fixtureNoMatchesOnDate => '선택한 날짜에 예정된 경기가 없습니다.';

  @override
  String get fixturePostponed => '연기';

  @override
  String get matchCancelled => '취소';

  @override
  String get matchPostponed => '연기';

  @override
  String get fixtureStatusFinal => 'FT';

  @override
  String get fixtureViewAllMatches => '전체 경기 보기';

  @override
  String get forceUpdateButton => '업데이트';

  @override
  String get forceUpdateMessage => '새로운 기능과 안정성 개선이 포함된 업데이트가 있습니다.';

  @override
  String get forceUpdateSkip => '건너뛰기';

  @override
  String get forceUpdateTitle => '업데이트 필요';

  @override
  String get formInvalidEmail => '올바른 이메일 형식이 아닙니다';

  @override
  String get formRequired => '필수 입력 항목입니다';

  @override
  String get goBack => '뒤로가기';

  @override
  String get guestBannerCta => '지금 바로 프리미엄 체험하기 →';

  @override
  String get guestBannerSubtitle => '분석 카드, 프리미엄 픽 등 모든 기능 이용';

  @override
  String get guestBannerTitle => '지금 가입하고 48시간 무료 체험';

  @override
  String get helpCenterEmail => '이메일';

  @override
  String get helpCenterIntro => '문의 사항을 남겨주시면 이메일로 답변드리겠습니다.';

  @override
  String get helpCenterMessage => '메세지';

  @override
  String get helpCenterName => '이름';

  @override
  String get helpCenterSend => '문의 보내기';

  @override
  String get helpCenterSubject => '제목';

  @override
  String get helpCenterSubmit => '문의하기';

  @override
  String get helpCenterSubmitFail => '전송에 실패했습니다. 다시 시도해주세요.';

  @override
  String get helpCenterSubmitSuccess => '문의가 성공적으로 전송되었습니다.';

  @override
  String get helpCenterSuccess => '문의가 접수되었습니다.';

  @override
  String get helpCenterTitle => '문의하기';

  @override
  String get labelAway => '원정';

  @override
  String get labelAwayShort => 'A';

  @override
  String get labelDraw => '무';

  @override
  String get labelDrawShort => 'D';

  @override
  String get labelHome => '홈';

  @override
  String get labelHomeShort => 'H';

  @override
  String get labelOdds => '배당';

  @override
  String get labelPrediction => '예측';

  @override
  String get labelRecommend => '추천';

  @override
  String get labelOver => '오버';

  @override
  String get labelUnder => '언더';

  @override
  String get labelWin => '승';

  @override
  String get labelWinShort => 'W';

  @override
  String get languageSettingsTitle => '언어 설정';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageEnglish => 'English';

  @override
  String get maintenanceTitle => '서비스 점검 중';

  @override
  String get maintenanceSubtitle => '잠시 후 다시 시도해주세요.';

  @override
  String get legalLoadError => '내용을 불러오지 못했습니다.';

  @override
  String liveMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get loadMatchesFailed => '경기 목록을 불러오지 못했습니다.';

  @override
  String get loginAppBarTitle => '로그인';

  @override
  String get loginGoogle => 'Google로 시작하기';

  @override
  String get loginNaver => 'Naver로 시작하기';

  @override
  String get loginNaverFailed => '네이버 로그인에 실패했습니다. 다시 시도해주세요.';

  @override
  String get loginSheetDesc => 'H2H 상대전적부터 팀 심층 분석까지, 당신의 예측을 완성할 데이터를 확인하세요.';

  @override
  String get loginSheetTitle => '더 스마트한 선택의 시작.';

  @override
  String get loginStart => '시작하기';

  @override
  String get loginSubtitle =>
      '프리미엄 AI가 읽어내는 축구와 야구의 흐름.\n정교한 데이터로 예측의 정확도를 높이세요.';

  @override
  String get loginSuccess => '로그인 성공';

  @override
  String get loginTitle => 'Better Data,\nSmarter Picks,\nFor Your Choice.';

  @override
  String get matchAlarmDisabledGoSettings => '설정으로 이동';

  @override
  String get matchAlarmDisabledMessage =>
      '경기 알림이 꺼져 있습니다.\n메뉴 > 알림 설정에서 경기 알림을 켜주세요.';

  @override
  String get matchAlarmDisabledTitle => '경기 알림 비활성화';

  @override
  String get matchAlarmSettingsTitle => '경기 알림 설정';

  @override
  String get matchReportTitle => '매치 리포트';

  @override
  String get menuAbout => '서비스 소개';

  @override
  String get menuAppVersion => '앱 버전';

  @override
  String get menuDeleteAccount => '회원탈퇴';

  @override
  String get menuExplore => 'Explore';

  @override
  String get menuExploreSection => '추가 기능';

  @override
  String get menuHelpCenter => '문의하기';

  @override
  String get menuLanguage => '언어';

  @override
  String get menuMatchPreview => '매치 프리뷰';

  @override
  String get menuNotification => '알림';

  @override
  String get menuOthers => '기타';

  @override
  String menuPremiumExpiryDate(String date) {
    return '만료일 $date';
  }

  @override
  String get subscriptionCancelPending => '구독 해지 예정';

  @override
  String get subscriptionExpiryDate => '만료 예정';

  @override
  String get subscriptionStartDate => '구독 시작';

  @override
  String get subscriptionNextBilling => '다음 결제일';

  @override
  String get menuPrivacyPolicy => '개인정보처리방침';

  @override
  String get menuProfile => '프로필';

  @override
  String get menuSettings => '설정';

  @override
  String get menuSettingsSection => '앱 설정';

  @override
  String get menuSignOut => '로그아웃';

  @override
  String get menuSubscribe => '구독';

  @override
  String get menuSubscribeFree => '구독 시작하기';

  @override
  String get menuSubscribeInfoSection => '구독 정보';

  @override
  String get menuSubscribeManage => '구독 관리';

  @override
  String get menuSubscribeManageTitle => '구독 관리';

  @override
  String get menuSubscribePrompt => '지금 구독 시작하고 프리미엄 데이터를 확인하세요.';

  @override
  String get menuSubscribeTitle => '구독';

  @override
  String get menuSubscribeTrial => '체험 중';

  @override
  String get menuTermsOfService => '이용약관';

  @override
  String get menuTheme => '테마';

  @override
  String get menuTrialExpired => '체험 기간 만료';

  @override
  String menuTrialRemaining(int hours, int minutes) {
    return '$hours시간 $minutes분 남음';
  }

  @override
  String get noMatchInfo => '경기 정보가 없습니다';

  @override
  String get notificationAppGeneral => '앱 알림';

  @override
  String get notificationAppGeneralDesc => '업데이트, 공지, 서비스 안내';

  @override
  String get notificationDisabledSnack => '알림이 비활성화되었습니다. 설정에서 알림을 허용해주세요.';

  @override
  String get notificationMarketing => '마케팅 알림';

  @override
  String get notificationMarketingDesc => '프로모션, 이벤트, 할인 안내';

  @override
  String get notificationMatchEvents => '경기 알림';

  @override
  String get notificationMatchEventsDesc => '경기 이벤트 푸시 알림';

  @override
  String get notificationPermissionGoSettings => '설정으로 이동';

  @override
  String get notificationPermissionMessage => '알림 권한이 필요합니다.\n설정에서 알림을 허용해주세요.';

  @override
  String get notificationPermissionMessageMatch =>
      '경기 알림을 받으려면 알림 권한이 필요합니다.\n설정에서 알림을 허용해주세요.';

  @override
  String get notificationPermissionDisabledBanner =>
      '알림 권한이 비활성화되어 있습니다. 설정에서 활성화해주세요.';

  @override
  String get notificationPermissionTitle => '알림 권한 필요';

  @override
  String get notificationSettings => '알림';

  @override
  String get notificationGeneral => '일반';

  @override
  String get notificationSoccer => '축구';

  @override
  String get notificationBaseball => '야구';

  @override
  String get notificationAppAlerts => '앱 알림';

  @override
  String get alarmKickoff => '킥 오프';

  @override
  String get alarmGoal => '득점';

  @override
  String get alarmHalftime => '하프타임';

  @override
  String get alarmSecondHalfStart => '후반시작';

  @override
  String get alarmFulltime => '풀 타임';

  @override
  String get alarmYellowCard => '옐로우카드';

  @override
  String get alarmRedCard => '레드카드';

  @override
  String get alarmSubstitution => '교체';

  @override
  String get alarmGameStart => '경기 시작';

  @override
  String get alarmScore => '득점';

  @override
  String get alarmHomerun => '홈런';

  @override
  String get alarmInningEnd => '이닝 종료';

  @override
  String get alarmGameEnd => '경기 종료';

  @override
  String get notificationTitle => '알림 설정';

  @override
  String get pickDirectionAway => '원정';

  @override
  String get pickDirectionDraw => '무';

  @override
  String get pickDirectionHome => '홈';

  @override
  String get pitcherTbd => '미정';

  @override
  String planTicketExpiryDate(String date) {
    return '구독 만료일 : $date';
  }

  @override
  String planTicketExpiryPendingDate(String date) {
    return '만료 예정일 : $date';
  }

  @override
  String get planTicketFree => '무료 플랜';

  @override
  String get planTicketFreeTitle => '무료 플랜';

  @override
  String get planTicketPremium => '프리미엄 플랜';

  @override
  String get planTicketPremiumTitle => '프리미엄 플랜';

  @override
  String get planTicketManage => '구독 관리하기';

  @override
  String get planTicketRenew => '구독 연장하기';

  @override
  String get planTicketStart => '구독 시작하기';

  @override
  String get planTicketTrialEnded => '체험 종료';

  @override
  String planTicketTrialRemaining(int hours, int minutes) {
    return '$hours시간 $minutes분 남음';
  }

  @override
  String planTicketStartDate(String date) {
    return '구독 시작일 : $date';
  }

  @override
  String get planTicketTrial => '무료 체험 플랜';

  @override
  String planTicketTrialStartDate(String date) {
    return '체험 시작일 : $date';
  }

  @override
  String get planTicketTrialTitle => '체험 플랜';

  @override
  String get planTicketUpgrade => '구독 업그레이드';

  @override
  String get premiumBenefit24h => '24시간 우선 분석 접근';

  @override
  String get premiumBenefitBaseballAi => '야구 AI Analysis';

  @override
  String get premiumBenefitPremiumPick => 'PREMIUM PICK 무제한';

  @override
  String get premiumBenefitsTitle => '프리미엄 혜택';

  @override
  String get premiumComboLoadFailed => '야구 AI 조합을 불러오지 못했습니다.';

  @override
  String get premiumExclusiveContent => '프리미엄 전용 콘텐츠입니다.';

  @override
  String get premiumExclusiveShort => '프리미엄 전용 콘텐츠';

  @override
  String get premiumNoHighConfidence => '오늘 고신뢰도 픽이 없습니다';

  @override
  String get parserReasonBasis => '근거';

  @override
  String parserReasonPatternMatches(int count) {
    return '$count 경기 기반';
  }

  @override
  String parserReasonPowerDiffPoints(String value) {
    return '$value점';
  }

  @override
  String get parserReasonProbEdge => '확률 우위';

  @override
  String get premiumNonSubscriberSubtitle =>
      'AI 분석, PREMIUM PICK, 야구 조합\n광고 없는 쾌적한 환경';

  @override
  String get premiumNonSubscriberTitle => '프리미엄 전용 콘텐츠';

  @override
  String get premiumPickLoadFailed => '프리미엄 픽 목록을 불러오지 못했습니다.';

  @override
  String get premiumSubscribeAfter => '구독 후 이용하실 수 있습니다.';

  @override
  String get premiumSubscribeBenefitsLine1 => 'PREMIUM PICK과 야구 AI 조합 분석을';

  @override
  String get premiumSubscribeNow => '지금 구독하기';

  @override
  String get subscribeNow => '지금 구독하기';

  @override
  String get subscribeToUnlock => '프리미엄 구독으로 전체 예측을 확인하세요';

  @override
  String get premiumSubscribeSheetBaseballDesc =>
      '승리 확률, 오버&언더, 시즌 통계 등 AI 분석 데이터를 이용해보세요.';

  @override
  String get premiumSubscribeSheetSoccerDesc =>
      'H2H 상대전적, 팀 심층 분석 등 프리미엄 혜택을 이용해보세요.';

  @override
  String get reportAuthorRole => '축구 데이터 분석가';

  @override
  String get reportDetailLoadError => '매치 프리뷰를 불러오지 못했습니다.';

  @override
  String get reportEmptySubtitle => '새 프리뷰가 등록되면 여기에 표시됩니다.';

  @override
  String get reportEmptyTitle => '등록된 매치 프리뷰가 없습니다.';

  @override
  String get reportListLoadError => '매치 프리뷰 목록을 불러오지 못했습니다.';

  @override
  String get reportNotFoundSubtitle => '목록에서 다시 선택해 주세요.';

  @override
  String get reportNotFoundTitle => '리포트를 찾을 수 없습니다.';

  @override
  String get reportPremiumOnlyMessage => 'AI 분석 결과를 확인하려면 구독이 필요합니다';

  @override
  String get reportPremiumOnlyTitle => '프리미엄 구독 회원 전용 콘텐츠입니다';

  @override
  String get reportTabAiAnalysis => 'AI Analysis';

  @override
  String get reportTabPremium => '프리미엄';

  @override
  String get reportTabStandard => '스탠다드';

  @override
  String get retry => '다시 시도';

  @override
  String get save => '저장';

  @override
  String get seasonCurrent => '이번시즌';

  @override
  String get seasonPrevious => '이전시즌';

  @override
  String get seeMore => '더 보기 →';

  @override
  String get selectMatchFromAnalysis => '분석 페이지에서 경기를 선택해 주세요.';

  @override
  String get signOutConfirm => '로그아웃';

  @override
  String get signOutMessage => '정말 로그아웃 하시겠습니까?';

  @override
  String get signOutSuccess => '로그아웃 되었습니다.';

  @override
  String get signOutTitle => '로그아웃';

  @override
  String get signupAgreeAll => '전체 동의';

  @override
  String get signupTermsAgree => '이용약관 동의';

  @override
  String get signupPrivacyAgree => '개인정보처리방침 동의';

  @override
  String get signupMarketingAgree => '마케팅 이메일 수신 동의';

  @override
  String get signupRequiredBadge => '필수';

  @override
  String get signupOptionalBadge => '선택';

  @override
  String get signupFreeBenefit1 => '기본 분석 데이터 확인';

  @override
  String get signupFreeBenefit2 => '실시간 스코어 및 경기 일정';

  @override
  String get signupFreeBenefit3 => '야구 Standard 분석 열람';

  @override
  String get signupTrialBannerSubtitle => '가입 즉시 프리미엄 기능 48시간 무료 체험';

  @override
  String get signupWhatsNextBenefit1 => '48시간 무료 체험 종료 후 자동 무료 전환';

  @override
  String get signupWhatsNextBenefit2 => '프리미엄 구독으로 모든 기능 이용 가능';

  @override
  String get signupCompleteAppBarTitle => '가입완료';

  @override
  String signupCompleteCountdown(int seconds) {
    return '$seconds초 후 자동으로 홈으로 이동합니다.';
  }

  @override
  String get signupCompleteFreeBenefit1 => '경기 시작 2시간 전 분석 오픈';

  @override
  String get signupCompleteFreeBenefit2 => '기본 분석 데이터 제공';

  @override
  String get signupCompleteFreeBenefit3 => '실시간 스코어 및 경기 일정';

  @override
  String get signupCompleteFreeBenefitsHeader => '무료 혜택';

  @override
  String get signupCompleteGoHome => '홈으로 이동';

  @override
  String get signupCompletePremiumBenefit1 => '24시간 우선 분석 접근';

  @override
  String get signupCompletePremiumBenefit2 => 'PREMIUM PICK 무제한';

  @override
  String get signupCompletePremiumBenefit3 => '야구 AI Analysis';

  @override
  String get signupCompletePremiumBenefitsHeader => '프리미엄 혜택';

  @override
  String get signupCompletePremiumUpgrade => '프리미엄 업그레이드';

  @override
  String get signupCompleteStartPrompt => '지금 트렌드사커를 시작해 보세요.';

  @override
  String get signupCompleteSubtitle => '48시간 프리미엄 체험이 시작되었습니다.';

  @override
  String get signupCompleteSuccessToast => '회원가입 완료! 프리미엄 체험을 시작합니다.';

  @override
  String get signupCompleteTitle => '환영합니다!';

  @override
  String get signupCompleteTrialBanner => '48시간 프리미엄 무료 체험이 시작되었습니다!';

  @override
  String get signupErrorProcessing => '가입 처리 중 오류가 발생했습니다.';

  @override
  String get signupMarketingOptional => '마케팅 이메일 수신';

  @override
  String get signupOptional => '[선택]';

  @override
  String get signupPageTitle => '회원가입';

  @override
  String get signupPrivacyRequired => '개인정보처리방침';

  @override
  String get signupRequired => '[필수]';

  @override
  String get signupSubmit => '가입하기';

  @override
  String get signupTermsHeadingLine1 => '서비스 이용을 위해';

  @override
  String get signupTermsHeadingLine2 => '약관에 동의해주세요.';

  @override
  String get signupTermsHint => '필수 항목에 동의하시면 가입이 완료됩니다.';

  @override
  String get signupTermsRequired => '이용약관';

  @override
  String get signupTermsTitle => '약관 동의';

  @override
  String get signupView => '보기';

  @override
  String get skip => '건너뛰기';

  @override
  String get soccerAiPremiumOnly => '프리미엄 전용 분석';

  @override
  String get soccerAiPremiumSubscribeHint =>
      'H2H 심층 분석과 팀 인사이트는 프리미엄 구독 후 이용할 수 있습니다.';

  @override
  String get soccerAnalysisReasoning => '분석 근거';

  @override
  String get soccerAnalysisResult => '분석 결과';

  @override
  String get soccerAwayPower => '원정 파워';

  @override
  String soccerAwayWinPct(int percent) {
    return '원정 $percent%';
  }

  @override
  String get soccerDraw => '무승부';

  @override
  String get soccerEventFulltime => '경기 종료';

  @override
  String get soccerEventGoal => '득점';

  @override
  String get soccerEventHalftime => '하프타임';

  @override
  String get soccerEventKickoff => '경기 시작';

  @override
  String get soccerEventRedCard => '퇴장';

  @override
  String get soccerEventSubstitution => '선수 교체';

  @override
  String get soccerEventYellowCard => '경고';

  @override
  String get soccerFinalProbability => '최종 예측 확률';

  @override
  String get soccerH2h => 'H2H';

  @override
  String get soccerH2hAllTime => '역대 전적';

  @override
  String get soccerH2hAvgGoals => '평균 득점';

  @override
  String get soccerH2hInsights => '매치 인사이트';

  @override
  String get soccerH2hLoading => 'H2H 분석 로딩 중...';

  @override
  String get soccerH2hMaxScore => '최대 스코어';

  @override
  String get soccerH2hRecent => '최근 맞대결';

  @override
  String soccerH2hMatchCount(int count) {
    return '($count경기)';
  }

  @override
  String get soccerH2hStatistics => '통계';

  @override
  String get soccerHomePower => '홈 파워';

  @override
  String soccerHomeWinPct(int percent) {
    return '홈 $percent%';
  }

  @override
  String get soccerMarketBtts => 'BTTS';

  @override
  String get soccerMarketCs => 'CS';

  @override
  String get soccerMarketFts => 'FTS';

  @override
  String get soccerMarketIndicators => '마켓 지표 (최근 10경기)';

  @override
  String get soccerMethod3 => '3-Method 분석';

  @override
  String get soccerMethodFirstGoal => '선제골';

  @override
  String get soccerMethodMinMax => 'MIN-MAX 비교';

  @override
  String get soccerMethodPaCompare => 'P/A비교';

  @override
  String get soccerOddsAway => '원정 승';

  @override
  String get soccerOddsDraw => '무승부';

  @override
  String get soccerOddsHome => '홈 승';

  @override
  String get soccerPowerDiff => '파워차';

  @override
  String get soccerPowerIndex => '파워 인덱스';

  @override
  String get soccerPremiumOnly => '프리미엄 전용';

  @override
  String get soccerRecent10 => '최근 10경기';

  @override
  String get soccerRecentForm => '최근 폼';

  @override
  String get soccerReasonFirstGoalAway => '원정 선득점 승률';

  @override
  String get soccerReasonFirstGoalHome => '홈 선득점 승률';

  @override
  String get soccerSeasonAway => '시즌 원정 성적';

  @override
  String get soccerSeasonHome => '시즌 홈 성적';

  @override
  String get soccerStatAnalyzedMatches => '분석 경기';

  @override
  String get soccerStatComebackRate => '역전률';

  @override
  String get soccerStatFirstGoalRate => '선제골 승률';

  @override
  String get soccerStatGoalDifference => '득실비';

  @override
  String get soccerStatGoalLine => '골 라인';

  @override
  String get soccerStatLosses => '패';

  @override
  String get soccerStatOver15 => 'O 1.5';

  @override
  String get soccerStatOver25 => 'O 2.5';

  @override
  String get soccerStatOver35 => 'O 3.5';

  @override
  String get soccerStatPattern => '패턴 통계';

  @override
  String get soccerStatPowerDiff => '파워차';

  @override
  String get soccerStatTeamInsights => '팀 인사이트';

  @override
  String get soccerStatTeamStats => '팀 상세 통계';

  @override
  String get soccerStatWinProb => '승리 확률';

  @override
  String get soccerStatWinRate => '승률';

  @override
  String get soccerStatWins => '승';

  @override
  String get sportBaseball => '야구';

  @override
  String get sportSoccer => '축구';

  @override
  String get subscribeAlreadyOwned => '이미 구독 중입니다. 기존 구독을 확인합니다.';

  @override
  String get subscribeBack => '돌아가기';

  @override
  String get subscribeDiscount => '33% OFF';

  @override
  String get subscribeFailAttemptAmount => '결제 시도 금액';

  @override
  String get subscribeFailDescription => '다시 시도하거나 다른 결제 수단을 이용해주세요.';

  @override
  String get subscribeFailErrorCode => '오류 코드';

  @override
  String get subscribeFailMessage => '결제에 실패했습니다.';

  @override
  String get subscribeFailRetry => '다시 시도하기';

  @override
  String get subscribeFailTitle => '결제 실패';

  @override
  String get subscribeFreeBenefit1 => '분석 카드 킥오프 2시간 전 공개';

  @override
  String get subscribeFreeBenefit2 => '기본 경기 분석 및 통계';

  @override
  String get subscribeFreeBenefit3 => '실시간 스코어 및 경기 일정';

  @override
  String get subscribeFreeBenefit4 => '광고 포함';

  @override
  String get subscribeGoHome => '홈으로 돌아가기';

  @override
  String get subscribeHeader => 'Get Full Access To The AI Assistant';

  @override
  String get subscribeHeaderLine1 => 'Get Full Access To';

  @override
  String get subscribeHeaderLine2 => 'The AI Assistant !';

  @override
  String get subscribeIapCannotStart => 'Google Play 결제를 시작할 수 없습니다.';

  @override
  String get subscribeIapPreparing => 'Google Play 결제 준비 중...';

  @override
  String get subscribeIapProcessing => 'Google Play 결제 처리 중...';

  @override
  String get subscribeIapRestoring => '기존 구독 확인 중...';

  @override
  String get subscribeIapUnavailable => 'Google Play 결제를 사용할 수 없습니다.';

  @override
  String get subscribeIapVerifyPending =>
      '결제는 완료되었으나 검증 대기 중입니다. 잠시 후 앱을 재시작해주세요.';

  @override
  String get subscribeManageOnPlay => 'Google Play에서 구독 관리';

  @override
  String subscribePeriodMonths(int months) {
    return '$months개월';
  }

  @override
  String get subscribePlanFree => '무료';

  @override
  String get subscribePlanMonthly => '1개월';

  @override
  String get subscribePlanPremium => '프리미엄';

  @override
  String get subscribePlanQuarterly => '3개월';

  @override
  String get subscribePremiumActive => '프리미엄 구독 중';

  @override
  String get subscribePremiumBenefit1 => '모든 분석 24시간 우선 접근';

  @override
  String get subscribePremiumBenefit2 => '축구 프리미엄픽 무제한';

  @override
  String get subscribePremiumBenefit3 => 'AI 야구 분석 전체 공개';

  @override
  String get subscribePremiumBenefit4 => '야구 조합 픽';

  @override
  String get subscribePremiumBenefit5 => '광고 없는 경험';

  @override
  String subscribePremiumExpiry(String date) {
    return '만료일: $date';
  }

  @override
  String get subscribePremiumMessage => '현재 프리미엄 구독을 이용 중입니다.';

  @override
  String get subscribePriceMonthly => '₩4,900';

  @override
  String get subscribePriceQuarterly => '₩9,900';

  @override
  String get subscribeReceiptAmount => '결제 금액';

  @override
  String get subscribeReceiptPlan => '구독 플랜';

  @override
  String get subscribeSelectProduct => '구독 상품 선택';

  @override
  String get subscribeStartPremium => '프리미엄 구독 시작하기';

  @override
  String get subscribeStartPremiumArrow => '프리미엄 구독 시작하기 →';

  @override
  String get subscribeSuccessCTA => '프리미엄 분석 시작하기';

  @override
  String get subscribeSuccessComplete => '구독이 완료되었습니다.';

  @override
  String get subscribeSuccessSubtitle => '지금 바로 프리미엄 혜택을 이용해보세요.';

  @override
  String get subscribeSuccessTitle => '결제 완료';

  @override
  String get subscribeTrialActive => '48시간 프리미엄 체험 중';

  @override
  String get subscribeTrialMessage => '체험 기간 종료 후 구독할 수 있습니다.';

  @override
  String subscribeTrialRemaining(int hours, int minutes) {
    return '남은 시간: $hours시간 $minutes분';
  }

  @override
  String get subscribeTrialRemainingZero => '남은 시간: 0시간 0분';

  @override
  String get subscribeUpdating => '구독 정보 업데이트 중...';

  @override
  String get tabAnalysis => '분석';

  @override
  String get tabFixture => '일정';

  @override
  String get tabMenu => '메뉴';

  @override
  String get tabPremium => '프리미엄';

  @override
  String get tabTrend => '트렌드';

  @override
  String get themeDark => '다크 모드';

  @override
  String get themeLight => '라이트 모드';

  @override
  String get themeSettingsTitle => '테마 설정';

  @override
  String get themeSystem => '시스템 설정';

  @override
  String get today => '오늘';

  @override
  String get todayCombination => '오늘의 추천 조합';

  @override
  String get todayPremiumPick => '오늘의 추천 경기';

  @override
  String get trendBaseballAnalysis => '야구 분석';

  @override
  String get trendEmptySubtitle1 => '현재 진행 중인 공식 리그 일정이 없습니다.';

  @override
  String get trendEmptySubtitle2 => '시즌 재개 시 더욱 스마트한 데이터를 제공해 드립니다.';

  @override
  String get trendEmptyTitle => '다음 경기를 기다리고 있습니다.';

  @override
  String get trendNoBaseballScheduled => '예정된 야구 경기가 없습니다.';

  @override
  String get trendNoSoccerScheduled => '예정된 축구 경기가 없습니다.';

  @override
  String get trendPremiumAnalysis => '프리미엄 분석';

  @override
  String get trendSoccerAnalysis => '축구 분석';

  @override
  String get weekdayFri => '금';

  @override
  String get weekdayMon => '월';

  @override
  String get weekdaySat => '토';

  @override
  String get weekdaySun => '일';

  @override
  String get weekdayThu => '목';

  @override
  String get weekdayTue => '화';

  @override
  String get weekdayWed => '수';
}
