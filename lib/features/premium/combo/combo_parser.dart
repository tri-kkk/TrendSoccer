import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/locale_data_helper.dart';

import 'package:trendsoccer/core/utils/analysis_text_formatter.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
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
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamKo,
    required this.awayTeamKo,
    required this.homeLogo,
    required this.awayLogo,
    required this.pickTeam,
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

  final String homeTeam;
  final String awayTeam;
  final String homeTeamKo;
  final String awayTeamKo;
  final String homeLogo;
  final String awayLogo;
  final String pickTeam;
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

  static List<String> buildDateChips(AppLocalizations l10n) {
    final today = DateTime.now();
    final chips = <String>[l10n.comboDashboardToday];
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

  static List<ComboAiSection> parseAiAnalysis(
    String? aiAnalysis,
    AppLocalizations l10n,
  ) {
    if (aiAnalysis == null || aiAnalysis.isEmpty) return [];

    final sections = formatComboAnalysisText(aiAnalysis).split('\n\n');
    final result = <ComboAiSection>[];

    final bracketRegex = RegExp(r'^\[(.+?)\]\s*(.*)$', dotAll: true);

    for (final section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty) continue;

      final match = bracketRegex.firstMatch(trimmed);
      if (match != null) {
        final label = match.group(1)!;
        final content = match.group(2)?.trim() ?? '';

        final normalizedLabel = label.toLowerCase();
        final String type;
        if (label == '총평' || normalizedLabel == 'summary') {
          type = 'summary';
        } else if (label == '주의' ||
            normalizedLabel == 'warning' ||
            normalizedLabel == 'caution') {
          type = 'warning';
        } else {
          type = 'game';
        }

        result.add(
          ComboAiSection(
            label: _localizedAiLabel(label, l10n),
            content: content,
            type: type,
          ),
        );
      } else {
        result.add(
          ComboAiSection(
            label: l10n.comboAiSummary,
            content: trimmed,
            type: 'summary',
          ),
        );
      }
    }
    return result;
  }

  static String _localizedAiLabel(String apiLabel, AppLocalizations l10n) {
    final normalized = apiLabel.toLowerCase();
    return switch (apiLabel) {
      '총평' => l10n.comboAiSummary,
      '주의' => l10n.comboAiWarning,
      _ => switch (normalized) {
          'summary' => l10n.comboAiSummary,
          'warning' || 'caution' => l10n.comboAiWarning,
          _ => apiLabel,
        },
    };
  }

  static ComboDashboardData parseDashboard(
    Map<String, dynamic> data,
    int selectedDateIdx,
    AppLocalizations l10n,
  ) {
    final picks = _extractPicks(data);
    final dateChips = buildDateChips(l10n);
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

        
    final selectedDt = DateTime.parse(selectedDate);
    final dateTitle = _dashboardDateTitle(l10n, selectedDt);

    return ComboDashboardData(
      dateTitle: dateTitle,
      subtitle: l10n.comboPicksCompleted(total),
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
    AppLocalizations l10n,
  ) {
    final picks = _extractPicks(data);
    final datePicks =
        picks.where((p) => p['pick_date']?.toString() == selectedDate).toList();

    return datePicks.map((pick) {
      final innerPicks = pick['picks'] as List? ?? [];
      final result = pick['result']?.toString() ?? 'pending';

      final (statusLabel, statusType) = _mapComboResult(result, l10n);

      final foldCount = _readFoldCount(pick, innerPicks: innerPicks);
      final comboType = foldCount <= 2 ? 'safe' : 'high';

      final aiSummary = _readAiSummary(pick, l10n);

      return ComboCardData(
        id: (pick['id'] as num?)?.toInt() ?? 0,
        league: pick['league']?.toString() ?? 'KBO',
        comboCount: l10n.comboFoldCount(foldCount),
        statusLabel: statusLabel,
        statusType: statusType,
        comboType: comboType,
        totalOdd: _readTotalOdd(pick),
        reliability: '${(pick['avg_confidence'] as num?)?.round() ?? 0}%',
        aiSummary: aiSummary,
        aiSections: parseAiAnalysis(aiSummary, l10n),
        matches: innerPicks.map((m) {
          final map = Map<String, dynamic>.from(m as Map);
          return _parseMatch(map, l10n);
        }).toList(),
      );
    }).toList();
  }

  static ComboMatchData _parseMatch(
    Map<String, dynamic> m,
    AppLocalizations l10n,
  ) {
    final pickSide = m['pick']?.toString() ?? 'home';
    final pickTeamKo =
        m['pickTeamKo']?.toString() ?? m['pickTeam']?.toString() ?? '';

    final isCorrect = m['isCorrect'] as bool?;
    final matchStatus = m['matchStatus']?.toString() ?? '';
    final homeScore = (m['homeScore'] as num?)?.toInt();
    final awayScore = (m['awayScore'] as num?)?.toInt();

    
    final String matchResultLabel;
    final String matchResultType;

    if (matchStatus == 'FT' || matchStatus == 'AOT') {
      if (isCorrect == true) {
        matchResultLabel = l10n.comboMatchHit;
        matchResultType = 'hit';
      } else {
        matchResultLabel = l10n.comboMatchFail;
        matchResultType = 'miss';
      }
    } else {
      matchResultLabel = l10n.comboMatchPending;
      matchResultType = 'inProgress';
    }

    final homeTeam = m['homeTeam']?.toString() ?? '';
    final awayTeam = m['awayTeam']?.toString() ?? '';
    final homeTeamKo =
        m['homeTeamKo']?.toString() ?? homeTeam;
    final awayTeamKo =
        m['awayTeamKo']?.toString() ?? awayTeam;
    final pickTeam = m['pickTeam']?.toString() ?? pickTeamKo;

    return ComboMatchData(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamKo: homeTeamKo,
      awayTeamKo: awayTeamKo,
      homeLogo: m['homeLogo']?.toString() ?? '',
      awayLogo: m['awayLogo']?.toString() ?? '',
      pickTeam: pickTeam,
      pickTeamKo: pickTeamKo,
      pickPosition:
          pickSide == 'home' ? l10n.labelHome : l10n.labelAway,
      pickResult: l10n.comboWin,
      odds: (m['odds'] as num?)?.toDouble() ?? 0,
      winProb: _readWinProb(m),
      reason: _readLocalizedText(
        m,
        l10n,
        koKeys: const ['reason', 'reason_ko'],
        enKeys: const ['reason_en', 'reasonEn'],
      ),
      matchResultLabel: matchResultLabel,
      matchResultType: matchResultType,
      homePosition: 'H',
      awayPosition: 'A',
      homeScore: homeScore,
      awayScore: awayScore,
    );
  }

  static (String, String) _mapComboResult(
    String result,
    AppLocalizations l10n,
  ) {
    return switch (result) {
      'win' => (l10n.comboStatusHit, 'hit'),
      'partial' => (l10n.comboStatusPartial, 'partial'),
      'lose' => (l10n.comboStatusMiss, 'miss'),
      _ => (l10n.comboStatusInProgress, 'inProgress'),
    };
  }

  static String _dashboardDateTitle(AppLocalizations l10n, DateTime dt) {
    final weekday = _weekdayLabel(l10n, dt.weekday);
    if (l10n.localeName.startsWith('en')) {
      return '${dt.month}/${dt.day} ($weekday)';
    }
    return '${dt.month}월 ${dt.day}일 ($weekday)';
  }

  static String _weekdayLabel(AppLocalizations l10n, int weekday) {
    return switch (weekday) {
      DateTime.monday => l10n.weekdayMon,
      DateTime.tuesday => l10n.weekdayTue,
      DateTime.wednesday => l10n.weekdayWed,
      DateTime.thursday => l10n.weekdayThu,
      DateTime.friday => l10n.weekdayFri,
      DateTime.saturday => l10n.weekdaySat,
      DateTime.sunday => l10n.weekdaySun,
      _ => l10n.weekdayMon,
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

  static String? _readAiSummary(
    Map<String, dynamic> pick,
    AppLocalizations l10n,
  ) {
    final isEn = l10n.localeName.startsWith('en');
    if (isEn) {
      for (final key in const [
        'ai_analysis_en',
        'aiAnalysisEn',
        'ai_comment_en',
        'aiCommentEn',
      ]) {
        final value = pick[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    final value = pick['ai_analysis'] ?? pick['ai_comment'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static String _readLocalizedText(
    Map<String, dynamic> map,
    AppLocalizations l10n, {
    required List<String> koKeys,
    required List<String> enKeys,
  }) {
    final isEn = l10n.localeName.startsWith('en');
    if (isEn) {
      for (final key in enKeys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    for (final key in koKeys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
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

  static ComboMatchRowData toMatchRow(
    BuildContext context,
    ComboMatchData match,
  ) {
    final matchResult = switch (match.matchResultType) {
      'hit' => ComboStatus.hit,
      'miss' => ComboStatus.miss,
      'partial' => ComboStatus.partial,
      _ => null,
    };

    return ComboMatchRowData(
      homeTeam: localizedTeamName(
        context,
        match.homeTeam,
        match.homeTeamKo,
      ),
      awayTeam: localizedTeamName(
        context,
        match.awayTeam,
        match.awayTeamKo,
      ),
      homeLogoUrl: match.homeLogo.isEmpty ? null : match.homeLogo,
      awayLogoUrl: match.awayLogo.isEmpty ? null : match.awayLogo,
      predictTeam: localizedTeamName(
        context,
        match.pickTeam,
        match.pickTeamKo,
      ),
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
