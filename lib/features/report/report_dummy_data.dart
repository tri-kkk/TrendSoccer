class SoccerReportData {
  const SoccerReportData({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.leagueId,
    required this.date,
    required this.author,
    required this.content,
  });

  final String id;
  final String title;
  final String? thumbnailUrl;
  final String leagueId;
  final String date;
  final String author;
  final String content;
}

final List<SoccerReportData> soccerReportsDummy = [
  SoccerReportData(
    id: 'sr-01',
    title: 'UCL 준결승 프리뷰: 바르셀로나 vs 바이에른 뮌헨',
    leagueId: 'ucl',
    date: '2026.05.11',
    author: 'TrendSoccer',
    content:
        '바르셀로나와 바이에른 뮌헨의 UEFA 챔피언스리그 준결승 1차전이 다가오고 있습니다.\n\n양 팀 모두 시즌 내내 강력한 모습을 보여주며 이번 경기에서도 치열한 접전이 예상됩니다.\n\n바르셀로나는 홈에서 이번 시즌 UCL 무패 행진을 이어가고 있으며, 특히 세트피스 상황에서 높은 득점력을 발휘하고 있습니다.\n\n반면 바이에른은 원정 경기에서도 안정적인 수비력을 보여주고 있어, 이번 경기의 결과를 예측하기 어렵습니다.\n\n주요 분석 포인트:\n1. 바르셀로나의 홈 경기 세트피스 득점력\n2. 바이에른의 높은 프레싱과 역습 능력\n3. 양 팀 미드필드 장악력 비교\n4. 최근 5경기 상대 전적 분석',
  ),
  SoccerReportData(
    id: 'sr-02',
    title: 'EPL 34라운드 주요 경기 분석',
    leagueId: 'epl',
    date: '2026.05.10',
    author: 'TrendSoccer',
    content:
        'EPL 34라운드가 다가오면서 우승과 잔류를 위한 치열한 경쟁이 펼쳐지고 있습니다.\n\n특히 아스널 vs 첼시 경기는 이번 라운드의 빅매치로 꼽히며, 양 팀의 최근 폼과 전력을 분석합니다.',
  ),
  SoccerReportData(
    id: 'sr-03',
    title: 'La Liga 우승 경쟁: 레알 마드리드 vs 아틀레티코',
    leagueId: 'laliga',
    date: '2026.05.09',
    author: 'TrendSoccer',
    content:
        '라리가 우승 경쟁이 막바지에 접어들면서 레알 마드리드와 아틀레티코 마드리드의 직접 대결이 주목받고 있습니다.',
  ),
  SoccerReportData(
    id: 'sr-04',
    title: 'Bundesliga 클래식커: 바이에른 vs 도르트문트 프리뷰',
    leagueId: 'bundesliga',
    date: '2026.05.08',
    author: 'TrendSoccer',
    content: '분데스리가 최고의 라이벌전 데어 클라시커가 돌아왔습니다.',
  ),
  SoccerReportData(
    id: 'sr-05',
    title: 'Serie A 주간 리뷰: 유벤투스의 반등',
    leagueId: 'seriea',
    date: '2026.05.07',
    author: 'TrendSoccer',
    content: '유벤투스가 최근 3연승을 기록하며 UCL 진출권 경쟁에 다시 뛰어들었습니다.',
  ),
  SoccerReportData(
    id: 'sr-06',
    title: 'UCL 8강 결과 종합 분석',
    leagueId: 'ucl',
    date: '2026.05.06',
    author: 'TrendSoccer',
    content: 'UCL 8강전이 모두 마무리되었습니다. 예상대로 강호들이 4강에 이름을 올렸습니다.',
  ),
  SoccerReportData(
    id: 'sr-07',
    title: 'EPL 하위권 잔류 전쟁: 남은 일정 분석',
    leagueId: 'epl',
    date: '2026.05.05',
    author: 'TrendSoccer',
    content:
        'EPL 하위권 잔류 경쟁이 치열해지고 있습니다. 남은 경기 일정과 상대 전력을 분석합니다.',
  ),
  SoccerReportData(
    id: 'sr-08',
    title: 'K리그 전반기 중간 점검',
    leagueId: 'kleague',
    date: '2026.05.04',
    author: 'TrendSoccer',
    content: 'K리그 전반기가 중반을 넘기면서 각 팀의 전력을 점검합니다.',
  ),
];
