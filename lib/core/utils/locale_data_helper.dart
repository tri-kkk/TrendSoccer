import 'package:flutter/material.dart';

/// Display-layer helpers for API fields that provide English and Korean names.

String? _optionalLocalizedName(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == '-') return null;
  return trimmed;
}

String _localizedBilingualName({
  required String locale,
  String? nameEn,
  String? nameKo,
}) {
  final en = _optionalLocalizedName(nameEn);
  final ko = _optionalLocalizedName(nameKo);

  if (locale == 'ko') {
    return ko ?? en ?? '';
  }
  return en ?? ko ?? '';
}

String localizedTeamName(
  BuildContext context,
  String? nameEn,
  String? nameKo,
) {
  return _localizedBilingualName(
    locale: Localizations.localeOf(context).languageCode,
    nameEn: nameEn,
    nameKo: nameKo,
  );
}

String localizedLeagueName(
  BuildContext context,
  String? nameEn,
  String? nameKo,
) {
  return localizedTeamName(context, nameEn, nameKo);
}

String localizedPitcherName(
  BuildContext context,
  String? nameEn,
  String? nameKo,
) {
  final locale = Localizations.localeOf(context).languageCode;
  final en = _optionalLocalizedName(nameEn);
  final ko = _optionalLocalizedName(nameKo);

  if (locale == 'ko') {
    return ko ?? en ?? '';
  }
  return en ?? ko ?? '';
}

bool isKoreanLocale(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ko';

/// Korean-first name for KBO/NPB stats API lookup (DB keys are Korean).
String baseballAsianLeagueApiLookupName(String? nameEn, String? nameKo) {
  final ko = _optionalLocalizedName(nameKo);
  if (ko != null) return ko;
  return _optionalLocalizedName(nameEn) ?? '';
}

/// Korean-first team name for KBO/NPB stats API lookup.
String baseballAsianLeagueApiLookupTeam(String? nameEn, String? nameKo) {
  final ko = _optionalLocalizedName(nameKo);
  if (ko != null) return ko;
  return _optionalLocalizedName(nameEn) ?? (nameEn?.trim() ?? '');
}

/// Localizes streak text from API (e.g. "2연승" → "2 Streak" in English).
String localizedStreak(BuildContext context, String? streak) {
  if (streak == null || streak.isEmpty) return '';
  if (streak == '-') return streak;
  if (isKoreanLocale(context)) {
    return _koreanStreakDisplay(streak);
  }

  final match = RegExp(r'(\d+)(연승|연속 일치|연속|연패|무)').firstMatch(streak);
  if (match != null) {
    final count = match.group(1);
    final type = match.group(2);
    return switch (type) {
      '연승' || '연속 일치' || '연속' => '$count Streak',
      '연패' => '$count Loss',
      '무' => '$count Draw',
      _ => streak,
    };
  }
  return streak;
}

String _koreanStreakDisplay(String streak) {
  final alreadyFormatted = RegExp(r'^(\d+) 연속$').firstMatch(streak);
  if (alreadyFormatted != null) return streak;

  final winFromEn = RegExp(r'^(\d+) Win$').firstMatch(streak);
  if (winFromEn != null) return '${winFromEn.group(1)} 연속';

  final streakFromEn = RegExp(r'^(\d+) (?:Consecutive Matches|Streak)$')
      .firstMatch(streak);
  if (streakFromEn != null) return '${streakFromEn.group(1)} 연속';

  final koWin =
      RegExp(r'^(\d+)(?:연승|연속(?:\s*일치)?)$').firstMatch(streak);
  if (koWin != null) return '${koWin.group(1)} 연속';

  return streak;
}
