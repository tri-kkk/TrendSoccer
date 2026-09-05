/// Gauge fraction helpers for baseball report blocks 05–09.
///
/// Mirrors the `_ratioForValues` logic in
/// `baseball_starting_pitchers_report_block.dart` without modifying blocks 01–04.
double baseballRatioForNullableValues(
  double? homeValue,
  double? awayValue, {
  required bool lowerIsBetter,
}) {
  return baseballRatioForValues(
    homeValue ?? 0,
    awayValue ?? 0,
    lowerIsBetter: lowerIsBetter,
  );
}

double baseballRatioForValues(
  double homeValue,
  double awayValue, {
  required bool lowerIsBetter,
}) {
  if (lowerIsBetter) {
    if (homeValue <= 0 && awayValue <= 0) return 0.5;
    if (homeValue <= 0) return 0;
    if (awayValue <= 0) return 1;
    final homeScore = 1 / homeValue;
    final awayScore = 1 / awayValue;
    final total = homeScore + awayScore;
    return total > 0 ? (homeScore / total).clamp(0.0, 1.0) : 0.5;
  }

  final total = homeValue + awayValue;
  return total > 0 ? (homeValue / total).clamp(0.0, 1.0) : 0.5;
}

double? parseBaseballPercentValue(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed.toUpperCase() == 'N/A') return null;

  final percentPart = trimmed.contains(' (')
      ? trimmed.substring(0, trimmed.indexOf(' ('))
      : trimmed;
  return double.tryParse(percentPart.replaceAll('%', '').trim());
}

String formatBaseballProductionValue(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(1);
}

String formatBaseballSeasonDecimal(double? value, {required int decimals}) {
  if (value == null) return '-';
  return value.toStringAsFixed(decimals);
}

String formatBaseballProbabilityLabel(double? value) {
  if (value == null) return '-';
  final percent = value <= 1 ? value * 100 : value;
  return '${percent.round()}%';
}
