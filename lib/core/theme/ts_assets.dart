import 'package:flutter/material.dart';

/// Centralized bundle asset paths with theme-aware helpers.
abstract final class TsAssets {
  static String logoHorizon(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/logo/dark/horizon.svg'
          : 'assets/images/logo/light/horizon.svg';

  static String logoVertical(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/logo/dark/vertical.svg'
          : 'assets/images/logo/light/vertical.svg';

  static String logoSymbol(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/logo/dark/symbol.svg'
          : 'assets/images/logo/light/symbol.svg';

  static String logoEditor(Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/logo/dark/editor.svg'
          : 'assets/images/logo/light/editor.svg';

  static String leagueIcon(String leagueId, Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/league/icon/dark/$leagueId.svg'
          : 'assets/images/league/icon/light/$leagueId.svg';

  static String leagueLogo(String leagueId, Brightness brightness) =>
      brightness == Brightness.dark
          ? 'assets/images/league/logo/dark/$leagueId.svg'
          : 'assets/images/league/logo/light/$leagueId.svg';

  static const socialGoogle = 'assets/images/social/google.svg';
  static const socialNaver = 'assets/images/social/naver.svg';

  static const planFree = 'assets/images/plan/free.png';
  static const planTrial = 'assets/images/plan/trial.png';
  static const planPremium = 'assets/images/plan/premium.png';
}
