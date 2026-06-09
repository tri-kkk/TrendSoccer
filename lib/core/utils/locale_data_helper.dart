import 'package:flutter/material.dart';

/// Display-layer helpers for API fields that provide English and Korean names.
String localizedTeamName(
  BuildContext context,
  String? nameEn,
  String? nameKo,
) {
  final locale = Localizations.localeOf(context).languageCode;
  final en = nameEn?.trim() ?? '';
  final ko = nameKo?.trim() ?? '';
  if (locale == 'ko') {
    return ko.isNotEmpty ? ko : en;
  }
  return en.isNotEmpty ? en : ko;
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
  return localizedTeamName(context, nameEn, nameKo);
}

bool isKoreanLocale(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ko';

/// Localizes Korean streak text from API (e.g. "2연승" → "2 Win").
String localizedStreak(BuildContext context, String? streak) {
  if (streak == null || streak.isEmpty) return '';
  if (streak == '-') return streak;
  if (isKoreanLocale(context)) return streak;

  final match = RegExp(r'(\d+)(연승|연패|무)').firstMatch(streak);
  if (match != null) {
    final count = match.group(1);
    final type = match.group(2);
    return switch (type) {
      '연승' => '$count Win',
      '연패' => '$count Loss',
      '무' => '$count Draw',
      _ => streak,
    };
  }
  return streak;
}
