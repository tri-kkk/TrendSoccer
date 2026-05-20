abstract final class VersionUtils {
  static bool isVersionOutdated(String currentVersion, String minVersion) {
    return compareVersions(currentVersion, minVersion) < 0;
  }

  static int compareVersions(String currentVersion, String minVersion) {
    final current = _parseParts(currentVersion);
    final minimum = _parseParts(minVersion);
    final length = current.length > minimum.length
        ? current.length
        : minimum.length;

    for (var i = 0; i < length; i++) {
      final currentPart = i < current.length ? current[i] : 0;
      final minPart = i < minimum.length ? minimum[i] : 0;
      if (currentPart != minPart) {
        return currentPart.compareTo(minPart);
      }
    }
    return 0;
  }

  static List<int> _parseParts(String version) {
    final core = version.split('+').first.trim();
    if (core.isEmpty) return const [0];

    return core.split('.').map((part) {
      final digits = part.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(digits.isEmpty ? '0' : digits) ?? 0;
    }).toList();
  }
}
