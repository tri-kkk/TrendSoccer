import 'package:flutter/material.dart';

/// Centralized bundle asset paths with theme-aware helpers.
abstract final class TsAssets {
  static String logoHorizon(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/tsLogo/dark/horizon.svg'
          : 'assets/images/tsLogo/light/horizon.svg';

  static String logoVertical(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/tsLogo/dark/vertical.svg'
          : 'assets/images/tsLogo/light/vertical.svg';

  static String logoSymbol(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/tsLogo/dark/symbol.svg'
          : 'assets/images/tsLogo/light/symbol.svg';

  static String logoEditor(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/tsLogo/dark/editor.svg'
          : 'assets/images/tsLogo/light/editor.svg';

  static String leagueIcon(String leagueId, Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/league/icon/dark/$leagueId.svg'
          : 'assets/images/league/icon/light/$leagueId.svg';

  static String leagueLogo(String leagueId, Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/league/logo/dark/$leagueId.svg'
          : 'assets/images/league/logo/light/$leagueId.svg';

  /// Maps API [league_code] values to local league icon asset ids.
  static String? leagueIconIdFromApiCode(String? apiCode) {
    if (apiCode == null || apiCode.isEmpty) return null;
    return _apiLeagueCodeToIconId[apiCode.toUpperCase()];
  }

  static const _apiLeagueCodeToIconId = <String, String>{
    'PL': 'premier_league',
    'PD': 'laliga',
    'BL1': 'bundesliga',
    'SA': 'serie_a',
    'FL1': 'ligue_1',
    'DED': 'eredivisie',
    'MLS': 'mls',
    'KL': 'k_league',
    'KL1': 'k_league',
    'KL2': 'k_league',
    'J1': 'j1_league',
    'UCL': 'champions_league',
    'CL': 'champions_league',
    'UEL': 'europa_league',
    'EL': 'europa_league',
  };

  static const socialGoogle = 'assets/images/social/google.svg';
  static const socialNaver = 'assets/images/social/naver.svg';

  static const planFree = 'assets/images/plan/free.png';
  static const planTrial = 'assets/images/plan/trial.png';
  static const planPremium = 'assets/images/plan/premium.png';

  // Foundation Icons
  static const iconTrend = 'assets/images/icon/foundation/trend.svg';
  static const iconAnalysis = 'assets/images/icon/foundation/analysis.svg';
  static const iconFixture = 'assets/images/icon/foundation/fixture.svg';
  static const iconPremium = 'assets/images/icon/foundation/premium.svg';
  static const iconMenu = 'assets/images/icon/foundation/menu.svg';
  static const iconArrowBack = 'assets/images/icon/foundation/arrow_back.svg';
  static const iconNotifications =
      'assets/images/icon/foundation/notifications.svg';
  static const iconNotificationsNone =
      'assets/images/icon/foundation/notifications_none.svg';
  static const iconAccountCircle =
      'assets/images/icon/foundation/account_circle.svg';
  static const iconInfo = 'assets/images/icon/foundation/info.svg';
  static const iconPrivacyTip = 'assets/images/icon/foundation/privacy_tip.svg';
  static const iconBlog = 'assets/images/icon/foundation/blog.svg';
  static const iconHelp = 'assets/images/icon/foundation/help.svg';
  static const iconVersionInfo =
      'assets/images/icon/foundation/version_info.svg';
  static const iconTheme = 'assets/images/icon/foundation/theme.svg';
  static const iconLanguage = 'assets/images/icon/foundation/language.svg';
  static const iconCheckboxChecked =
      'assets/images/icon/foundation/checkbox_checked.svg';
  static const iconCheckboxUnchecked =
      'assets/images/icon/foundation/checkbox_unchecked.svg';
  static const iconCheckboxPartial =
      'assets/images/icon/foundation/checkbox_partial.svg';
  static const iconRadioChecked =
      'assets/images/icon/foundation/radio_checked.svg';
  static const iconRadioUnchecked =
      'assets/images/icon/foundation/radio_unchecked.svg';
  static const iconCelebration =
      'assets/images/icon/foundation/celebration.svg';
  static const iconRocketLaunch =
      'assets/images/icon/foundation/rocket_launch.svg';
  static const iconWarning = 'assets/images/icon/foundation/warning.svg';
  static const iconHourglassEmpty =
      'assets/images/icon/foundation/hourglass_empty.svg';
  static const iconCheckCircle =
      'assets/images/icon/foundation/check_circle.svg';
  static const iconCheckSmall =
      'assets/images/icon/foundation/check_small.svg';

  // Sport Icons
  static const sportSoccerPrimary =
      'assets/images/icon/sport/soccer_primary.svg';
  static const sportSoccerOnPrimary =
      'assets/images/icon/sport/soccer_on_primary.svg';
  static const sportBaseballPrimary =
      'assets/images/icon/sport/baseball_primary.svg';
  static const sportBaseballOnPrimary =
      'assets/images/icon/sport/baseball_on_primary.svg';
}
