import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/baseball_combo_parsed.dart';
import 'package:trendsoccer/core/utils/locale_data_helper.dart';
import 'package:trendsoccer/design_system/widgets/ts_ai_report_block.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_card.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_footer.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_leg_row.dart';
import 'package:trendsoccer/design_system/widgets/ts_combo_match_row.dart';
import 'package:trendsoccer/features_v2/reports/reports_combo_logic.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

bool reportsComboDetailIdMatches(int? id, String comboId) {
  if (id == null) return false;
  if (id.toString() == comboId) return true;
  final parsed = int.tryParse(comboId);
  return parsed != null && parsed == id;
}

BaseballComboParsed? reportsComboDetailFindInCache(
  Map<String, dynamic> raw,
  String comboId,
) {
  for (final combo in parseBaseballComboPicks(raw)) {
    if (reportsComboDetailIdMatches(combo.id, comboId)) {
      return combo;
    }
  }
  return null;
}

/// Locale-aware AI summary — mirrors v1 `_readLocalizedText` / `_readAiSummary`.
String? reportsComboDetailAiSummary(
  BuildContext context,
  BaseballComboParsed combo,
) {
  if (isKoreanLocale(context)) {
    for (final value in [combo.aiAnalysis, combo.aiComment]) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    for (final value in [combo.aiAnalysisEn, combo.aiCommentEn]) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  for (final value in [combo.aiAnalysisEn, combo.aiCommentEn]) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  for (final value in [combo.aiAnalysis, combo.aiComment]) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

/// Bracket-marker line opener — label and body on the same line.
final _reportsComboAiLineMarkerRegex = RegExp(r'^\[(.+?)\]\s*(.*)$');

enum _ReportsComboAiSectionTarget { none, summary, leg, caution }

class ReportsComboAiParsed {
  const ReportsComboAiParsed({
    required this.summary,
    required this.legs,
    required this.cautionLabel,
    required this.caution,
  });

  final String summary;
  final List<TsAiReportLeg> legs;
  final String cautionLabel;
  final String caution;
}

String _reportsComboAiAppendLine(String existing, String line) {
  if (line.isEmpty) return existing;
  if (existing.isEmpty) return line;
  return '$existing\n$line';
}

bool _reportsComboAiIsSummaryLabel(String label) {
  if (label == '총평' || label == '종합' || label == '종합 평가') {
    return true;
  }
  return label.toLowerCase() == 'summary';
}

bool _reportsComboAiIsCautionLabel(String label) {
  if (label == '주의') return true;
  final normalized = label.toLowerCase();
  return normalized == 'caution' || normalized == 'warning';
}

ReportsComboAiParsed reportsComboDetailParseAiText(String text) {
  var summary = '';
  final legs = <TsAiReportLeg>[];
  var cautionLabel = '';
  var caution = '';
  var target = _ReportsComboAiSectionTarget.none;

  void appendUnmarked(String line) {
    switch (target) {
      case _ReportsComboAiSectionTarget.summary:
        summary = _reportsComboAiAppendLine(summary, line);
      case _ReportsComboAiSectionTarget.leg:
        if (legs.isEmpty) {
          summary = _reportsComboAiAppendLine(summary, line);
        } else {
          final last = legs.removeLast();
          legs.add(
            TsAiReportLeg(
              label: last.label,
              body: _reportsComboAiAppendLine(last.body, line),
            ),
          );
        }
      case _ReportsComboAiSectionTarget.caution:
        caution = _reportsComboAiAppendLine(caution, line);
      case _ReportsComboAiSectionTarget.none:
        summary = _reportsComboAiAppendLine(summary, line);
    }
  }

  for (final line in text.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;

    final match = _reportsComboAiLineMarkerRegex.firstMatch(trimmed);
    if (match != null) {
      final label = match.group(1)!;
      final body = match.group(2) ?? '';

      if (_reportsComboAiIsSummaryLabel(label)) {
        summary = _reportsComboAiAppendLine(summary, body);
        target = _ReportsComboAiSectionTarget.summary;
      } else if (_reportsComboAiIsCautionLabel(label)) {
        cautionLabel = label;
        caution = body;
        target = _ReportsComboAiSectionTarget.caution;
      } else {
        legs.add(TsAiReportLeg(label: label, body: body));
        target = _ReportsComboAiSectionTarget.leg;
      }
    } else {
      appendUnmarked(trimmed);
    }
  }

  return ReportsComboAiParsed(
    summary: summary,
    legs: legs,
    cautionLabel: cautionLabel,
    caution: caution,
  );
}

TsAiReportData? reportsComboDetailAiReportData(
  BuildContext context,
  AppLocalizations l10n,
  BaseballComboParsed combo,
) {
  final raw = reportsComboDetailAiSummary(context, combo);
  if (raw == null) return null;

  final parsed = reportsComboDetailParseAiText(raw);
  return TsAiReportData(
    titleLabel: l10n.baseballAiSummary,
    summaryLabel: parsed.summary,
    legs: parsed.legs,
    caution: parsed.caution,
    cautionLabel: parsed.cautionLabel,
    disclaimerLabel: l10n.comboAiDisclaimer,
  );
}

TsComboPick reportsComboDetailLegPick(String? pickSide) {
  final normalized = pickSide?.trim().toLowerCase();
  if (normalized == 'away' || normalized == 'a') {
    return TsComboPick.away;
  }
  return TsComboPick.home;
}

String reportsComboDetailLegScoreLabel(BaseballComboLegParsed leg) {
  final home = leg.homeScore;
  final away = leg.awayScore;
  if (home == null && away == null) return reportsComboNullDisplay;
  return '${home ?? reportsComboNullDisplay} : ${away ?? reportsComboNullDisplay}';
}

double reportsComboDetailLegProbability(double? winProb) {
  if (winProb == null) return 0.5;
  if (winProb > 1) return (winProb / 100).clamp(0.0, 1.0);
  return winProb.clamp(0.0, 1.0);
}

String reportsComboDetailLegProbabilityLabel(double? winProb) {
  if (winProb == null) return reportsComboNullDisplay;
  final pct =
      winProb > 1 ? winProb.round() : (winProb * 100).round();
  return '$pct%';
}

String? reportsComboDetailLegReason(
  BuildContext context,
  BaseballComboLegParsed leg,
) {
  if (isKoreanLocale(context)) {
    final ko = leg.reason;
    if (ko != null && ko.trim().isNotEmpty) return ko.trim();
    final en = leg.reasonEn;
    if (en != null && en.trim().isNotEmpty) return en.trim();
    return null;
  }

  final en = leg.reasonEn;
  if (en != null && en.trim().isNotEmpty) return en.trim();
  final ko = leg.reason;
  if (ko != null && ko.trim().isNotEmpty) return ko.trim();
  return null;
}

String reportsComboDetailLegPickText(
  BuildContext context,
  AppLocalizations l10n,
  BaseballComboLegParsed leg,
) {
  final team = localizedTeamName(context, leg.pickTeam, leg.pickTeamKo);
  if (team.isEmpty) return reportsComboNullDisplay;
  return l10n.comboLegPickWin(team);
}

TsComboOutcome reportsComboDetailOutcome(List<BaseballComboLegParsed> legs) {
  if (legs.isEmpty) return TsComboOutcome.pending;

  final results =
      legs.map((leg) => reportsComboLegResult(leg.isCorrect)).toList();
  final hasHit = results.any((r) => r == TsComboResult.hit);
  final hasMiss = results.any((r) => r == TsComboResult.miss);
  final hasPending = results.any((r) => r == TsComboResult.inProgress);

  if (hasHit && hasMiss) return TsComboOutcome.partial;
  if (results.every((r) => r == TsComboResult.hit)) {
    return TsComboOutcome.hit;
  }
  if (results.every((r) => r == TsComboResult.miss)) {
    return TsComboOutcome.miss;
  }
  if (hasMiss && !hasHit && hasPending) return TsComboOutcome.miss;
  return TsComboOutcome.pending;
}

List<TsComboLeg> reportsComboDetailLegs(
  BuildContext context,
  AppLocalizations l10n,
  BaseballComboParsed combo,
) {
  return [
    for (final leg in combo.legs)
      TsComboLeg(
        pick: reportsComboDetailLegPick(leg.pickSide),
        homeTeamLabel: leg.homeTeam == null
            ? reportsComboNullDisplay
            : localizedTeamName(context, leg.homeTeam, leg.homeTeamKo),
        awayTeamLabel: leg.awayTeam == null
            ? reportsComboNullDisplay
            : localizedTeamName(context, leg.awayTeam, leg.awayTeamKo),
        timeLabel: leg.matchStatus ?? reportsComboNullDisplay,
        scoreLabel: reportsComboDetailLegScoreLabel(leg),
        pickTextLabel: reportsComboDetailLegPickText(context, l10n, leg),
        probabilityLabel: reportsComboDetailLegProbabilityLabel(leg.winProb),
        indexLabel: leg.odds == null
            ? reportsComboNullDisplay
            : leg.odds!.toStringAsFixed(2),
        probability: reportsComboDetailLegProbability(leg.winProb),
        baseline: 0.5,
        reasonLabel: reportsComboDetailLegReason(context, leg),
        homeEmblemUrl: leg.homeLogo,
        awayEmblemUrl: leg.awayLogo,
      ),
  ];
}
