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
