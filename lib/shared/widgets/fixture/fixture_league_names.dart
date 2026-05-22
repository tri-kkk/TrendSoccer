/// Hardcoded Korean display names for league codes when the API omits [leagueName].
const fixtureLeagueNameMap = <String, String>{
  'PL': '프리미어리그',
  'PD': '라리가',
  'BL1': '분데스리가',
  'SA': '세리에A',
  'FL1': '리그1',
  'DED': '에레디비지',
  'MLS': 'MLS',
  'KL': 'K리그1',
  'KL1': 'K리그1',
  'KL2': 'K리그2',
  'J1': 'J리그',
  'UCL': '챔피언스리그',
  'UEL': '유로파리그',
  'ECL': '컨퍼런스리그',
  'DSL': '수페르리가엔',
  'SPL': '스코틀랜드 프리미어리그',
  'SAL': '사우디 프로리그',
  'EGY': '이집트 프리미어리그',
  'GSL': '그리스 슈퍼리그',
  'SSL': '스위스 슈퍼리그',
  'JPL': '벨기에 주필러리그',
  'BSA': '브라질레이랑',
  'PPL': '포르투갈 프리메이라',
  'SB': '세리에B',
  'BL2': '분데스리가2',
  'CHP': '챔피언십',
  'L2': '리그2',
  'MX': '리가MX',
  'CSL': '중국 슈퍼리그',
  'ALG': '알제리 리그',
  'MAR': '모로코 리그',
  'TUN': '튀니지 리그',
  'RSA': '남아공 프리미어리그',
  'AUS': 'A리그',
  'AMATCH': 'A매치',
  'CL2': 'AFC 챔피언스리그2',
  'COPA': '코파 리베르타도레스',
  'COSU': '코파 수다메리카나',
  'DZA': '알제리 리그',
  'LMX': '리가MX',
  'ABL': '오스트리아 분데스리가',
  'TDP': '포르투갈 타사',
  'SD': '세군다 디비시온',
  'ELC': '챔피언십',
  'CDF': '쿠프 드 프랑스',
  'DFB': 'DFB 포칼',
  'ARG': '아르헨티나 프리메라',
  'KBO': 'KBO',
  'MLB': 'MLB',
  'NPB': 'NPB',
  'CPBL': 'CPBL',
};

String fixtureDisplayLeagueName(String? name, String? code) {
  final trimmedName = name?.trim();
  final trimmedCode = code?.trim().toUpperCase();

  if (trimmedName != null &&
      trimmedName.isNotEmpty &&
      trimmedName.toUpperCase() != trimmedCode) {
    return trimmedName;
  }

  if (trimmedCode != null &&
      trimmedCode.isNotEmpty &&
      fixtureLeagueNameMap.containsKey(trimmedCode)) {
    return fixtureLeagueNameMap[trimmedCode]!;
  }

  return trimmedName ?? code?.trim() ?? '';
}
