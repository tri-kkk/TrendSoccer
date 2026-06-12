import 'package:intl/intl.dart';

bool isKoreanLocaleCode(String locale) =>
    locale.toLowerCase().startsWith('ko');

/// e.g. KO: "6월 12일 18:30" / EN: "Jun 12 18:30"
String formatMatchDateMonthDayTime(String locale, DateTime local) {
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  if (isKoreanLocaleCode(locale)) {
    return '${local.month}월 ${local.day}일 $hour:$minute';
  }
  final month = DateFormat('MMM', 'en').format(local);
  return '$month ${local.day} $hour:$minute';
}

/// e.g. KO: "6월 12일 수요일 18:30" / EN: "Jun 12 (Wed) 18:30"
String formatMatchDateWithWeekdayAndTime(String locale, DateTime local) {
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  if (isKoreanLocaleCode(locale)) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[local.weekday - 1];
    return '${local.month}월 ${local.day}일 $weekday요일 $hour:$minute';
  }
  final month = DateFormat('MMM', 'en').format(local);
  final weekday = DateFormat('EEE', 'en').format(local);
  return '$month ${local.day} ($weekday) $hour:$minute';
}
