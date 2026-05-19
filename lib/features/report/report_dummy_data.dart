class SoccerReportData {
  const SoccerReportData({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.leagueId,
    required this.date,
    required this.author,
    required this.content,
  });

  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String leagueId;
  final String date;
  final String author;
  final String content;
}

final List<SoccerReportData> soccerReportsDummy = [
  SoccerReportData(
    id: 'sr-01',
    title: 'EPL 35R 맨시티 vs 아스널 프리뷰',
    description: '시즌 최대 빅매치, 양 팀 전력 분석과 핵심 변수를 짚어봅니다.',
    leagueId: 'premier_league',
    date: '2026.05.15',
    author: 'TrendSoccer',
    content:
        '시즌 최대 빅매치가 다가왔습니다. 맨시티와 아스널의 35라운드 직접 대결은 이번 시즌 우승 향방을 결정짓는 분수령이 될 전망입니다.\n'
        '맨시티는 최근 10경기에서 8승 1무 1패를 기록하며 상승세를 이어가고 있습니다. 특히 홈에서의 득점력이 경기당 평균 2.4골로 리그 최고 수준입니다.\n'
        '반면 아스널은 원정 경기에서 꾸준한 수비력을 자랑하지만, 최근 핵심 미드필더의 부상으로 중원 장악력에 의문이 제기되고 있습니다.',
  ),
  SoccerReportData(
    id: 'sr-02',
    title: 'UCL 4강 레알 마드리드 vs 바이에른 뮌헨',
    description: '챔피언스리그 4강 1차전 맞대결 분석 리포트.',
    leagueId: 'champions_league',
    date: '2026.05.15',
    author: 'TrendSoccer',
    content:
        '챔피언스리그 4강 1차전, 레알 마드리드와 바이에른 뮌헨의 맞대결은 유럽 최고의 두 거함이 펼치는 전술 대결이 될 것입니다.\n'
        '레알 마드리드는 홈에서의 압도적인 경기 운영과 세트피스 득점력을 바탕으로 4강 진출에 성공했습니다. 특히 후반전 집중력이 뛰어나 70분 이후 득점 비율이 높습니다.\n'
        '바이에른은 높은 라인에서 시작하는 프레싱과 빠른 역습으로 상대 수비를 흔들며, 원정에서도 평균 1.8골을 기록하고 있습니다.',
  ),
  SoccerReportData(
    id: 'sr-03',
    title: '라리가 32R 바르셀로나 vs AT 마드리드',
    description: '라리가 우승 경쟁 빅매치, 양 팀 최근 폼과 전술 분석',
    leagueId: 'laliga',
    date: '2026.05.15',
    author: 'TrendSoccer',
    content:
        '라리가 우승 경쟁이 막바지에 접어들면서 바르셀로나와 아틀레티코 마드리드의 직접 대결이 빅매치로 주목받고 있습니다.\n'
        '바르셀로나는 최근 5경기 연속 승리를 거두며 공격 전개의 템포를 높였고, 홈에서의 점유율이 65%를 넘깁니다.\n'
        '아틀레티코는 수비 조직력과 카운터 어택을 무기로 원정에서도 실점을 최소화하며, 최근 4경기에서 3승 1무를 기록했습니다.',
  ),
  SoccerReportData(
    id: 'sr-04',
    title: '분데스리가 30R 도르트문트 vs 레버쿠젠',
    description: '분데스리가 상위권 직접 대결, 득점력과 수비력 비교',
    leagueId: 'bundesliga',
    date: '2026.05.15',
    author: 'TrendSoccer',
    content:
        '분데스리가 상위권 직접 대결에서 도르트문트와 레버쿠젠이 맞붙습니다. 양 팀 모두 챔피언스리그 진출권을 놓고 치열한 경쟁을 이어가고 있습니다.\n'
        '도르트문트는 홈에서의 득점력이 경기당 2.1골로 리그 상위권이며, 측면 돌파와 크로스 연결을 적극 활용합니다.\n'
        '레버쿠젠은 전 라인에서의 압박과 빠른 전환을 통해 상대 수비를 붕괴시키며, 최근 6경기에서 5승 1무의 성적을 거두었습니다.',
  ),
  SoccerReportData(
    id: 'sr-05',
    title: '리포트 타이틀',
    description: '디스크립션 텍스트',
    leagueId: 'serie_a',
    date: '2026.05.15',
    author: 'TrendSoccer',
    content: '리포트 본문 콘텐츠.',
  ),
  SoccerReportData(
    id: 'sr-06',
    title: '리포트 타이틀',
    description: '디스크립션 텍스트',
    leagueId: 'ligue_1',
    date: '2026.05.15',
    author: 'TrendSoccer',
    content: '리포트 본문 콘텐츠.',
  ),
];
