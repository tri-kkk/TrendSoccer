import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en'),
  ];

  /// No description provided for @aboutContactEmail.
  ///
  /// In ko, this message translates to:
  /// **'tikilab2025@gmail.com'**
  String get aboutContactEmail;

  /// No description provided for @aboutContactSection.
  ///
  /// In ko, this message translates to:
  /// **'컨택 & 서포트'**
  String get aboutContactSection;

  /// No description provided for @aboutContactWebsite.
  ///
  /// In ko, this message translates to:
  /// **'trendsoccer.com'**
  String get aboutContactWebsite;

  /// No description provided for @aboutDescription.
  ///
  /// In ko, this message translates to:
  /// **'TrendSoccer는 AI 기반 실시간 분석으로 경기 흐름을 예측합니다. 프리미어리그부터 챔피언스리그까지, 모든 빅매치를 전문가 수준의 인사이트로 경험하세요.'**
  String get aboutDescription;

  /// No description provided for @aboutFeatureAiDesc.
  ///
  /// In ko, this message translates to:
  /// **'4시즌 방대한 경기 데이터를 기반으로 구축'**
  String get aboutFeatureAiDesc;

  /// No description provided for @aboutFeatureAiTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 기반 분석'**
  String get aboutFeatureAiTitle;

  /// No description provided for @aboutFeatureLeaguesDesc.
  ///
  /// In ko, this message translates to:
  /// **'주요 6대 리그 종합 데이터 지원'**
  String get aboutFeatureLeaguesDesc;

  /// No description provided for @aboutFeatureLeaguesTitle.
  ///
  /// In ko, this message translates to:
  /// **'글로벌 리그 지원'**
  String get aboutFeatureLeaguesTitle;

  /// No description provided for @aboutFeatureOddsDesc.
  ///
  /// In ko, this message translates to:
  /// **'배당 무브먼트에 따른 마켓 모니터링'**
  String get aboutFeatureOddsDesc;

  /// No description provided for @aboutFeatureOddsTitle.
  ///
  /// In ko, this message translates to:
  /// **'실시간 배당 분석'**
  String get aboutFeatureOddsTitle;

  /// No description provided for @aboutFeaturesSection.
  ///
  /// In ko, this message translates to:
  /// **'주요 기능'**
  String get aboutFeaturesSection;

  /// No description provided for @aboutTagline.
  ///
  /// In ko, this message translates to:
  /// **'데이터로 읽는 축구의 흐름'**
  String get aboutTagline;

  /// No description provided for @aboutVisionSection.
  ///
  /// In ko, this message translates to:
  /// **'비전'**
  String get aboutVisionSection;

  /// No description provided for @aboutVisionText.
  ///
  /// In ko, this message translates to:
  /// **'축구 팬들이 경기를 더 깊이 이해하고 즐길 수 있도록 돕습니다.'**
  String get aboutVisionText;

  /// No description provided for @accessLockLoginRequired.
  ///
  /// In ko, this message translates to:
  /// **'로그인 후 확인 가능합니다.'**
  String get accessLockLoginRequired;

  /// No description provided for @accessLockOpens24HoursBefore.
  ///
  /// In ko, this message translates to:
  /// **'경기 시작 24시간 전에 오픈됩니다.'**
  String get accessLockOpens24HoursBefore;

  /// No description provided for @accessLockOpensOneHourBefore.
  ///
  /// In ko, this message translates to:
  /// **'경기 시작 1시간 전에 오픈됩니다.'**
  String get accessLockOpensOneHourBefore;

  /// No description provided for @accessLockPremium24h.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 구독 시 경기 시작 24시간 전부터 확인 가능합니다.'**
  String get accessLockPremium24h;

  /// No description provided for @accessUnlockDaysHours.
  ///
  /// In ko, this message translates to:
  /// **'{days}일 {hours}시간 후 오픈'**
  String accessUnlockDaysHours(int days, int hours);

  /// No description provided for @accessUnlockHoursMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 {minutes}분 후 오픈'**
  String accessUnlockHoursMinutes(int hours, int minutes);

  /// No description provided for @accessUnlockMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 후 오픈'**
  String accessUnlockMinutes(int minutes);

  /// No description provided for @accessUnlockViewAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'분석보기'**
  String get accessUnlockViewAnalysis;

  /// No description provided for @alarmToggleTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림 받기'**
  String get alarmToggleTitle;

  /// No description provided for @alarmSecondHalf.
  ///
  /// In ko, this message translates to:
  /// **'후반전 시작'**
  String get alarmSecondHalf;

  /// No description provided for @analysisAiAnalyzing.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석 중...'**
  String get analysisAiAnalyzing;

  /// No description provided for @analysisAiWaitHint.
  ///
  /// In ko, this message translates to:
  /// **'잠시만 기다려주세요 (약 5–10초)'**
  String get analysisAiWaitHint;

  /// No description provided for @analysisCardView.
  ///
  /// In ko, this message translates to:
  /// **'분석보기'**
  String get analysisCardView;

  /// No description provided for @analysisCardViewAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'분석하기'**
  String get analysisCardViewAnalysis;

  /// No description provided for @analysisEmpty.
  ///
  /// In ko, this message translates to:
  /// **'분석 데이터가 없습니다.'**
  String get analysisEmpty;

  /// No description provided for @analysisLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'분석 데이터를 불러오지 못했습니다.'**
  String get analysisLoadFailed;

  /// No description provided for @analysisLoadMatchesFailed.
  ///
  /// In ko, this message translates to:
  /// **'경기 목록을 불러오지 못했습니다.'**
  String get analysisLoadMatchesFailed;

  /// No description provided for @analysisMatchInfoLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'경기 정보를 불러오지 못했습니다.'**
  String get analysisMatchInfoLoadFailed;

  /// No description provided for @analysisMatchInfoLoading.
  ///
  /// In ko, this message translates to:
  /// **'경기 정보 로딩 중...'**
  String get analysisMatchInfoLoading;

  /// No description provided for @analysisNoBaseballScheduled.
  ///
  /// In ko, this message translates to:
  /// **'예정된 야구 경기가 없습니다.'**
  String get analysisNoBaseballScheduled;

  /// No description provided for @analysisNoMatches.
  ///
  /// In ko, this message translates to:
  /// **'경기가 없습니다'**
  String get analysisNoMatches;

  /// No description provided for @analysisNoMatchesFilterHint.
  ///
  /// In ko, this message translates to:
  /// **'오늘 예정된 경기가 없거나 필터 조건에 맞는 경기가 없습니다.'**
  String get analysisNoMatchesFilterHint;

  /// No description provided for @analysisNoResult.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과가 없습니다.'**
  String get analysisNoResult;

  /// No description provided for @analysisPremiumPick.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 분석'**
  String get analysisPremiumPick;

  /// No description provided for @analysisTabBaseball.
  ///
  /// In ko, this message translates to:
  /// **'야구 분석'**
  String get analysisTabBaseball;

  /// No description provided for @analysisTabSoccer.
  ///
  /// In ko, this message translates to:
  /// **'축구 분석'**
  String get analysisTabSoccer;

  /// No description provided for @analysisToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get analysisToday;

  /// No description provided for @analyzeButton.
  ///
  /// In ko, this message translates to:
  /// **'Analyze'**
  String get analyzeButton;

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'트렌드사커'**
  String get appName;

  /// No description provided for @apply.
  ///
  /// In ko, this message translates to:
  /// **'적용하기'**
  String get apply;

  /// No description provided for @back.
  ///
  /// In ko, this message translates to:
  /// **'뒤로'**
  String get back;

  /// No description provided for @baseballAiLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 분석을 불러오지 못했습니다.'**
  String get baseballAiLoadFailed;

  /// No description provided for @baseballAiLoading.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 분석 로딩 중...'**
  String get baseballAiLoading;

  /// No description provided for @baseballAiLoadingHint.
  ///
  /// In ko, this message translates to:
  /// **'최초 분석 시 10–30초 정도 소요될 수 있습니다.'**
  String get baseballAiLoadingHint;

  /// No description provided for @baseballAiMatchAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'AI 경기 분석'**
  String get baseballAiMatchAnalysis;

  /// No description provided for @baseballAiPremiumHint.
  ///
  /// In ko, this message translates to:
  /// **'AI 기반 심층 분석은 프리미엄 구독 후 이용할 수 있습니다.'**
  String get baseballAiPremiumHint;

  /// No description provided for @baseballAiSummary.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석 요약'**
  String get baseballAiSummary;

  /// No description provided for @baseballAiSummaryDefault.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석 데이터'**
  String get baseballAiSummaryDefault;

  /// No description provided for @baseballAiTabLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석을 불러오지 못했습니다.'**
  String get baseballAiTabLoadFailed;

  /// No description provided for @baseballAiTabLoading.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석 로딩 중...'**
  String get baseballAiTabLoading;

  /// No description provided for @baseballAiTabLoadingHint.
  ///
  /// In ko, this message translates to:
  /// **'최초 분석 시 10–15초 정도 소요될 수 있습니다.'**
  String get baseballAiTabLoadingHint;

  /// No description provided for @baseballAiWinProbabilityHint.
  ///
  /// In ko, this message translates to:
  /// **'AI 기반 승리 확률 분석입니다.'**
  String get baseballAiWinProbabilityHint;

  /// No description provided for @baseballBaseline.
  ///
  /// In ko, this message translates to:
  /// **'기준선'**
  String get baseballBaseline;

  /// No description provided for @baseballBaselineDash.
  ///
  /// In ko, this message translates to:
  /// **'기준선 -'**
  String get baseballBaselineDash;

  /// No description provided for @baseballBaselineValue.
  ///
  /// In ko, this message translates to:
  /// **'기준선 {line}'**
  String baseballBaselineValue(String line);

  /// No description provided for @baseballConfidenceHigh.
  ///
  /// In ko, this message translates to:
  /// **'높음'**
  String get baseballConfidenceHigh;

  /// No description provided for @baseballConfidenceLow.
  ///
  /// In ko, this message translates to:
  /// **'낮음'**
  String get baseballConfidenceLow;

  /// No description provided for @baseballConfidenceMedium.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get baseballConfidenceMedium;

  /// No description provided for @baseballEventFirstPitch.
  ///
  /// In ko, this message translates to:
  /// **'경기 시작'**
  String get baseballEventFirstPitch;

  /// No description provided for @baseballEventGameEnd.
  ///
  /// In ko, this message translates to:
  /// **'경기 종료'**
  String get baseballEventGameEnd;

  /// No description provided for @baseballEventHomerun.
  ///
  /// In ko, this message translates to:
  /// **'홈런'**
  String get baseballEventHomerun;

  /// No description provided for @baseballEventInningChange.
  ///
  /// In ko, this message translates to:
  /// **'이닝 종료'**
  String get baseballEventInningChange;

  /// No description provided for @baseballEventScore.
  ///
  /// In ko, this message translates to:
  /// **'득점'**
  String get baseballEventScore;

  /// No description provided for @baseballH2hLoading.
  ///
  /// In ko, this message translates to:
  /// **'상대 전적 데이터를 불러오는 중...'**
  String get baseballH2hLoading;

  /// No description provided for @baseballH2hNoData.
  ///
  /// In ko, this message translates to:
  /// **'상대 전적 데이터가 없습니다.'**
  String get baseballH2hNoData;

  /// No description provided for @baseballHomeAwayRecord.
  ///
  /// In ko, this message translates to:
  /// **'홈&원정 성적'**
  String get baseballHomeAwayRecord;

  /// No description provided for @baseballHomeAwayWinRate.
  ///
  /// In ko, this message translates to:
  /// **'최근 10경기 승률'**
  String get baseballHomeAwayWinRate;

  /// No description provided for @baseballOddsBaseline.
  ///
  /// In ko, this message translates to:
  /// **'기준점'**
  String get baseballOddsBaseline;

  /// No description provided for @baseballOverUnder.
  ///
  /// In ko, this message translates to:
  /// **'오버&언더'**
  String get baseballOverUnder;

  /// No description provided for @baseballProductionBatterEdge.
  ///
  /// In ko, this message translates to:
  /// **'{team} 타선 우세 ({value}점/경기)'**
  String baseballProductionBatterEdge(String team, String value);

  /// No description provided for @baseballProductionDefenseEdge.
  ///
  /// In ko, this message translates to:
  /// **'{team} 수비 우세 ({value}실점/경기)'**
  String baseballProductionDefenseEdge(String team, String value);

  /// No description provided for @baseballPitcherAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'투수 분석'**
  String get baseballPitcherAnalysis;

  /// No description provided for @baseballPitcherAnalysisNoData.
  ///
  /// In ko, this message translates to:
  /// **'투수 분석 데이터를 불러올 수 없습니다.'**
  String get baseballPitcherAnalysisNoData;

  /// No description provided for @baseballPitcherMatchup.
  ///
  /// In ko, this message translates to:
  /// **'투수 매치업 분석'**
  String get baseballPitcherMatchup;

  /// No description provided for @baseballPitcherGeneric.
  ///
  /// In ko, this message translates to:
  /// **'투수'**
  String get baseballPitcherGeneric;

  /// No description provided for @baseballPitcherLeftHand.
  ///
  /// In ko, this message translates to:
  /// **'좌완 투수'**
  String get baseballPitcherLeftHand;

  /// No description provided for @baseballPitcherRightHand.
  ///
  /// In ko, this message translates to:
  /// **'우완 투수'**
  String get baseballPitcherRightHand;

  /// No description provided for @baseballRecent10.
  ///
  /// In ko, this message translates to:
  /// **'최근 10경기'**
  String get baseballRecent10;

  /// No description provided for @baseballRelatedMatches.
  ///
  /// In ko, this message translates to:
  /// **'관련 경기'**
  String get baseballRelatedMatches;

  /// No description provided for @baseballReliability.
  ///
  /// In ko, this message translates to:
  /// **'신뢰도'**
  String get baseballReliability;

  /// No description provided for @baseballSeasonStats.
  ///
  /// In ko, this message translates to:
  /// **'시즌 팀 통계'**
  String get baseballSeasonStats;

  /// No description provided for @baseballSeasonStatsNoData.
  ///
  /// In ko, this message translates to:
  /// **'시즌 통계 데이터를 불러올 수 없습니다.'**
  String get baseballSeasonStatsNoData;

  /// No description provided for @baseballStatHits.
  ///
  /// In ko, this message translates to:
  /// **'안타'**
  String get baseballStatHits;

  /// No description provided for @baseballStatRunsAllowed.
  ///
  /// In ko, this message translates to:
  /// **'실점'**
  String get baseballStatRunsAllowed;

  /// No description provided for @baseballStatRunsScored.
  ///
  /// In ko, this message translates to:
  /// **'득점'**
  String get baseballStatRunsScored;

  /// No description provided for @baseballSectionH2h.
  ///
  /// In ko, this message translates to:
  /// **'Head to Head'**
  String get baseballSectionH2h;

  /// No description provided for @baseballSectionOdds.
  ///
  /// In ko, this message translates to:
  /// **'Odds'**
  String get baseballSectionOdds;

  /// No description provided for @baseballSectionPitchers.
  ///
  /// In ko, this message translates to:
  /// **'Starting Pitchers'**
  String get baseballSectionPitchers;

  /// No description provided for @baseballSectionPitchersKo.
  ///
  /// In ko, this message translates to:
  /// **'선발 투수'**
  String get baseballSectionPitchersKo;

  /// No description provided for @baseballStrength.
  ///
  /// In ko, this message translates to:
  /// **'강점'**
  String get baseballStrength;

  /// No description provided for @baseballTeamProductivity.
  ///
  /// In ko, this message translates to:
  /// **'팀 생산성'**
  String get baseballTeamProductivity;

  /// No description provided for @baseballTeamBattingAvg.
  ///
  /// In ko, this message translates to:
  /// **'팀 타율'**
  String get baseballTeamBattingAvg;

  /// No description provided for @baseballTeamEra.
  ///
  /// In ko, this message translates to:
  /// **'팀 방어율'**
  String get baseballTeamEra;

  /// No description provided for @baseballTeamOps.
  ///
  /// In ko, this message translates to:
  /// **'팀 OPS'**
  String get baseballTeamOps;

  /// No description provided for @baseballTeamProductivityComment.
  ///
  /// In ko, this message translates to:
  /// **'최근 10경기 팀 공격 생산성 지표입니다.'**
  String get baseballTeamProductivityComment;

  /// No description provided for @baseballTeamWhip.
  ///
  /// In ko, this message translates to:
  /// **'팀 WHIP'**
  String get baseballTeamWhip;

  /// No description provided for @baseballWeakness.
  ///
  /// In ko, this message translates to:
  /// **'약점'**
  String get baseballWeakness;

  /// No description provided for @baseballWinProbability.
  ///
  /// In ko, this message translates to:
  /// **'승리 확률'**
  String get baseballWinProbability;

  /// No description provided for @baseballWinsLosses.
  ///
  /// In ko, this message translates to:
  /// **'{wins}승 {losses}패'**
  String baseballWinsLosses(int wins, int losses);

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @cardCheckPick.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 픽 확인하기 →'**
  String get cardCheckPick;

  /// No description provided for @cardCheckPickShort.
  ///
  /// In ko, this message translates to:
  /// **'확인하기 →'**
  String get cardCheckPickShort;

  /// No description provided for @cardComboCheck.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 조합 확인하기 →'**
  String get cardComboCheck;

  /// No description provided for @cardComboCount.
  ///
  /// In ko, this message translates to:
  /// **'조합 수'**
  String get cardComboCount;

  /// No description provided for @cardComboDefaultSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 AI 조합을 확인하세요.'**
  String get cardComboDefaultSubtitle;

  /// No description provided for @cardComboLeagueHint.
  ///
  /// In ko, this message translates to:
  /// **'매일 3대 리그 AI 분석 조합 제공'**
  String get cardComboLeagueHint;

  /// No description provided for @cardComboTodayCount.
  ///
  /// In ko, this message translates to:
  /// **'오늘 조합 {count}개'**
  String cardComboTodayCount(int count);

  /// No description provided for @cardHitRate.
  ///
  /// In ko, this message translates to:
  /// **'적중률'**
  String get cardHitRate;

  /// No description provided for @cardNextUpdate.
  ///
  /// In ko, this message translates to:
  /// **'다음 업데이트까지'**
  String get cardNextUpdate;

  /// No description provided for @cardPickCount.
  ///
  /// In ko, this message translates to:
  /// **'픽 개수'**
  String get cardPickCount;

  /// No description provided for @cardStreak.
  ///
  /// In ko, this message translates to:
  /// **'현재 연승'**
  String get cardStreak;

  /// No description provided for @cardTodayCombo.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 추천 조합'**
  String get cardTodayCombo;

  /// No description provided for @cardTodayPick.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 추천 경기'**
  String get cardTodayPick;

  /// No description provided for @cardUpdateLabel.
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get cardUpdateLabel;

  /// No description provided for @cardUpdating.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 중...'**
  String get cardUpdating;

  /// No description provided for @checkNow.
  ///
  /// In ko, this message translates to:
  /// **'확인하기'**
  String get checkNow;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @comboAiDisclaimer.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석 결과는 참고용이며, 결과를 보장하지 않습니다.'**
  String get comboAiDisclaimer;

  /// No description provided for @comboAiSummary.
  ///
  /// In ko, this message translates to:
  /// **'종합 평가'**
  String get comboAiSummary;

  /// No description provided for @comboAiWarning.
  ///
  /// In ko, this message translates to:
  /// **'주의사항'**
  String get comboAiWarning;

  /// No description provided for @comboAvgOdds.
  ///
  /// In ko, this message translates to:
  /// **'평균 배당'**
  String get comboAvgOdds;

  /// No description provided for @comboComboCount.
  ///
  /// In ko, this message translates to:
  /// **'조합 수'**
  String get comboComboCount;

  /// No description provided for @comboDashboardToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get comboDashboardToday;

  /// No description provided for @comboFoldCount.
  ///
  /// In ko, this message translates to:
  /// **'{count} COMBO'**
  String comboFoldCount(int count);

  /// No description provided for @comboHighOdds.
  ///
  /// In ko, this message translates to:
  /// **'고배당'**
  String get comboHighOdds;

  /// No description provided for @comboMatchFail.
  ///
  /// In ko, this message translates to:
  /// **'실패'**
  String get comboMatchFail;

  /// No description provided for @comboMatchHit.
  ///
  /// In ko, this message translates to:
  /// **'적중'**
  String get comboMatchHit;

  /// No description provided for @comboMatchPending.
  ///
  /// In ko, this message translates to:
  /// **'대기'**
  String get comboMatchPending;

  /// No description provided for @comboPicksCompleted.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 AI 조합 분석 완료'**
  String comboPicksCompleted(int count);

  /// No description provided for @comboReliability.
  ///
  /// In ko, this message translates to:
  /// **'신뢰도'**
  String get comboReliability;

  /// No description provided for @comboResultHitCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 적중'**
  String comboResultHitCount(int count);

  /// No description provided for @comboResultInProgressCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 진행 중'**
  String comboResultInProgressCount(int count);

  /// No description provided for @comboResultMissCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 미적중'**
  String comboResultMissCount(int count);

  /// No description provided for @comboResultPartialCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 부분 적중'**
  String comboResultPartialCount(int count);

  /// No description provided for @comboSafe.
  ///
  /// In ko, this message translates to:
  /// **'안전형'**
  String get comboSafe;

  /// No description provided for @comboSafeHitRate.
  ///
  /// In ko, this message translates to:
  /// **'안전형 적중률'**
  String get comboSafeHitRate;

  /// No description provided for @comboStatusHit.
  ///
  /// In ko, this message translates to:
  /// **'적중'**
  String get comboStatusHit;

  /// No description provided for @comboStatusInProgress.
  ///
  /// In ko, this message translates to:
  /// **'진행중'**
  String get comboStatusInProgress;

  /// No description provided for @comboStatusMiss.
  ///
  /// In ko, this message translates to:
  /// **'미적중'**
  String get comboStatusMiss;

  /// No description provided for @comboStatusPartial.
  ///
  /// In ko, this message translates to:
  /// **'부분'**
  String get comboStatusPartial;

  /// No description provided for @comboTotalOdds.
  ///
  /// In ko, this message translates to:
  /// **'총 배당'**
  String get comboTotalOdds;

  /// No description provided for @comboTypeHigh.
  ///
  /// In ko, this message translates to:
  /// **'고배당'**
  String get comboTypeHigh;

  /// No description provided for @comboTypeSafe.
  ///
  /// In ko, this message translates to:
  /// **'안전형'**
  String get comboTypeSafe;

  /// No description provided for @comboWin.
  ///
  /// In ko, this message translates to:
  /// **'승'**
  String get comboWin;

  /// No description provided for @confidenceAccuracy.
  ///
  /// In ko, this message translates to:
  /// **'정합도'**
  String get confidenceAccuracy;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ko, this message translates to:
  /// **'계정삭제'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountHint.
  ///
  /// In ko, this message translates to:
  /// **'\'DELETE\'를 입력하여 확인하세요.'**
  String get deleteAccountHint;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In ko, this message translates to:
  /// **'계정을 삭제하면 모든 데이터가 삭제되며 복구할 수 없습니다.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ko, this message translates to:
  /// **'계정 삭제'**
  String get deleteAccountTitle;

  /// No description provided for @emptyChangeDate.
  ///
  /// In ko, this message translates to:
  /// **'날짜 변경'**
  String get emptyChangeDate;

  /// No description provided for @emptyDataSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'나중에 다시 확인해 주세요.'**
  String get emptyDataSubtitle;

  /// No description provided for @emptyDataTitle.
  ///
  /// In ko, this message translates to:
  /// **'데이터가 없습니다.'**
  String get emptyDataTitle;

  /// No description provided for @emptyPremiumPickSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'오전 6시 또는 오후 6시에 다시 확인해 주세요.'**
  String get emptyPremiumPickSubtitle;

  /// No description provided for @emptyPremiumPickTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 픽이 없습니다.'**
  String get emptyPremiumPickTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다.'**
  String get errorGeneric;

  /// No description provided for @errorLogin.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다.'**
  String get errorLogin;

  /// No description provided for @errorNetwork.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요.'**
  String get errorNetwork;

  /// No description provided for @errorPayment.
  ///
  /// In ko, this message translates to:
  /// **'결제에 실패했습니다.'**
  String get errorPayment;

  /// No description provided for @errorContactFailed.
  ///
  /// In ko, this message translates to:
  /// **'문의 전송에 실패했습니다'**
  String get errorContactFailed;

  /// No description provided for @errorCooldownActive.
  ///
  /// In ko, this message translates to:
  /// **'{daysLeft}일 후 다시 시도해주세요'**
  String errorCooldownActive(int daysLeft);

  /// No description provided for @errorDeleteConfirmation.
  ///
  /// In ko, this message translates to:
  /// **'계정 삭제에 실패했습니다'**
  String get errorDeleteConfirmation;

  /// No description provided for @errorAccountDeleted.
  ///
  /// In ko, this message translates to:
  /// **'탈퇴한 계정입니다. 다른 계정으로 로그인해주세요.'**
  String get errorAccountDeleted;

  /// No description provided for @errorEmailRequired.
  ///
  /// In ko, this message translates to:
  /// **'이메일이 필요합니다'**
  String get errorEmailRequired;

  /// No description provided for @errorNaverLoginFailed.
  ///
  /// In ko, this message translates to:
  /// **'네이버 로그인에 실패했습니다. 다시 시도해주세요.'**
  String get errorNaverLoginFailed;

  /// No description provided for @errorNetworkTimeout.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해주세요'**
  String get errorNetworkTimeout;

  /// No description provided for @errorNotFound.
  ///
  /// In ko, this message translates to:
  /// **'요청한 정보를 찾을 수 없습니다'**
  String get errorNotFound;

  /// No description provided for @errorPaymentPending.
  ///
  /// In ko, this message translates to:
  /// **'결제 처리 중입니다. 잠시 후 다시 시도해주세요'**
  String get errorPaymentPending;

  /// No description provided for @errorPurchaseVerifyFailed.
  ///
  /// In ko, this message translates to:
  /// **'결제 확인에 실패했습니다'**
  String get errorPurchaseVerifyFailed;

  /// No description provided for @errorRateLimited.
  ///
  /// In ko, this message translates to:
  /// **'요청이 너무 많습니다. 잠시 후 다시 시도해주세요'**
  String get errorRateLimited;

  /// No description provided for @errorServerError.
  ///
  /// In ko, this message translates to:
  /// **'서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요'**
  String get errorServerError;

  /// No description provided for @errorSubscriptionRequired.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 구독이 필요합니다'**
  String get errorSubscriptionRequired;

  /// No description provided for @errorUnauthorized.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요합니다'**
  String get errorUnauthorized;

  /// No description provided for @errorUnknown.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다'**
  String get errorUnknown;

  /// No description provided for @exitConfirm.
  ///
  /// In ko, this message translates to:
  /// **'종료하기'**
  String get exitConfirm;

  /// No description provided for @exitMessage.
  ///
  /// In ko, this message translates to:
  /// **'TrendSoccer를 종료하시겠습니까?'**
  String get exitMessage;

  /// No description provided for @exitTitle.
  ///
  /// In ko, this message translates to:
  /// **'앱 종료'**
  String get exitTitle;

  /// No description provided for @filterAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get filterAll;

  /// No description provided for @fixtureCancelled.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get fixtureCancelled;

  /// No description provided for @fixtureEmpty.
  ///
  /// In ko, this message translates to:
  /// **'경기 일정이 없습니다.'**
  String get fixtureEmpty;

  /// No description provided for @fixtureInterrupted.
  ///
  /// In ko, this message translates to:
  /// **'중단'**
  String get fixtureInterrupted;

  /// No description provided for @baseballInningTop.
  ///
  /// In ko, this message translates to:
  /// **'{inning}회 초'**
  String baseballInningTop(int inning);

  /// No description provided for @baseballInningBottom.
  ///
  /// In ko, this message translates to:
  /// **'{inning}회 말'**
  String baseballInningBottom(int inning);

  /// No description provided for @fixtureLive.
  ///
  /// In ko, this message translates to:
  /// **'LIVE'**
  String get fixtureLive;

  /// No description provided for @fixtureLiveEmpty.
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 경기가 없습니다.'**
  String get fixtureLiveEmpty;

  /// No description provided for @fixtureLiveEmptyAction.
  ///
  /// In ko, this message translates to:
  /// **'오늘 경기 확인하기'**
  String get fixtureLiveEmptyAction;

  /// No description provided for @fixtureLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'경기 일정을 불러오지 못했습니다.'**
  String get fixtureLoadFailed;

  /// No description provided for @fixtureNoMatches.
  ///
  /// In ko, this message translates to:
  /// **'경기가 없습니다'**
  String get fixtureNoMatches;

  /// No description provided for @fixtureNoMatchesOnDate.
  ///
  /// In ko, this message translates to:
  /// **'선택한 날짜에 예정된 경기가 없습니다.'**
  String get fixtureNoMatchesOnDate;

  /// No description provided for @fixturePostponed.
  ///
  /// In ko, this message translates to:
  /// **'연기'**
  String get fixturePostponed;

  /// No description provided for @matchCancelled.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get matchCancelled;

  /// No description provided for @matchPostponed.
  ///
  /// In ko, this message translates to:
  /// **'연기'**
  String get matchPostponed;

  /// No description provided for @fixtureStatusFinal.
  ///
  /// In ko, this message translates to:
  /// **'FT'**
  String get fixtureStatusFinal;

  /// No description provided for @fixtureViewAllMatches.
  ///
  /// In ko, this message translates to:
  /// **'전체 경기 보기'**
  String get fixtureViewAllMatches;

  /// No description provided for @forceUpdateButton.
  ///
  /// In ko, this message translates to:
  /// **'업데이트'**
  String get forceUpdateButton;

  /// No description provided for @forceUpdateMessage.
  ///
  /// In ko, this message translates to:
  /// **'새로운 기능과 안정성 개선이 포함된 업데이트가 있습니다.'**
  String get forceUpdateMessage;

  /// No description provided for @forceUpdateSkip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get forceUpdateSkip;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In ko, this message translates to:
  /// **'업데이트 필요'**
  String get forceUpdateTitle;

  /// No description provided for @formInvalidEmail.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일 형식이 아닙니다'**
  String get formInvalidEmail;

  /// No description provided for @formRequired.
  ///
  /// In ko, this message translates to:
  /// **'필수 입력 항목입니다'**
  String get formRequired;

  /// No description provided for @goBack.
  ///
  /// In ko, this message translates to:
  /// **'뒤로가기'**
  String get goBack;

  /// No description provided for @guestBannerCta.
  ///
  /// In ko, this message translates to:
  /// **'지금 바로 프리미엄 체험하기 →'**
  String get guestBannerCta;

  /// No description provided for @guestBannerSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'분석 카드, 프리미엄 픽 등 모든 기능 이용'**
  String get guestBannerSubtitle;

  /// No description provided for @guestBannerTitle.
  ///
  /// In ko, this message translates to:
  /// **'지금 가입하고 48시간 무료 체험'**
  String get guestBannerTitle;

  /// No description provided for @helpCenterEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get helpCenterEmail;

  /// No description provided for @helpCenterIntro.
  ///
  /// In ko, this message translates to:
  /// **'문의 사항을 남겨주시면 이메일로 답변드리겠습니다.'**
  String get helpCenterIntro;

  /// No description provided for @helpCenterMessage.
  ///
  /// In ko, this message translates to:
  /// **'메세지'**
  String get helpCenterMessage;

  /// No description provided for @helpCenterName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get helpCenterName;

  /// No description provided for @helpCenterSend.
  ///
  /// In ko, this message translates to:
  /// **'문의 보내기'**
  String get helpCenterSend;

  /// No description provided for @helpCenterSubject.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get helpCenterSubject;

  /// No description provided for @helpCenterSubmit.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get helpCenterSubmit;

  /// No description provided for @helpCenterSubmitFail.
  ///
  /// In ko, this message translates to:
  /// **'전송에 실패했습니다. 다시 시도해주세요.'**
  String get helpCenterSubmitFail;

  /// No description provided for @helpCenterSubmitSuccess.
  ///
  /// In ko, this message translates to:
  /// **'문의가 성공적으로 전송되었습니다.'**
  String get helpCenterSubmitSuccess;

  /// No description provided for @helpCenterSuccess.
  ///
  /// In ko, this message translates to:
  /// **'문의가 접수되었습니다.'**
  String get helpCenterSuccess;

  /// No description provided for @helpCenterTitle.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get helpCenterTitle;

  /// No description provided for @labelAway.
  ///
  /// In ko, this message translates to:
  /// **'원정'**
  String get labelAway;

  /// No description provided for @labelAwayShort.
  ///
  /// In ko, this message translates to:
  /// **'A'**
  String get labelAwayShort;

  /// No description provided for @labelDraw.
  ///
  /// In ko, this message translates to:
  /// **'무'**
  String get labelDraw;

  /// No description provided for @labelDrawShort.
  ///
  /// In ko, this message translates to:
  /// **'D'**
  String get labelDrawShort;

  /// No description provided for @labelHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get labelHome;

  /// No description provided for @labelHomeShort.
  ///
  /// In ko, this message translates to:
  /// **'H'**
  String get labelHomeShort;

  /// No description provided for @labelOdds.
  ///
  /// In ko, this message translates to:
  /// **'배당'**
  String get labelOdds;

  /// No description provided for @labelPrediction.
  ///
  /// In ko, this message translates to:
  /// **'예측'**
  String get labelPrediction;

  /// No description provided for @labelRecommend.
  ///
  /// In ko, this message translates to:
  /// **'추천'**
  String get labelRecommend;

  /// No description provided for @labelOver.
  ///
  /// In ko, this message translates to:
  /// **'오버'**
  String get labelOver;

  /// No description provided for @labelUnder.
  ///
  /// In ko, this message translates to:
  /// **'언더'**
  String get labelUnder;

  /// No description provided for @labelWin.
  ///
  /// In ko, this message translates to:
  /// **'승'**
  String get labelWin;

  /// No description provided for @labelWinShort.
  ///
  /// In ko, this message translates to:
  /// **'W'**
  String get labelWinShort;

  /// No description provided for @languageSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get languageSettingsTitle;

  /// No description provided for @languageKorean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @languageEnglish.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @maintenanceTitle.
  ///
  /// In ko, this message translates to:
  /// **'서비스 점검 중'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'잠시 후 다시 시도해주세요.'**
  String get maintenanceSubtitle;

  /// No description provided for @legalLoadError.
  ///
  /// In ko, this message translates to:
  /// **'내용을 불러오지 못했습니다.'**
  String get legalLoadError;

  /// No description provided for @liveMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String liveMinutes(int minutes);

  /// No description provided for @loadMatchesFailed.
  ///
  /// In ko, this message translates to:
  /// **'경기 목록을 불러오지 못했습니다.'**
  String get loadMatchesFailed;

  /// No description provided for @loginAppBarTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get loginAppBarTitle;

  /// No description provided for @loginGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 시작하기'**
  String get loginGoogle;

  /// No description provided for @loginNaver.
  ///
  /// In ko, this message translates to:
  /// **'Naver로 시작하기'**
  String get loginNaver;

  /// No description provided for @loginNaverFailed.
  ///
  /// In ko, this message translates to:
  /// **'네이버 로그인에 실패했습니다. 다시 시도해주세요.'**
  String get loginNaverFailed;

  /// No description provided for @loginSheetDesc.
  ///
  /// In ko, this message translates to:
  /// **'H2H 상대전적부터 팀 심층 분석까지, 당신의 예측을 완성할 데이터를 확인하세요.'**
  String get loginSheetDesc;

  /// No description provided for @loginSheetTitle.
  ///
  /// In ko, this message translates to:
  /// **'더 스마트한 선택의 시작.'**
  String get loginSheetTitle;

  /// No description provided for @loginStart.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get loginStart;

  /// No description provided for @loginSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 AI가 읽어내는 축구와 야구의 흐름.\n정교한 데이터로 예측의 정확도를 높이세요.'**
  String get loginSubtitle;

  /// No description provided for @loginSuccess.
  ///
  /// In ko, this message translates to:
  /// **'로그인 성공'**
  String get loginSuccess;

  /// No description provided for @loginTitle.
  ///
  /// In ko, this message translates to:
  /// **'Better Data,\nSmarter Picks,\nFor Your Choice.'**
  String get loginTitle;

  /// No description provided for @matchAlarmDisabledGoSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get matchAlarmDisabledGoSettings;

  /// No description provided for @matchAlarmDisabledMessage.
  ///
  /// In ko, this message translates to:
  /// **'경기 알림이 꺼져 있습니다.\n메뉴 > 알림 설정에서 경기 알림을 켜주세요.'**
  String get matchAlarmDisabledMessage;

  /// No description provided for @matchAlarmDisabledTitle.
  ///
  /// In ko, this message translates to:
  /// **'경기 알림 비활성화'**
  String get matchAlarmDisabledTitle;

  /// No description provided for @matchAlarmSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'경기 알림 설정'**
  String get matchAlarmSettingsTitle;

  /// No description provided for @matchReportTitle.
  ///
  /// In ko, this message translates to:
  /// **'매치 리포트'**
  String get matchReportTitle;

  /// No description provided for @menuAbout.
  ///
  /// In ko, this message translates to:
  /// **'서비스 소개'**
  String get menuAbout;

  /// No description provided for @menuAppVersion.
  ///
  /// In ko, this message translates to:
  /// **'앱 버전'**
  String get menuAppVersion;

  /// No description provided for @menuDeleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'회원탈퇴'**
  String get menuDeleteAccount;

  /// No description provided for @menuExplore.
  ///
  /// In ko, this message translates to:
  /// **'Explore'**
  String get menuExplore;

  /// No description provided for @menuExploreSection.
  ///
  /// In ko, this message translates to:
  /// **'추가 기능'**
  String get menuExploreSection;

  /// No description provided for @menuHelpCenter.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get menuHelpCenter;

  /// No description provided for @menuLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get menuLanguage;

  /// No description provided for @menuMatchPreview.
  ///
  /// In ko, this message translates to:
  /// **'매치 프리뷰'**
  String get menuMatchPreview;

  /// No description provided for @menuNotification.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get menuNotification;

  /// No description provided for @menuOthers.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get menuOthers;

  /// No description provided for @menuPremiumExpiryDate.
  ///
  /// In ko, this message translates to:
  /// **'만료일 {date}'**
  String menuPremiumExpiryDate(String date);

  /// No description provided for @subscriptionCancelPending.
  ///
  /// In ko, this message translates to:
  /// **'구독 해지 예정'**
  String get subscriptionCancelPending;

  /// No description provided for @subscriptionExpiryDate.
  ///
  /// In ko, this message translates to:
  /// **'만료 예정'**
  String get subscriptionExpiryDate;

  /// No description provided for @subscriptionStartDate.
  ///
  /// In ko, this message translates to:
  /// **'구독 시작'**
  String get subscriptionStartDate;

  /// No description provided for @subscriptionNextBilling.
  ///
  /// In ko, this message translates to:
  /// **'다음 결제일'**
  String get subscriptionNextBilling;

  /// No description provided for @menuPrivacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침'**
  String get menuPrivacyPolicy;

  /// No description provided for @menuProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get menuProfile;

  /// No description provided for @menuSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get menuSettings;

  /// No description provided for @menuSettingsSection.
  ///
  /// In ko, this message translates to:
  /// **'앱 설정'**
  String get menuSettingsSection;

  /// No description provided for @menuSignOut.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get menuSignOut;

  /// No description provided for @menuSubscribe.
  ///
  /// In ko, this message translates to:
  /// **'구독'**
  String get menuSubscribe;

  /// No description provided for @menuSubscribeFree.
  ///
  /// In ko, this message translates to:
  /// **'구독 시작하기'**
  String get menuSubscribeFree;

  /// No description provided for @menuSubscribeInfoSection.
  ///
  /// In ko, this message translates to:
  /// **'구독 정보'**
  String get menuSubscribeInfoSection;

  /// No description provided for @menuSubscribeManage.
  ///
  /// In ko, this message translates to:
  /// **'구독 관리'**
  String get menuSubscribeManage;

  /// No description provided for @menuSubscribeManageTitle.
  ///
  /// In ko, this message translates to:
  /// **'구독 관리'**
  String get menuSubscribeManageTitle;

  /// No description provided for @menuSubscribePrompt.
  ///
  /// In ko, this message translates to:
  /// **'지금 구독 시작하고 프리미엄 데이터를 확인하세요.'**
  String get menuSubscribePrompt;

  /// No description provided for @menuSubscribeTitle.
  ///
  /// In ko, this message translates to:
  /// **'구독'**
  String get menuSubscribeTitle;

  /// No description provided for @menuSubscribeTrial.
  ///
  /// In ko, this message translates to:
  /// **'체험 중'**
  String get menuSubscribeTrial;

  /// No description provided for @menuTermsOfService.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get menuTermsOfService;

  /// No description provided for @menuTheme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get menuTheme;

  /// No description provided for @menuTrialExpired.
  ///
  /// In ko, this message translates to:
  /// **'체험 기간 만료'**
  String get menuTrialExpired;

  /// No description provided for @menuTrialRemaining.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 {minutes}분 남음'**
  String menuTrialRemaining(int hours, int minutes);

  /// No description provided for @noMatchInfo.
  ///
  /// In ko, this message translates to:
  /// **'경기 정보가 없습니다'**
  String get noMatchInfo;

  /// No description provided for @notificationAppGeneral.
  ///
  /// In ko, this message translates to:
  /// **'앱 알림'**
  String get notificationAppGeneral;

  /// No description provided for @notificationAppGeneralDesc.
  ///
  /// In ko, this message translates to:
  /// **'업데이트, 공지, 서비스 안내'**
  String get notificationAppGeneralDesc;

  /// No description provided for @notificationDisabledSnack.
  ///
  /// In ko, this message translates to:
  /// **'알림이 비활성화되었습니다. 설정에서 알림을 허용해주세요.'**
  String get notificationDisabledSnack;

  /// No description provided for @notificationMarketing.
  ///
  /// In ko, this message translates to:
  /// **'마케팅 알림'**
  String get notificationMarketing;

  /// No description provided for @notificationMarketingDesc.
  ///
  /// In ko, this message translates to:
  /// **'프로모션, 이벤트, 할인 안내'**
  String get notificationMarketingDesc;

  /// No description provided for @notificationMatchEvents.
  ///
  /// In ko, this message translates to:
  /// **'경기 알림'**
  String get notificationMatchEvents;

  /// No description provided for @notificationMatchEventsDesc.
  ///
  /// In ko, this message translates to:
  /// **'경기 이벤트 푸시 알림'**
  String get notificationMatchEventsDesc;

  /// No description provided for @notificationPermissionGoSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get notificationPermissionGoSettings;

  /// No description provided for @notificationPermissionMessage.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 필요합니다.\n설정에서 알림을 허용해주세요.'**
  String get notificationPermissionMessage;

  /// No description provided for @notificationPermissionMessageMatch.
  ///
  /// In ko, this message translates to:
  /// **'경기 알림을 받으려면 알림 권한이 필요합니다.\n설정에서 알림을 허용해주세요.'**
  String get notificationPermissionMessageMatch;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한 필요'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get notificationTitle;

  /// No description provided for @pickDirectionAway.
  ///
  /// In ko, this message translates to:
  /// **'원정'**
  String get pickDirectionAway;

  /// No description provided for @pickDirectionDraw.
  ///
  /// In ko, this message translates to:
  /// **'무'**
  String get pickDirectionDraw;

  /// No description provided for @pickDirectionHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get pickDirectionHome;

  /// No description provided for @pitcherTbd.
  ///
  /// In ko, this message translates to:
  /// **'미정'**
  String get pitcherTbd;

  /// No description provided for @planTicketExpiryDate.
  ///
  /// In ko, this message translates to:
  /// **'구독 만료일 : {date}'**
  String planTicketExpiryDate(String date);

  /// No description provided for @planTicketExpiryPendingDate.
  ///
  /// In ko, this message translates to:
  /// **'만료 예정일 : {date}'**
  String planTicketExpiryPendingDate(String date);

  /// No description provided for @planTicketFree.
  ///
  /// In ko, this message translates to:
  /// **'무료 플랜'**
  String get planTicketFree;

  /// No description provided for @planTicketFreeTitle.
  ///
  /// In ko, this message translates to:
  /// **'무료 플랜'**
  String get planTicketFreeTitle;

  /// No description provided for @planTicketPremium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 플랜'**
  String get planTicketPremium;

  /// No description provided for @planTicketPremiumTitle.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 플랜'**
  String get planTicketPremiumTitle;

  /// No description provided for @planTicketManage.
  ///
  /// In ko, this message translates to:
  /// **'구독 관리하기'**
  String get planTicketManage;

  /// No description provided for @planTicketRenew.
  ///
  /// In ko, this message translates to:
  /// **'구독 연장하기'**
  String get planTicketRenew;

  /// No description provided for @planTicketStart.
  ///
  /// In ko, this message translates to:
  /// **'구독 시작하기'**
  String get planTicketStart;

  /// No description provided for @planTicketTrialEnded.
  ///
  /// In ko, this message translates to:
  /// **'체험 종료'**
  String get planTicketTrialEnded;

  /// No description provided for @planTicketTrialRemaining.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 {minutes}분 남음'**
  String planTicketTrialRemaining(int hours, int minutes);

  /// No description provided for @planTicketStartDate.
  ///
  /// In ko, this message translates to:
  /// **'구독 시작일 : {date}'**
  String planTicketStartDate(String date);

  /// No description provided for @planTicketTrial.
  ///
  /// In ko, this message translates to:
  /// **'무료 체험 플랜'**
  String get planTicketTrial;

  /// No description provided for @planTicketTrialStartDate.
  ///
  /// In ko, this message translates to:
  /// **'체험 시작일 : {date}'**
  String planTicketTrialStartDate(String date);

  /// No description provided for @planTicketTrialTitle.
  ///
  /// In ko, this message translates to:
  /// **'체험 플랜'**
  String get planTicketTrialTitle;

  /// No description provided for @planTicketUpgrade.
  ///
  /// In ko, this message translates to:
  /// **'구독 업그레이드'**
  String get planTicketUpgrade;

  /// No description provided for @premiumBenefit24h.
  ///
  /// In ko, this message translates to:
  /// **'24시간 우선 분석 접근'**
  String get premiumBenefit24h;

  /// No description provided for @premiumBenefitBaseballAi.
  ///
  /// In ko, this message translates to:
  /// **'야구 AI Analysis'**
  String get premiumBenefitBaseballAi;

  /// No description provided for @premiumBenefitPremiumPick.
  ///
  /// In ko, this message translates to:
  /// **'PREMIUM PICK 무제한'**
  String get premiumBenefitPremiumPick;

  /// No description provided for @premiumBenefitsTitle.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 혜택'**
  String get premiumBenefitsTitle;

  /// No description provided for @premiumComboLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'야구 AI 조합을 불러오지 못했습니다.'**
  String get premiumComboLoadFailed;

  /// No description provided for @premiumExclusiveContent.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 전용 콘텐츠입니다.'**
  String get premiumExclusiveContent;

  /// No description provided for @premiumExclusiveShort.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 전용 콘텐츠'**
  String get premiumExclusiveShort;

  /// No description provided for @premiumNoHighConfidence.
  ///
  /// In ko, this message translates to:
  /// **'오늘 고신뢰도 픽이 없습니다'**
  String get premiumNoHighConfidence;

  /// No description provided for @parserReasonBasis.
  ///
  /// In ko, this message translates to:
  /// **'근거'**
  String get parserReasonBasis;

  /// No description provided for @parserReasonPatternMatches.
  ///
  /// In ko, this message translates to:
  /// **'{count} 경기 기반'**
  String parserReasonPatternMatches(int count);

  /// No description provided for @parserReasonPowerDiffPoints.
  ///
  /// In ko, this message translates to:
  /// **'{value}점'**
  String parserReasonPowerDiffPoints(String value);

  /// No description provided for @parserReasonProbEdge.
  ///
  /// In ko, this message translates to:
  /// **'확률 우위'**
  String get parserReasonProbEdge;

  /// No description provided for @premiumNonSubscriberSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석, PREMIUM PICK, 야구 조합\n광고 없는 쾌적한 환경'**
  String get premiumNonSubscriberSubtitle;

  /// No description provided for @premiumNonSubscriberTitle.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 전용 콘텐츠'**
  String get premiumNonSubscriberTitle;

  /// No description provided for @premiumPickLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 픽 목록을 불러오지 못했습니다.'**
  String get premiumPickLoadFailed;

  /// No description provided for @premiumSubscribeAfter.
  ///
  /// In ko, this message translates to:
  /// **'구독 후 이용하실 수 있습니다.'**
  String get premiumSubscribeAfter;

  /// No description provided for @premiumSubscribeBenefitsLine1.
  ///
  /// In ko, this message translates to:
  /// **'PREMIUM PICK과 야구 AI 조합 분석을'**
  String get premiumSubscribeBenefitsLine1;

  /// No description provided for @premiumSubscribeNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 구독하기'**
  String get premiumSubscribeNow;

  /// No description provided for @subscribeNow.
  ///
  /// In ko, this message translates to:
  /// **'지금 구독하기'**
  String get subscribeNow;

  /// No description provided for @subscribeToUnlock.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 구독으로 전체 예측을 확인하세요'**
  String get subscribeToUnlock;

  /// No description provided for @premiumSubscribeSheetBaseballDesc.
  ///
  /// In ko, this message translates to:
  /// **'승리 확률, 오버&언더, 시즌 통계 등 AI 분석 데이터를 이용해보세요.'**
  String get premiumSubscribeSheetBaseballDesc;

  /// No description provided for @premiumSubscribeSheetSoccerDesc.
  ///
  /// In ko, this message translates to:
  /// **'H2H 상대전적, 팀 심층 분석 등 프리미엄 혜택을 이용해보세요.'**
  String get premiumSubscribeSheetSoccerDesc;

  /// No description provided for @reportAuthorRole.
  ///
  /// In ko, this message translates to:
  /// **'축구 데이터 분석가'**
  String get reportAuthorRole;

  /// No description provided for @reportDetailLoadError.
  ///
  /// In ko, this message translates to:
  /// **'매치 프리뷰를 불러오지 못했습니다.'**
  String get reportDetailLoadError;

  /// No description provided for @reportEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'새 프리뷰가 등록되면 여기에 표시됩니다.'**
  String get reportEmptySubtitle;

  /// No description provided for @reportEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'등록된 매치 프리뷰가 없습니다.'**
  String get reportEmptyTitle;

  /// No description provided for @reportListLoadError.
  ///
  /// In ko, this message translates to:
  /// **'매치 프리뷰 목록을 불러오지 못했습니다.'**
  String get reportListLoadError;

  /// No description provided for @reportNotFoundSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'목록에서 다시 선택해 주세요.'**
  String get reportNotFoundSubtitle;

  /// No description provided for @reportNotFoundTitle.
  ///
  /// In ko, this message translates to:
  /// **'리포트를 찾을 수 없습니다.'**
  String get reportNotFoundTitle;

  /// No description provided for @reportPremiumOnlyMessage.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석 결과를 확인하려면 구독이 필요합니다'**
  String get reportPremiumOnlyMessage;

  /// No description provided for @reportPremiumOnlyTitle.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 구독 회원 전용 콘텐츠입니다'**
  String get reportPremiumOnlyTitle;

  /// No description provided for @reportTabAiAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'AI Analysis'**
  String get reportTabAiAnalysis;

  /// No description provided for @reportTabPremium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄'**
  String get reportTabPremium;

  /// No description provided for @reportTabStandard.
  ///
  /// In ko, this message translates to:
  /// **'스탠다드'**
  String get reportTabStandard;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @seasonCurrent.
  ///
  /// In ko, this message translates to:
  /// **'이번시즌'**
  String get seasonCurrent;

  /// No description provided for @seasonPrevious.
  ///
  /// In ko, this message translates to:
  /// **'이전시즌'**
  String get seasonPrevious;

  /// No description provided for @seeMore.
  ///
  /// In ko, this message translates to:
  /// **'더 보기 →'**
  String get seeMore;

  /// No description provided for @selectMatchFromAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'분석 페이지에서 경기를 선택해 주세요.'**
  String get selectMatchFromAnalysis;

  /// No description provided for @signOutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get signOutConfirm;

  /// No description provided for @signOutMessage.
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃 하시겠습니까?'**
  String get signOutMessage;

  /// No description provided for @signOutSuccess.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 되었습니다.'**
  String get signOutSuccess;

  /// No description provided for @signOutTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get signOutTitle;

  /// No description provided for @signupAgreeAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 동의'**
  String get signupAgreeAll;

  /// No description provided for @signupTermsAgree.
  ///
  /// In ko, this message translates to:
  /// **'이용약관 동의'**
  String get signupTermsAgree;

  /// No description provided for @signupPrivacyAgree.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침 동의'**
  String get signupPrivacyAgree;

  /// No description provided for @signupMarketingAgree.
  ///
  /// In ko, this message translates to:
  /// **'마케팅 이메일 수신 동의'**
  String get signupMarketingAgree;

  /// No description provided for @signupRequiredBadge.
  ///
  /// In ko, this message translates to:
  /// **'필수'**
  String get signupRequiredBadge;

  /// No description provided for @signupOptionalBadge.
  ///
  /// In ko, this message translates to:
  /// **'선택'**
  String get signupOptionalBadge;

  /// No description provided for @signupFreeBenefit1.
  ///
  /// In ko, this message translates to:
  /// **'기본 분석 데이터 확인'**
  String get signupFreeBenefit1;

  /// No description provided for @signupFreeBenefit2.
  ///
  /// In ko, this message translates to:
  /// **'실시간 스코어 및 경기 일정'**
  String get signupFreeBenefit2;

  /// No description provided for @signupFreeBenefit3.
  ///
  /// In ko, this message translates to:
  /// **'야구 Standard 분석 열람'**
  String get signupFreeBenefit3;

  /// No description provided for @signupTrialBannerSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'가입 즉시 프리미엄 기능 48시간 무료 체험'**
  String get signupTrialBannerSubtitle;

  /// No description provided for @signupWhatsNextBenefit1.
  ///
  /// In ko, this message translates to:
  /// **'48시간 무료 체험 종료 후 자동 무료 전환'**
  String get signupWhatsNextBenefit1;

  /// No description provided for @signupWhatsNextBenefit2.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 구독으로 모든 기능 이용 가능'**
  String get signupWhatsNextBenefit2;

  /// No description provided for @signupCompleteAppBarTitle.
  ///
  /// In ko, this message translates to:
  /// **'가입완료'**
  String get signupCompleteAppBarTitle;

  /// No description provided for @signupCompleteCountdown.
  ///
  /// In ko, this message translates to:
  /// **'{seconds}초 후 자동으로 홈으로 이동합니다.'**
  String signupCompleteCountdown(int seconds);

  /// No description provided for @signupCompleteFreeBenefit1.
  ///
  /// In ko, this message translates to:
  /// **'경기 시작 2시간 전 분석 오픈'**
  String get signupCompleteFreeBenefit1;

  /// No description provided for @signupCompleteFreeBenefit2.
  ///
  /// In ko, this message translates to:
  /// **'기본 분석 데이터 제공'**
  String get signupCompleteFreeBenefit2;

  /// No description provided for @signupCompleteFreeBenefit3.
  ///
  /// In ko, this message translates to:
  /// **'실시간 스코어 및 경기 일정'**
  String get signupCompleteFreeBenefit3;

  /// No description provided for @signupCompleteFreeBenefitsHeader.
  ///
  /// In ko, this message translates to:
  /// **'무료 혜택'**
  String get signupCompleteFreeBenefitsHeader;

  /// No description provided for @signupCompleteGoHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로 이동'**
  String get signupCompleteGoHome;

  /// No description provided for @signupCompletePremiumBenefit1.
  ///
  /// In ko, this message translates to:
  /// **'24시간 우선 분석 접근'**
  String get signupCompletePremiumBenefit1;

  /// No description provided for @signupCompletePremiumBenefit2.
  ///
  /// In ko, this message translates to:
  /// **'PREMIUM PICK 무제한'**
  String get signupCompletePremiumBenefit2;

  /// No description provided for @signupCompletePremiumBenefit3.
  ///
  /// In ko, this message translates to:
  /// **'야구 AI Analysis'**
  String get signupCompletePremiumBenefit3;

  /// No description provided for @signupCompletePremiumBenefitsHeader.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 혜택'**
  String get signupCompletePremiumBenefitsHeader;

  /// No description provided for @signupCompletePremiumUpgrade.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 업그레이드'**
  String get signupCompletePremiumUpgrade;

  /// No description provided for @signupCompleteStartPrompt.
  ///
  /// In ko, this message translates to:
  /// **'지금 트렌드사커를 시작해 보세요.'**
  String get signupCompleteStartPrompt;

  /// No description provided for @signupCompleteSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'48시간 프리미엄 체험이 시작되었습니다.'**
  String get signupCompleteSubtitle;

  /// No description provided for @signupCompleteSuccessToast.
  ///
  /// In ko, this message translates to:
  /// **'회원가입 완료! 프리미엄 체험을 시작합니다.'**
  String get signupCompleteSuccessToast;

  /// No description provided for @signupCompleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'환영합니다!'**
  String get signupCompleteTitle;

  /// No description provided for @signupCompleteTrialBanner.
  ///
  /// In ko, this message translates to:
  /// **'48시간 프리미엄 무료 체험이 시작되었습니다!'**
  String get signupCompleteTrialBanner;

  /// No description provided for @signupErrorProcessing.
  ///
  /// In ko, this message translates to:
  /// **'가입 처리 중 오류가 발생했습니다.'**
  String get signupErrorProcessing;

  /// No description provided for @signupMarketingOptional.
  ///
  /// In ko, this message translates to:
  /// **'마케팅 이메일 수신'**
  String get signupMarketingOptional;

  /// No description provided for @signupOptional.
  ///
  /// In ko, this message translates to:
  /// **'[선택]'**
  String get signupOptional;

  /// No description provided for @signupPageTitle.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get signupPageTitle;

  /// No description provided for @signupPrivacyRequired.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침'**
  String get signupPrivacyRequired;

  /// No description provided for @signupRequired.
  ///
  /// In ko, this message translates to:
  /// **'[필수]'**
  String get signupRequired;

  /// No description provided for @signupSubmit.
  ///
  /// In ko, this message translates to:
  /// **'가입하기'**
  String get signupSubmit;

  /// No description provided for @signupTermsHeadingLine1.
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용을 위해'**
  String get signupTermsHeadingLine1;

  /// No description provided for @signupTermsHeadingLine2.
  ///
  /// In ko, this message translates to:
  /// **'약관에 동의해주세요.'**
  String get signupTermsHeadingLine2;

  /// No description provided for @signupTermsHint.
  ///
  /// In ko, this message translates to:
  /// **'필수 항목에 동의하시면 가입이 완료됩니다.'**
  String get signupTermsHint;

  /// No description provided for @signupTermsRequired.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get signupTermsRequired;

  /// No description provided for @signupTermsTitle.
  ///
  /// In ko, this message translates to:
  /// **'약관 동의'**
  String get signupTermsTitle;

  /// No description provided for @signupView.
  ///
  /// In ko, this message translates to:
  /// **'보기'**
  String get signupView;

  /// No description provided for @skip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get skip;

  /// No description provided for @soccerAiPremiumOnly.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 전용 분석'**
  String get soccerAiPremiumOnly;

  /// No description provided for @soccerAiPremiumSubscribeHint.
  ///
  /// In ko, this message translates to:
  /// **'H2H 심층 분석과 팀 인사이트는 프리미엄 구독 후 이용할 수 있습니다.'**
  String get soccerAiPremiumSubscribeHint;

  /// No description provided for @soccerAnalysisReasoning.
  ///
  /// In ko, this message translates to:
  /// **'분석 근거'**
  String get soccerAnalysisReasoning;

  /// No description provided for @soccerAnalysisResult.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과'**
  String get soccerAnalysisResult;

  /// No description provided for @soccerAwayPower.
  ///
  /// In ko, this message translates to:
  /// **'원정 파워'**
  String get soccerAwayPower;

  /// No description provided for @soccerAwayWinPct.
  ///
  /// In ko, this message translates to:
  /// **'원정 {percent}%'**
  String soccerAwayWinPct(int percent);

  /// No description provided for @soccerDraw.
  ///
  /// In ko, this message translates to:
  /// **'무승부'**
  String get soccerDraw;

  /// No description provided for @soccerEventFulltime.
  ///
  /// In ko, this message translates to:
  /// **'경기 종료'**
  String get soccerEventFulltime;

  /// No description provided for @soccerEventGoal.
  ///
  /// In ko, this message translates to:
  /// **'득점'**
  String get soccerEventGoal;

  /// No description provided for @soccerEventHalftime.
  ///
  /// In ko, this message translates to:
  /// **'하프타임'**
  String get soccerEventHalftime;

  /// No description provided for @soccerEventKickoff.
  ///
  /// In ko, this message translates to:
  /// **'경기 시작'**
  String get soccerEventKickoff;

  /// No description provided for @soccerEventRedCard.
  ///
  /// In ko, this message translates to:
  /// **'퇴장'**
  String get soccerEventRedCard;

  /// No description provided for @soccerEventSubstitution.
  ///
  /// In ko, this message translates to:
  /// **'선수 교체'**
  String get soccerEventSubstitution;

  /// No description provided for @soccerEventYellowCard.
  ///
  /// In ko, this message translates to:
  /// **'경고'**
  String get soccerEventYellowCard;

  /// No description provided for @soccerFinalProbability.
  ///
  /// In ko, this message translates to:
  /// **'최종 예측 확률'**
  String get soccerFinalProbability;

  /// No description provided for @soccerH2h.
  ///
  /// In ko, this message translates to:
  /// **'H2H'**
  String get soccerH2h;

  /// No description provided for @soccerH2hAllTime.
  ///
  /// In ko, this message translates to:
  /// **'역대 전적'**
  String get soccerH2hAllTime;

  /// No description provided for @soccerH2hAvgGoals.
  ///
  /// In ko, this message translates to:
  /// **'평균 득점'**
  String get soccerH2hAvgGoals;

  /// No description provided for @soccerH2hInsights.
  ///
  /// In ko, this message translates to:
  /// **'매치 인사이트'**
  String get soccerH2hInsights;

  /// No description provided for @soccerH2hLoading.
  ///
  /// In ko, this message translates to:
  /// **'H2H 분석 로딩 중...'**
  String get soccerH2hLoading;

  /// No description provided for @soccerH2hMaxScore.
  ///
  /// In ko, this message translates to:
  /// **'최대 스코어'**
  String get soccerH2hMaxScore;

  /// No description provided for @soccerH2hRecent.
  ///
  /// In ko, this message translates to:
  /// **'최근 맞대결'**
  String get soccerH2hRecent;

  /// No description provided for @soccerH2hMatchCount.
  ///
  /// In ko, this message translates to:
  /// **'({count}경기)'**
  String soccerH2hMatchCount(int count);

  /// No description provided for @soccerH2hStatistics.
  ///
  /// In ko, this message translates to:
  /// **'통계'**
  String get soccerH2hStatistics;

  /// No description provided for @soccerHomePower.
  ///
  /// In ko, this message translates to:
  /// **'홈 파워'**
  String get soccerHomePower;

  /// No description provided for @soccerHomeWinPct.
  ///
  /// In ko, this message translates to:
  /// **'홈 {percent}%'**
  String soccerHomeWinPct(int percent);

  /// No description provided for @soccerMarketBtts.
  ///
  /// In ko, this message translates to:
  /// **'BTTS'**
  String get soccerMarketBtts;

  /// No description provided for @soccerMarketCs.
  ///
  /// In ko, this message translates to:
  /// **'CS'**
  String get soccerMarketCs;

  /// No description provided for @soccerMarketFts.
  ///
  /// In ko, this message translates to:
  /// **'FTS'**
  String get soccerMarketFts;

  /// No description provided for @soccerMarketIndicators.
  ///
  /// In ko, this message translates to:
  /// **'마켓 지표 (최근 10경기)'**
  String get soccerMarketIndicators;

  /// No description provided for @soccerMethod3.
  ///
  /// In ko, this message translates to:
  /// **'3-Method 분석'**
  String get soccerMethod3;

  /// No description provided for @soccerMethodFirstGoal.
  ///
  /// In ko, this message translates to:
  /// **'선제골'**
  String get soccerMethodFirstGoal;

  /// No description provided for @soccerMethodMinMax.
  ///
  /// In ko, this message translates to:
  /// **'MIN-MAX 비교'**
  String get soccerMethodMinMax;

  /// No description provided for @soccerMethodPaCompare.
  ///
  /// In ko, this message translates to:
  /// **'P/A비교'**
  String get soccerMethodPaCompare;

  /// No description provided for @soccerOddsAway.
  ///
  /// In ko, this message translates to:
  /// **'원정 승'**
  String get soccerOddsAway;

  /// No description provided for @soccerOddsDraw.
  ///
  /// In ko, this message translates to:
  /// **'무승부'**
  String get soccerOddsDraw;

  /// No description provided for @soccerOddsHome.
  ///
  /// In ko, this message translates to:
  /// **'홈 승'**
  String get soccerOddsHome;

  /// No description provided for @soccerPowerDiff.
  ///
  /// In ko, this message translates to:
  /// **'파워차'**
  String get soccerPowerDiff;

  /// No description provided for @soccerPowerIndex.
  ///
  /// In ko, this message translates to:
  /// **'파워 인덱스'**
  String get soccerPowerIndex;

  /// No description provided for @soccerPremiumOnly.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 전용'**
  String get soccerPremiumOnly;

  /// No description provided for @soccerRecent10.
  ///
  /// In ko, this message translates to:
  /// **'최근 10경기'**
  String get soccerRecent10;

  /// No description provided for @soccerRecentForm.
  ///
  /// In ko, this message translates to:
  /// **'최근 폼'**
  String get soccerRecentForm;

  /// No description provided for @soccerReasonFirstGoalAway.
  ///
  /// In ko, this message translates to:
  /// **'원정 선득점 승률'**
  String get soccerReasonFirstGoalAway;

  /// No description provided for @soccerReasonFirstGoalHome.
  ///
  /// In ko, this message translates to:
  /// **'홈 선득점 승률'**
  String get soccerReasonFirstGoalHome;

  /// No description provided for @soccerSeasonAway.
  ///
  /// In ko, this message translates to:
  /// **'시즌 원정 성적'**
  String get soccerSeasonAway;

  /// No description provided for @soccerSeasonHome.
  ///
  /// In ko, this message translates to:
  /// **'시즌 홈 성적'**
  String get soccerSeasonHome;

  /// No description provided for @soccerStatAnalyzedMatches.
  ///
  /// In ko, this message translates to:
  /// **'분석 경기'**
  String get soccerStatAnalyzedMatches;

  /// No description provided for @soccerStatComebackRate.
  ///
  /// In ko, this message translates to:
  /// **'역전률'**
  String get soccerStatComebackRate;

  /// No description provided for @soccerStatFirstGoalRate.
  ///
  /// In ko, this message translates to:
  /// **'선제골 승률'**
  String get soccerStatFirstGoalRate;

  /// No description provided for @soccerStatGoalDifference.
  ///
  /// In ko, this message translates to:
  /// **'득실비'**
  String get soccerStatGoalDifference;

  /// No description provided for @soccerStatGoalLine.
  ///
  /// In ko, this message translates to:
  /// **'골 라인'**
  String get soccerStatGoalLine;

  /// No description provided for @soccerStatLosses.
  ///
  /// In ko, this message translates to:
  /// **'패'**
  String get soccerStatLosses;

  /// No description provided for @soccerStatOver15.
  ///
  /// In ko, this message translates to:
  /// **'O 1.5'**
  String get soccerStatOver15;

  /// No description provided for @soccerStatOver25.
  ///
  /// In ko, this message translates to:
  /// **'O 2.5'**
  String get soccerStatOver25;

  /// No description provided for @soccerStatOver35.
  ///
  /// In ko, this message translates to:
  /// **'O 3.5'**
  String get soccerStatOver35;

  /// No description provided for @soccerStatPattern.
  ///
  /// In ko, this message translates to:
  /// **'패턴 통계'**
  String get soccerStatPattern;

  /// No description provided for @soccerStatPowerDiff.
  ///
  /// In ko, this message translates to:
  /// **'파워차'**
  String get soccerStatPowerDiff;

  /// No description provided for @soccerStatTeamInsights.
  ///
  /// In ko, this message translates to:
  /// **'팀 인사이트'**
  String get soccerStatTeamInsights;

  /// No description provided for @soccerStatTeamStats.
  ///
  /// In ko, this message translates to:
  /// **'팀 상세 통계'**
  String get soccerStatTeamStats;

  /// No description provided for @soccerStatWinProb.
  ///
  /// In ko, this message translates to:
  /// **'승리 확률'**
  String get soccerStatWinProb;

  /// No description provided for @soccerStatWinRate.
  ///
  /// In ko, this message translates to:
  /// **'승률'**
  String get soccerStatWinRate;

  /// No description provided for @soccerStatWins.
  ///
  /// In ko, this message translates to:
  /// **'승'**
  String get soccerStatWins;

  /// No description provided for @sportBaseball.
  ///
  /// In ko, this message translates to:
  /// **'야구'**
  String get sportBaseball;

  /// No description provided for @sportSoccer.
  ///
  /// In ko, this message translates to:
  /// **'축구'**
  String get sportSoccer;

  /// No description provided for @subscribeAlreadyOwned.
  ///
  /// In ko, this message translates to:
  /// **'이미 구독 중입니다. 기존 구독을 확인합니다.'**
  String get subscribeAlreadyOwned;

  /// No description provided for @subscribeBack.
  ///
  /// In ko, this message translates to:
  /// **'돌아가기'**
  String get subscribeBack;

  /// No description provided for @subscribeDiscount.
  ///
  /// In ko, this message translates to:
  /// **'33% OFF'**
  String get subscribeDiscount;

  /// No description provided for @subscribeFailAttemptAmount.
  ///
  /// In ko, this message translates to:
  /// **'결제 시도 금액'**
  String get subscribeFailAttemptAmount;

  /// No description provided for @subscribeFailDescription.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도하거나 다른 결제 수단을 이용해주세요.'**
  String get subscribeFailDescription;

  /// No description provided for @subscribeFailErrorCode.
  ///
  /// In ko, this message translates to:
  /// **'오류 코드'**
  String get subscribeFailErrorCode;

  /// No description provided for @subscribeFailMessage.
  ///
  /// In ko, this message translates to:
  /// **'결제에 실패했습니다.'**
  String get subscribeFailMessage;

  /// No description provided for @subscribeFailRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도하기'**
  String get subscribeFailRetry;

  /// No description provided for @subscribeFailTitle.
  ///
  /// In ko, this message translates to:
  /// **'결제 실패'**
  String get subscribeFailTitle;

  /// No description provided for @subscribeFreeBenefit1.
  ///
  /// In ko, this message translates to:
  /// **'분석 카드 킥오프 2시간 전 공개'**
  String get subscribeFreeBenefit1;

  /// No description provided for @subscribeFreeBenefit2.
  ///
  /// In ko, this message translates to:
  /// **'기본 경기 분석 및 통계'**
  String get subscribeFreeBenefit2;

  /// No description provided for @subscribeFreeBenefit3.
  ///
  /// In ko, this message translates to:
  /// **'실시간 스코어 및 경기 일정'**
  String get subscribeFreeBenefit3;

  /// No description provided for @subscribeFreeBenefit4.
  ///
  /// In ko, this message translates to:
  /// **'광고 포함'**
  String get subscribeFreeBenefit4;

  /// No description provided for @subscribeGoHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로 돌아가기'**
  String get subscribeGoHome;

  /// No description provided for @subscribeHeader.
  ///
  /// In ko, this message translates to:
  /// **'Get Full Access To The AI Assistant'**
  String get subscribeHeader;

  /// No description provided for @subscribeHeaderLine1.
  ///
  /// In ko, this message translates to:
  /// **'Get Full Access To'**
  String get subscribeHeaderLine1;

  /// No description provided for @subscribeHeaderLine2.
  ///
  /// In ko, this message translates to:
  /// **'The AI Assistant !'**
  String get subscribeHeaderLine2;

  /// No description provided for @subscribeIapCannotStart.
  ///
  /// In ko, this message translates to:
  /// **'Google Play 결제를 시작할 수 없습니다.'**
  String get subscribeIapCannotStart;

  /// No description provided for @subscribeIapPreparing.
  ///
  /// In ko, this message translates to:
  /// **'Google Play 결제 준비 중...'**
  String get subscribeIapPreparing;

  /// No description provided for @subscribeIapProcessing.
  ///
  /// In ko, this message translates to:
  /// **'Google Play 결제 처리 중...'**
  String get subscribeIapProcessing;

  /// No description provided for @subscribeIapRestoring.
  ///
  /// In ko, this message translates to:
  /// **'기존 구독 확인 중...'**
  String get subscribeIapRestoring;

  /// No description provided for @subscribeIapUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'Google Play 결제를 사용할 수 없습니다.'**
  String get subscribeIapUnavailable;

  /// No description provided for @subscribeIapVerifyPending.
  ///
  /// In ko, this message translates to:
  /// **'결제는 완료되었으나 검증 대기 중입니다. 잠시 후 앱을 재시작해주세요.'**
  String get subscribeIapVerifyPending;

  /// No description provided for @subscribeManageOnPlay.
  ///
  /// In ko, this message translates to:
  /// **'Google Play에서 구독 관리'**
  String get subscribeManageOnPlay;

  /// No description provided for @subscribePeriodMonths.
  ///
  /// In ko, this message translates to:
  /// **'{months}개월'**
  String subscribePeriodMonths(int months);

  /// No description provided for @subscribePlanFree.
  ///
  /// In ko, this message translates to:
  /// **'무료'**
  String get subscribePlanFree;

  /// No description provided for @subscribePlanMonthly.
  ///
  /// In ko, this message translates to:
  /// **'1개월'**
  String get subscribePlanMonthly;

  /// No description provided for @subscribePlanPremium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄'**
  String get subscribePlanPremium;

  /// No description provided for @subscribePlanQuarterly.
  ///
  /// In ko, this message translates to:
  /// **'3개월'**
  String get subscribePlanQuarterly;

  /// No description provided for @subscribePremiumActive.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 구독 중'**
  String get subscribePremiumActive;

  /// No description provided for @subscribePremiumBenefit1.
  ///
  /// In ko, this message translates to:
  /// **'모든 분석 24시간 우선 접근'**
  String get subscribePremiumBenefit1;

  /// No description provided for @subscribePremiumBenefit2.
  ///
  /// In ko, this message translates to:
  /// **'축구 프리미엄픽 무제한'**
  String get subscribePremiumBenefit2;

  /// No description provided for @subscribePremiumBenefit3.
  ///
  /// In ko, this message translates to:
  /// **'AI 야구 분석 전체 공개'**
  String get subscribePremiumBenefit3;

  /// No description provided for @subscribePremiumBenefit4.
  ///
  /// In ko, this message translates to:
  /// **'야구 조합 픽'**
  String get subscribePremiumBenefit4;

  /// No description provided for @subscribePremiumBenefit5.
  ///
  /// In ko, this message translates to:
  /// **'광고 없는 경험'**
  String get subscribePremiumBenefit5;

  /// No description provided for @subscribePremiumExpiry.
  ///
  /// In ko, this message translates to:
  /// **'만료일: {date}'**
  String subscribePremiumExpiry(String date);

  /// No description provided for @subscribePremiumMessage.
  ///
  /// In ko, this message translates to:
  /// **'현재 프리미엄 구독을 이용 중입니다.'**
  String get subscribePremiumMessage;

  /// No description provided for @subscribePriceMonthly.
  ///
  /// In ko, this message translates to:
  /// **'₩4,900'**
  String get subscribePriceMonthly;

  /// No description provided for @subscribePriceQuarterly.
  ///
  /// In ko, this message translates to:
  /// **'₩9,900'**
  String get subscribePriceQuarterly;

  /// No description provided for @subscribeReceiptAmount.
  ///
  /// In ko, this message translates to:
  /// **'결제 금액'**
  String get subscribeReceiptAmount;

  /// No description provided for @subscribeReceiptPlan.
  ///
  /// In ko, this message translates to:
  /// **'구독 플랜'**
  String get subscribeReceiptPlan;

  /// No description provided for @subscribeSelectProduct.
  ///
  /// In ko, this message translates to:
  /// **'구독 상품 선택'**
  String get subscribeSelectProduct;

  /// No description provided for @subscribeStartPremium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 구독 시작하기'**
  String get subscribeStartPremium;

  /// No description provided for @subscribeStartPremiumArrow.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 구독 시작하기 →'**
  String get subscribeStartPremiumArrow;

  /// No description provided for @subscribeSuccessCTA.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 분석 시작하기'**
  String get subscribeSuccessCTA;

  /// No description provided for @subscribeSuccessComplete.
  ///
  /// In ko, this message translates to:
  /// **'구독이 완료되었습니다.'**
  String get subscribeSuccessComplete;

  /// No description provided for @subscribeSuccessSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'지금 바로 프리미엄 혜택을 이용해보세요.'**
  String get subscribeSuccessSubtitle;

  /// No description provided for @subscribeSuccessTitle.
  ///
  /// In ko, this message translates to:
  /// **'결제 완료'**
  String get subscribeSuccessTitle;

  /// No description provided for @subscribeTrialActive.
  ///
  /// In ko, this message translates to:
  /// **'48시간 프리미엄 체험 중'**
  String get subscribeTrialActive;

  /// No description provided for @subscribeTrialMessage.
  ///
  /// In ko, this message translates to:
  /// **'체험 기간 종료 후 구독할 수 있습니다.'**
  String get subscribeTrialMessage;

  /// No description provided for @subscribeTrialRemaining.
  ///
  /// In ko, this message translates to:
  /// **'남은 시간: {hours}시간 {minutes}분'**
  String subscribeTrialRemaining(int hours, int minutes);

  /// No description provided for @subscribeTrialRemainingZero.
  ///
  /// In ko, this message translates to:
  /// **'남은 시간: 0시간 0분'**
  String get subscribeTrialRemainingZero;

  /// No description provided for @subscribeUpdating.
  ///
  /// In ko, this message translates to:
  /// **'구독 정보 업데이트 중...'**
  String get subscribeUpdating;

  /// No description provided for @tabAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'분석'**
  String get tabAnalysis;

  /// No description provided for @tabFixture.
  ///
  /// In ko, this message translates to:
  /// **'일정'**
  String get tabFixture;

  /// No description provided for @tabMenu.
  ///
  /// In ko, this message translates to:
  /// **'메뉴'**
  String get tabMenu;

  /// No description provided for @tabPremium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄'**
  String get tabPremium;

  /// No description provided for @tabTrend.
  ///
  /// In ko, this message translates to:
  /// **'트렌드'**
  String get tabTrend;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트 모드'**
  String get themeLight;

  /// No description provided for @themeSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'테마 설정'**
  String get themeSettingsTitle;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정'**
  String get themeSystem;

  /// No description provided for @today.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get today;

  /// No description provided for @todayCombination.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 추천 조합'**
  String get todayCombination;

  /// No description provided for @todayPremiumPick.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 추천 경기'**
  String get todayPremiumPick;

  /// No description provided for @trendBaseballAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'야구 분석'**
  String get trendBaseballAnalysis;

  /// No description provided for @trendEmptySubtitle1.
  ///
  /// In ko, this message translates to:
  /// **'현재 진행 중인 공식 리그 일정이 없습니다.'**
  String get trendEmptySubtitle1;

  /// No description provided for @trendEmptySubtitle2.
  ///
  /// In ko, this message translates to:
  /// **'시즌 재개 시 더욱 스마트한 데이터를 제공해 드립니다.'**
  String get trendEmptySubtitle2;

  /// No description provided for @trendEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'다음 경기를 기다리고 있습니다.'**
  String get trendEmptyTitle;

  /// No description provided for @trendNoBaseballScheduled.
  ///
  /// In ko, this message translates to:
  /// **'예정된 야구 경기가 없습니다.'**
  String get trendNoBaseballScheduled;

  /// No description provided for @trendNoSoccerScheduled.
  ///
  /// In ko, this message translates to:
  /// **'예정된 축구 경기가 없습니다.'**
  String get trendNoSoccerScheduled;

  /// No description provided for @trendPremiumAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 분석'**
  String get trendPremiumAnalysis;

  /// No description provided for @trendSoccerAnalysis.
  ///
  /// In ko, this message translates to:
  /// **'축구 분석'**
  String get trendSoccerAnalysis;

  /// No description provided for @weekdayFri.
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get weekdayFri;

  /// No description provided for @weekdayMon.
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get weekdayMon;

  /// No description provided for @weekdaySat.
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get weekdaySun;

  /// No description provided for @weekdayThu.
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get weekdayThu;

  /// No description provided for @weekdayTue.
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get weekdayWed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
