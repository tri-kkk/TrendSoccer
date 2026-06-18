/// Hardcoded analysis league chips (always show all 11 leagues + 전체).
class SoccerAnalysisLeagueChip {
  const SoccerAnalysisLeagueChip({
    required this.id,
    required this.label,
    required this.labelEn,
    this.codes,
    this.iconId,
  });

  final String id;
  final String label;
  final String labelEn;
  final List<String>? codes;
  final String? iconId;

  bool get isAll => codes == null;

  /// Chip label for the current locale.
  String get displayLabel {
    // TODO: Switch to labelEn when locale is 'en'
    return label;
  }
}

const soccerAnalysisLeagueChips = [
  SoccerAnalysisLeagueChip(
    id: 'all',
    label: '전체',
    labelEn: 'All',
  ),
  SoccerAnalysisLeagueChip(
    id: 'champions_league',
    label: 'UCL',
    labelEn: 'UCL',
    codes: ['UCL', 'CL'],
    iconId: 'champions_league',
  ),
  SoccerAnalysisLeagueChip(
    id: 'europa_league',
    label: 'UEL',
    labelEn: 'UEL',
    codes: ['UEL', 'EL'],
    iconId: 'europa_league',
  ),
  SoccerAnalysisLeagueChip(
    id: 'premier_league',
    label: '프리미어리그',
    labelEn: 'EPL',
    codes: ['PL'],
    iconId: 'premier_league',
  ),
  SoccerAnalysisLeagueChip(
    id: 'laliga',
    label: '라리가',
    labelEn: 'La Liga',
    codes: ['PD'],
    iconId: 'laliga',
  ),
  SoccerAnalysisLeagueChip(
    id: 'bundesliga',
    label: '분데스리가',
    labelEn: 'Bundesliga',
    codes: ['BL1'],
    iconId: 'bundesliga',
  ),
  SoccerAnalysisLeagueChip(
    id: 'serie_a',
    label: '세리에A',
    labelEn: 'Serie A',
    codes: ['SA'],
    iconId: 'serie_a',
  ),
  SoccerAnalysisLeagueChip(
    id: 'ligue_1',
    label: '리그1',
    labelEn: 'Ligue 1',
    codes: ['FL1'],
    iconId: 'ligue_1',
  ),
  SoccerAnalysisLeagueChip(
    id: 'eredivisie',
    label: '에레디비지',
    labelEn: 'Eredivisie',
    codes: ['DED'],
    iconId: 'eredivisie',
  ),
  SoccerAnalysisLeagueChip(
    id: 'mls',
    label: 'MLS',
    labelEn: 'MLS',
    codes: ['MLS'],
    iconId: 'mls',
  ),
  SoccerAnalysisLeagueChip(
    id: 'k_league',
    label: 'K리그',
    labelEn: 'K League',
    codes: ['KL', 'KL1', 'KL2'],
    iconId: 'k_league',
  ),
  SoccerAnalysisLeagueChip(
    id: 'j1_league',
    label: 'J리그',
    labelEn: 'J League',
    codes: ['J1'],
    iconId: 'j1_league',
  ),
];
