import 'package:flutter/foundation.dart';

import 'package:trendsoccer/shared/widgets/combo/combo_card.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_status_badge.dart';
import 'package:trendsoccer/shared/widgets/combo/combo_type_badge.dart';

class ComboDashboardData {
  const ComboDashboardData({
    required this.dateTitle,
    required this.subtitle,
    required this.dateChips,
    required this.selectedDateIndex,
    required this.comboCount,
    required this.accuracy,
    required this.avgOdds,
    required this.safeRate,
    required this.safeRecord,
    required this.highRate,
    required this.highRecord,
  });

  final String dateTitle;
  final String subtitle;
  final List<String> dateChips;
  final int selectedDateIndex;
  final int comboCount;
  final String accuracy;
  final String avgOdds;
  final String safeRate;
  final String safeRecord;
  final String highRate;
  final String highRecord;
}

class ComboCardData {
  const ComboCardData({
    required this.id,
    required this.league,
    required this.comboCount,
    required this.statusLabel,
    required this.statusType,
    required this.comboType,
    required this.totalOdd,
    required this.reliability,
    required this.aiSummary,
    required this.aiSections,
    required this.matches,
  });

  final int id;
  final String league;
  final String comboCount;
  final String statusLabel;
  final String statusType;
  final String comboType;
  final double totalOdd;
  final String reliability;
  final String? aiSummary;
  final List<ComboAiSection> aiSections;
  final List<ComboMatchData> matches;
}

class ComboMatchData {
  const ComboMatchData({
    required this.homeTeamKo,
    required this.awayTeamKo,
    required this.homeLogo,
    required this.awayLogo,
    required this.pickTeamKo,
    required this.pickPosition,
    required this.pickResult,
    required this.odds,
    required this.winProb,
    required this.reason,
    required this.matchResultLabel,
    required this.matchResultType,
    required this.homePosition,
    required this.awayPosition,
    this.homeScore,
    this.awayScore,
  });

  final String homeTeamKo;
  final String awayTeamKo;
  final String homeLogo;
  final String awayLogo;
  final String pickTeamKo;
  final String pickPosition;
  final String pickResult;
  final double odds;
  final int winProb;
  final String reason;
  final String matchResultLabel;
  final String matchResultType;
  final String homePosition;
  final String awayPosition;
  final int? homeScore;
  final int? awayScore;
}

class ComboParser {
  ComboParser._();

  static List<String> buildDateChips() {
    final today = DateTime.now();
    final chips = <String>['오늘'];
    for (var i = 1; i <= 7; i++) {
      final d = today.subtract(Duration(days: i));
      chips.add('${d.month}.${d.day}');
    }
    return chips;
  }

  static List<String> buildDateValues() {
    final today = DateTime.now();
    final values = <String>[_formatDate(today)];
    for (var i = 1; i <= 7; i++) {
      values.add(_formatDate(today.subtract(Duration(days: i))));
    }
    return values;
  }

  static String dateValueAt(int selectedDateIdx) {
    final values = buildDateValues();
    if (selectedDateIdx < 0 || selectedDateIdx >= values.length) {
      return values.first;
    }
    return values[selectedDateIdx];
  }

  static List<ComboAiSection> parseAiAnalysis(String? aiAnalysis) {
    if (aiAnalysis == null || aiAnalysis.isEmpty) return [];

    final sections = aiAnalysis.split('\n\n');
    final result = <ComboAiSection>[];

    final bracketRegex = RegExp(r'^\[(.+?)\]\s*(.*)$', dotAll: true);

    for (final section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty) continue;

      final match = bracketRegex.firstMatch(trimmed);
      if (match != null) {
        final label = match.group(1)!;
        final content = match.group(2)?.trim() ?? '';

        final String type;
        if (label == '총평') {
          type = 'summary';
        } else if (label == '주의') {
          type = 'warning';
        } else {
          type = 'game';
        }

        result.add(
          ComboAiSection(label: label, content: content, type: type),
        );
      } else {
        result.add(
          ComboAiSection(label: '총평', content: trimmed, type: 'summary'),
        );
      }
    }
    return result;
  }

  static ComboDashboardData parseDashboard(
    Map<String, dynamic> data,
    int selectedDateIdx,
  ) {
    final picks = _extractPicks(data);
    final dateChips = buildDateChips();
    final dateValues = buildDateValues();
    final idx = selectedDateIdx.clamp(0, dateValues.length - 1);
    final selectedDate = dateValues[idx];

    final datePicks =
        picks.where((p) => p['pick_date']?.toString() == selectedDate).toList();

    final wins =
        datePicks.where((p) => p['result']?.toString() == 'win').length;
    final total = datePicks.length;
    final accRate = total > 0 ? (wins * 100 / total).round() : 0;

    final totalOdds = datePicks
        .map((p) => _readTotalOdd(p))
        .toList();
    final avgOdd = totalOdds.isNotEmpty
        ? totalOdds.reduce((a, b) => a + b) / totalOdds.length
        : 0.0;

    final safePicks = datePicks.where((p) => _readFoldCount(p) <= 2).toList();
    final highPicks = datePicks.where((p) => _readFoldCount(p) > 2).toList();
    final safeWins =
        safePicks.where((p) => p['result']?.toString() == 'win').length;
    final highWins =
        highPicks.where((p) => p['result']?.toString() == 'win').length;
    final safeRate = safePicks.isNotEmpty
        ? (safeWins * 100 / safePicks.length).round()
        : 0;
    final highRate = highPicks.isNotEmpty
        ? (highWins * 100 / highPicks.length).round()
        : 0;

    debugPrint(
      '[BASEBALL] combo dashboard accuracy: $wins wins / $total total = '
      '$accRate% (date: $selectedDate)',
    );
    debugPrint(
      '[BASEBALL] combo stats: safe=${safePicks.length}, '
      'high=${highPicks.length} (date: $selectedDate)',
    );

    final selectedDt = DateTime.parse(selectedDate);
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dateTitle =
        '${selectedDt.month}월 ${selectedDt.day}일 (${weekdays[selectedDt.weekday - 1]})';

    return ComboDashboardData(
      dateTitle: dateTitle,
      subtitle: '$total개 AI 조합 분석 완료',
      dateChips: dateChips,
      selectedDateIndex: idx,
      comboCount: total,
      accuracy: total > 0 ? '$accRate%' : '-',
      avgOdds: total > 0 ? avgOdd.toStringAsFixed(2) : '-',
      safeRate: safePicks.isNotEmpty ? '$safeRate%' : '-',
      safeRecord: '($safeWins/${safePicks.length})',
      highRate: highPicks.isNotEmpty ? '$highRate%' : '-',
      highRecord: '($highWins/${highPicks.length})',
    );
  }

  static List<ComboCardData> parseComboCards(
    Map<String, dynamic> data,
    String selectedDate,
  ) {
    final picks = _extractPicks(data);
    final datePicks =
        picks.where((p) => p['pick_date']?.toString() == selectedDate).toList();

    return datePicks.map((pick) {
      final innerPicks = pick['picks'] as List? ?? [];
      final result = pick['result']?.toString() ?? 'pending';

      final (statusLabel, statusType) = _mapComboResult(result);

      final foldCount = _readFoldCount(pick, innerPicks: innerPicks);
      final comboType = foldCount <= 2 ? 'safe' : 'high';

      final aiText = pick['ai_analysis']?.toString() ?? '';
      final aiPreview =
          aiText.length > 50 ? aiText.substring(0, 50) : aiText;
      debugPrint(
        '[BASEBALL] combo card: id=${pick['id']}, '
        'total_odds=${pick['total_odds']}, '
        'avg_confidence=${pick['avg_confidence']}, '
        'ai_analysis=$aiPreview',
      );
      debugPrint(
        '[BASEBALL] combo type: id=${pick['id']}, '
        'fold_count=$foldCount, type=$comboType',
      );

      final aiSummary = _readAiSummary(pick);

      return ComboCardData(
        id: (pick['id'] as num?)?.toInt() ?? 0,
        league: pick['league']?.toString() ?? 'KBO',
        comboCount: '$foldCount Combo',
        statusLabel: statusLabel,
        statusType: statusType,
        comboType: comboType,
        totalOdd: _readTotalOdd(pick),
        reliability: '${(pick['avg_confidence'] as num?)?.round() ?? 0}%',
        aiSummary: aiSummary,
        aiSections: parseAiAnalysis(aiSummary),
        matches: innerPicks.map((m) {
          final map = Map<String, dynamic>.from(m as Map);
          return _parseMatch(map);
        }).toList(),
      );
    }).toList();
  }

  static ComboMatchData _parseMatch(Map<String, dynamic> m) {
    final pickSide = m['pick']?.toString() ?? 'home';
    final pickTeamKo =
        m['pickTeamKo']?.toString() ?? m['pickTeam']?.toString() ?? '';

    final isCorrect = m['isCorrect'] as bool?;
    final matchStatus = m['matchStatus']?.toString() ?? '';
    final homeScore = (m['homeScore'] as num?)?.toInt();
    final awayScore = (m['awayScore'] as num?)?.toInt();

    debugPrint(
      '[BASEBALL] combo match: pickTeam=${m['pickTeamKo']}, '
      'isCorrect=$isCorrect, matchStatus=$matchStatus, '
      'score=$homeScore-$awayScore',
    );

    final String matchResultLabel;
    final String matchResultType;

    if (matchStatus == 'FT' || matchStatus == 'AOT') {
      if (isCorrect == true) {
        matchResultLabel = '적중';
        matchResultType = 'hit';
      } else {
        matchResultLabel = '실패';
        matchResultType = 'miss';
      }
    } else {
      matchResultLabel = '대기';
      matchResultType = 'inProgress';
    }

    return ComboMatchData(
      homeTeamKo: m['homeTeamKo']?.toString() ?? m['homeTeam']?.toString() ?? '',
      awayTeamKo: m['awayTeamKo']?.toString() ?? m['awayTeam']?.toString() ?? '',
      homeLogo: m['homeLogo']?.toString() ?? '',
      awayLogo: m['awayLogo']?.toString() ?? '',
      pickTeamKo: pickTeamKo,
      pickPosition: pickSide == 'home' ? '홈' : '원정',
      pickResult: '승',
      odds: (m['odds'] as num?)?.toDouble() ?? 0,
      winProb: _readWinProb(m),
      reason: m['reason']?.toString() ?? '',
      matchResultLabel: matchResultLabel,
      matchResultType: matchResultType,
      homePosition: 'H',
      awayPosition: 'A',
      homeScore: homeScore,
      awayScore: awayScore,
    );
  }

  static (String, String) _mapComboResult(String result) {
    return switch (result) {
      'win' => ('적중', 'hit'),
      'partial' => ('부분', 'partial'),
      'lose' => ('미적중', 'miss'),
      _ => ('진행중', 'inProgress'),
    };
  }

  static List<Map<String, dynamic>> _extractPicks(Map<String, dynamic> data) {
    final picks = data['picks'];
    if (picks is List) {
      return picks
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const [];
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static int _readFoldCount(
    Map<String, dynamic> pick, {
    List? innerPicks,
  }) {
    final picks = innerPicks ?? pick['picks'] as List?;
    return (pick['fold_count'] as num?)?.toInt() ?? picks?.length ?? 2;
  }

  static double _readTotalOdd(Map<String, dynamic> pick) {
    final value = pick['total_odds'] ?? pick['totalOdd'];
    if (value is num) return value.toDouble();
    return 0;
  }

  static String? _readAiSummary(Map<String, dynamic> pick) {
    final value = pick['ai_analysis'] ?? pick['ai_comment'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return null;
  }

  static int _readWinProb(Map<dynamic, dynamic> pick) {
    for (final key in const ['winProb', 'win_prob']) {
      final value = pick[key];
      if (value is num) return value.round();
    }
    return 50;
  }
}

class ComboUiMapper {
  ComboUiMapper._();

  static ComboStatus statusFromType(String statusType) {
    return switch (statusType) {
      'hit' => ComboStatus.hit,
      'partial' => ComboStatus.partial,
      'miss' => ComboStatus.miss,
      _ => ComboStatus.inProgress,
    };
  }

  static ComboType typeFromComboType(String comboType) {
    return comboType == 'safe' ? ComboType.safe : ComboType.highOdds;
  }

  static ComboMatchRowData toMatchRow(ComboMatchData match) {
    final matchResult = switch (match.matchResultType) {
      'hit' => ComboStatus.hit,
      'miss' => ComboStatus.miss,
      'partial' => ComboStatus.partial,
      _ => null,
    };

    return ComboMatchRowData(
      homeTeam: match.homeTeamKo,
      awayTeam: match.awayTeamKo,
      homeLogoUrl: match.homeLogo.isEmpty ? null : match.homeLogo,
      awayLogoUrl: match.awayLogo.isEmpty ? null : match.awayLogo,
      predictTeam: match.pickTeamKo,
      predictDirection: match.pickPosition,
      odds: match.odds.toStringAsFixed(2),
      winRate: '${match.winProb}%',
      winRateRatio: match.winProb / 100,
      comment: match.reason,
      matchResult: matchResult,
      homeScore: match.homeScore,
      awayScore: match.awayScore,
    );
  }

  static int comboCountFromLabel(String label) {
    final match = RegExp(r'^(\d+)').firstMatch(label);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }
}
