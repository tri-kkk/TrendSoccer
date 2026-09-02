import 'package:trendsoccer/core/services/soccer_service.dart';

const _baseballAnalysisLeagueCodes = {'MLB', 'NPB', 'KBO'};

/// Whether a fixture row may show the AI analysis badge (league code only, no date).
bool leagueSupportsAnalysis(String sport, String? leagueCode) {
  final code = leagueCode?.trim().toUpperCase();
  if (code == null || code.isEmpty) return false;

  if (sport == 'baseball') {
    return _baseballAnalysisLeagueCodes.contains(code);
  }

  return SoccerService.analysisLeagueCodes
      .map((entry) => entry.toUpperCase())
      .contains(code);
}
