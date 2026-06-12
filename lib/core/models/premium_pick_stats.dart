import 'package:trendsoccer/shared/widgets/cards/premium_pick_card.dart';

/// Parsed display model for `/api/premium-picks/stats`.
class PremiumPickStatsView {
  const PremiumPickStatsView({
    required this.winRate,
    required this.countdown,
    required this.streak,
    required this.recentWins,
    this.pickCount = '-',
  });

  final String winRate;
  final String countdown;
  final String streak;
  final List<RecentWinData> recentWins;
  final String pickCount;

  static const placeholder = PremiumPickStatsView(
    winRate: '-',
    countdown: '-',
    streak: '-',
    pickCount: '-',
    recentWins: [
      RecentWinData(
        homeTeam: '—',
        awayTeam: '—',
        pickDirection: '—',
      ),
    ],
  );

  factory PremiumPickStatsView.fromMap(Map<String, dynamic> map) {
    final statsRaw = map['stats'];
    final stats =
        statsRaw is Map ? Map<String, dynamic>.from(statsRaw) : null;

    final winRate = stats?['winRate'] ??
        map['winRate'] ??
        map['win_rate'] ??
        map['accuracy'] ??
        map['hitRate'];
    final streak = stats?['streak'] ??
        map['streak'] ??
        map['winStreak'] ??
        map['win_streak'] ??
        map['currentStreak'];
    final streakType = stats?['streakType'] ??
        stats?['streak_type'] ??
        map['streakType'] ??
        map['streak_type'];
    final total = stats?['total'] ??
        map['total'] ??
        map['pickCount'] ??
        map['pick_count'] ??
        map['todayPicks'] ??
        map['today_picks'] ??
        map['picksToday'];

    return PremiumPickStatsView(
      winRate: _formatWinRate(winRate),
      countdown: formatCountdown(nextKstUpdateRemaining()),
      streak: _formatStreak(streak, streakType),
      pickCount: _formatPickCount(total),
      recentWins: _parseRecentWins(
        map['recentResults'] ??
            map['recent_results'] ??
            map['recentWins'] ??
            map['recent_wins'] ??
            map['wins'],
      ),
    );
  }
}

List<RecentWinData> _parseRecentWins(Object? value) {
  if (value is! List) return PremiumPickStatsView.placeholder.recentWins;

  final wins = value
      .whereType<Map>()
      .map((item) {
        final map = Map<String, dynamic>.from(item);
        final matchTeams = _parseMatchTeams(map['match']);
        return RecentWinData(
          homeTeam: _readString(map, const [
                'homeTeam',
                'home_team',
                'home',
                'homeTeamName',
              ]) ??
              matchTeams?.home ??
              '—',
          awayTeam: _readString(map, const [
                'awayTeam',
                'away_team',
                'away',
                'awayTeamName',
              ]) ??
              matchTeams?.away ??
              '—',
          pickDirection: _pickDirectionCode(
            map['predicted'] ??
                map['pickDirection'] ??
                map['pick_direction'] ??
                map['pick'] ??
                map['direction'],
          ) ??
              '—',
        );
      })
      .where((w) => w.homeTeam != '—' || w.awayTeam != '—')
      .toList();

  return wins.isEmpty ? PremiumPickStatsView.placeholder.recentWins : wins;
}

({String home, String away})? _parseMatchTeams(Object? match) {
  if (match is! String || match.isEmpty) return null;
  final parts = match.split(RegExp(r'\s+vs\s+', caseSensitive: false));
  if (parts.length < 2) return null;
  return (
    home: parts.first.trim(),
    away: parts.sublist(1).join(' vs ').trim(),
  );
}

String? _readString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

String _formatWinRate(Object? value) {
  if (value == null) return '-';
  if (value is num) {
    if (value <= 1) return '${(value * 100).round()}%';
    return '${value.round()}%';
  }
  final raw = value.toString();
  return raw.contains('%') ? raw : '$raw%';
}

String _formatStreak(Object? value, [Object? streakType]) {
  if (value == null) return '-';

  final type = streakType?.toString().toLowerCase() ?? '';
  if (type.contains('los')) return '-';

  final count = value is num
      ? value.round()
      : int.tryParse(value.toString()) ?? 0;
  if (count <= 0) return '-';
  if (!type.contains('win')) return '-';

  return '$count Win';
}

/// Remaining time until the next premium-pick update (KST 06:00 / 18:00).
Duration nextKstUpdateRemaining() {
  final now = DateTime.now().toUtc();
  final todayDate = DateTime.utc(now.year, now.month, now.day);
  final update0900Utc = todayDate.add(const Duration(hours: 9));
  final update2100Utc = todayDate.add(const Duration(hours: 21));

  final DateTime nextUpdateUtc;
  if (now.isBefore(update0900Utc)) {
    nextUpdateUtc = update0900Utc;
  } else if (now.isBefore(update2100Utc)) {
    nextUpdateUtc = update2100Utc;
  } else {
    nextUpdateUtc = update0900Utc.add(const Duration(days: 1));
  }

  return nextUpdateUtc.difference(now);
}

/// Formats a countdown duration as HH:MM.
String formatCountdown(Duration duration) {
  if (duration.isNegative) return '00:00';
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  return '$hours:$minutes';
}

String _formatPickCount(Object? value) {
  if (value == null) return '-';
  if (value is num) return '${value.round()}';
  return value.toString();
}

String? _pickDirectionCode(Object? value) {
  if (value == null) return null;
  final raw = value.toString().toLowerCase();
  if (raw.contains('home') || raw == 'h' || raw.contains('홈')) return 'home';
  if (raw.contains('draw') || raw == 'd' || raw.contains('무')) return 'draw';
  if (raw.contains('away') || raw == 'a' || raw.contains('원정')) return 'away';
  return null;
}
