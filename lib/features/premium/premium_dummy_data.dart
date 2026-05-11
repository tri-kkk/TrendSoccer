import 'package:trendsoccer/features/trend/trend_dummy_data.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_card.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_status_badge.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_type_badge.dart';

final List<AnalysisCardData> premiumPickDummy = [
  AnalysisCardData(
    matchId: 'pp1',
    leagueId: 'ucl',
    leagueName: 'UCL',
    date: '05.11',
    homeTeam: 'Barcelona',
    awayTeam: 'Bayern',
    matchTime: '21:00',
    isPremiumPick: true,
    pickDirection: 'home',
    winRate: '72%',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'pp2',
    leagueId: 'epl',
    leagueName: 'EPL',
    date: '05.11',
    homeTeam: 'Arsenal',
    awayTeam: 'Chelsea',
    matchTime: '18:30',
    isPremiumPick: true,
    pickDirection: 'away',
    winRate: '65%',
    sport: 'soccer',
  ),
  AnalysisCardData(
    matchId: 'pp3',
    leagueId: 'seriea',
    leagueName: 'Serie A',
    date: '05.11',
    homeTeam: 'Juventus',
    awayTeam: 'AC Milan',
    matchTime: '19:00',
    isPremiumPick: true,
    pickDirection: 'draw',
    winRate: '58%',
    sport: 'soccer',
  ),
];

class ComboDayData {
  const ComboDayData({
    required this.dateLabel,
    required this.dateTitle,
    required this.comboCountText,
    required this.comboCount,
    required this.accuracy,
    required this.avgOdds,
    required this.safeHitRate,
    required this.safeHitDetail,
    required this.highOddsHitRate,
    required this.highOddsHitDetail,
    required this.combos,
  });

  final String dateLabel;
  final String dateTitle;
  final String comboCountText;
  final int comboCount;
  final String accuracy;
  final String avgOdds;
  final String safeHitRate;
  final String safeHitDetail;
  final String highOddsHitRate;
  final String highOddsHitDetail;
  final List<ComboCardDummy> combos;
}

class ComboCardDummy {
  const ComboCardDummy({
    required this.leagueId,
    required this.comboCount,
    required this.comboType,
    required this.status,
    required this.matches,
    required this.aiReport,
    required this.totalOdds,
    required this.confidence,
  });

  final String leagueId;
  final int comboCount;
  final ComboType comboType;
  final ComboStatus status;
  final List<ComboMatchRowData> matches;
  final String aiReport;
  final String totalOdds;
  final String confidence;
}

final List<ComboDayData> comboDaysDummy = [
  ComboDayData(
    dateLabel: '오늘',
    dateTitle: '5월 11일 (일)',
    comboCountText: '4개 AI 조합 분석 완료',
    comboCount: 4,
    accuracy: '50%',
    avgOdds: '3.85',
    safeHitRate: '60%',
    safeHitDetail: '(3/5)',
    highOddsHitRate: '33%',
    highOddsHitDetail: '(1/3)',
    combos: [
      ComboCardDummy(
        leagueId: 'kbo',
        comboCount: 2,
        comboType: ComboType.safe,
        status: ComboStatus.inProgress,
        matches: [
          const ComboMatchRowData(
            homeTeam: 'LG Twins',
            awayTeam: 'KT Wiz',
            predictTeam: 'LG Twins',
            predictDirection: '홈',
            odds: '1.55',
            winRate: '68%',
            winRateRatio: 0.68,
            comment: '최근 5연승 홈팀 우세',
          ),
          const ComboMatchRowData(
            homeTeam: 'Samsung',
            awayTeam: 'Doosan',
            predictTeam: 'Samsung',
            predictDirection: '홈',
            odds: '1.70',
            winRate: '62%',
            winRateRatio: 0.62,
            comment: '홈 구장 이점 활용',
          ),
        ],
        aiReport: '두 경기 모두 홈팀 우세. 최근 10경기 기록 압도적.',
        totalOdds: '2.64',
        confidence: '87%',
      ),
      ComboCardDummy(
        leagueId: 'mlb',
        comboCount: 2,
        comboType: ComboType.highOdds,
        status: ComboStatus.inProgress,
        matches: [
          const ComboMatchRowData(
            homeTeam: 'Yankees',
            awayTeam: 'Red Sox',
            predictTeam: 'Red Sox',
            predictDirection: '원정',
            odds: '2.30',
            winRate: '48%',
            winRateRatio: 0.48,
            comment: '선발 투수 매치업 원정 유리',
          ),
          const ComboMatchRowData(
            homeTeam: 'Dodgers',
            awayTeam: 'Giants',
            predictTeam: 'Dodgers',
            predictDirection: '홈',
            odds: '1.45',
            winRate: '71%',
            winRateRatio: 0.71,
            comment: '홈 승률 압도적',
          ),
        ],
        aiReport: '원정 고배당 Red Sox 선발 우위 + Dodgers 홈 안정성 조합.',
        totalOdds: '3.34',
        confidence: '62%',
      ),
    ],
  ),
  ComboDayData(
    dateLabel: '5.10',
    dateTitle: '5월 10일 (토)',
    comboCountText: '3개 AI 조합 분석 완료',
    comboCount: 3,
    accuracy: '67%',
    avgOdds: '2.90',
    safeHitRate: '100%',
    safeHitDetail: '(2/2)',
    highOddsHitRate: '0%',
    highOddsHitDetail: '(0/1)',
    combos: [
      ComboCardDummy(
        leagueId: 'kbo',
        comboCount: 2,
        comboType: ComboType.safe,
        status: ComboStatus.hit,
        matches: [
          ComboMatchRowData(
            homeTeam: 'NC',
            awayTeam: 'SSG',
            predictTeam: 'SSG',
            predictDirection: '원정',
            odds: '1.80',
            winRate: '58%',
            winRateRatio: 0.58,
            comment: '원정 SSG 최근 폼 상승',
            matchResult: ComboStatus.hit,
            homeScore: '3',
            awayScore: '6',
          ),
          ComboMatchRowData(
            homeTeam: 'Kiwoom',
            awayTeam: 'Lotte',
            predictTeam: 'Kiwoom',
            predictDirection: '홈',
            odds: '1.50',
            winRate: '65%',
            winRateRatio: 0.65,
            comment: '홈 구장 강세',
            matchResult: ComboStatus.hit,
            homeScore: '5',
            awayScore: '2',
          ),
        ],
        aiReport: '두 경기 모두 적중! SSG 원정 폼 예측 정확.',
        totalOdds: '2.70',
        confidence: '91%',
      ),
    ],
  ),
];

final List<String> comboDateLabels = [
  '오늘',
  '5.10',
  '5.9',
  '5.8',
  '5.7',
  '5.6',
  '5.5',
  '5.4',
];
