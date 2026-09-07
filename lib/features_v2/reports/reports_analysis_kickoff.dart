import 'package:intl/intl.dart';

import 'package:trendsoccer/core/utils/match_date_formatter.dart';

/// Reports analysis card kickoff — e.g. EN "Aug 18 · 04:00", KO "8월 18일 · 04:00".
///
/// Date portion follows [formatMatchDateMonthDayTime] locale rules; time is HH:mm
/// with a middle dot separator per Figma.
String reportsAnalysisKickoffLabel(String locale, DateTime local) {
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final time = '$hour:$minute';
  if (isKoreanLocaleCode(locale)) {
    return '${local.month}월 ${local.day}일 · $time';
  }
  final month = DateFormat('MMM', 'en').format(local);
  return '$month ${local.day} · $time';
}
