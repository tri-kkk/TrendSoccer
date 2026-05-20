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
    return PremiumPickStatsView(
      winRate: _formatWinRate(
        map['winRate'] ?? map['win_rate'] ?? map['accuracy'] ?? map['hitRate'],
      ),
      countdown: _formatCountdown(
        map['countdown'] ??
            map['nextUpdate'] ??
            map['next_update'] ??
            map['updateTime'] ??
            map['update_time'],
      ),
      streak: _formatStreak(
        map['streak'] ?? map['winStreak'] ?? map['win_streak'] ?? map['currentStreak'],
      ),
      pickCount: _formatPickCount(
        map['pickCount'] ??
            map['pick_count'] ??
            map['todayPicks'] ??
            map['today_picks'] ??
            map['picksToday'],
      ),
      recentWins: _parseRecentWins(
        map['recentWins'] ??
            map['recent_wins'] ??
            map['recentResults'] ??
            map['recent_results'] ??
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
        return RecentWinData(
          homeTeam: _readString(map, const [
                'homeTeam',
                'home_team',
                'home',
                'homeTeamName',
              ]) ??
              '—',
          awayTeam: _readString(map, const [
                'awayTeam',
                'away_team',
                'away',
                'awayTeamName',
              ]) ??
              '—',
          pickDirection: _formatPickDirectionLabel(
            map['pickDirection'] ??
                map['pick_direction'] ??
                map['pick'] ??
                map['direction'],
          ),
        );
      })
      .where((w) => w.homeTeam != '—' || w.awayTeam != '—')
      .toList();

  return wins.isEmpty ? PremiumPickStatsView.placeholder.recentWins : wins;
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

String _formatStreak(Object? value) {
  if (value == null) return '-';
  if (value is num) return '${value.round()} WIN';
  final raw = value.toString();
  if (raw.toUpperCase().contains('WIN')) return raw;
  return '$raw WIN';
}

String _formatPickCount(Object? value) {
  if (value == null) return '-';
  if (value is num) return '${value.round()}';
  return value.toString();
}

String _formatCountdown(Object? value) {
  if (value == null) return '-';
  if (value is String && value.isNotEmpty) return value;

  if (value is num) {
    final minutes = value.round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      final diff = parsed.toUtc().difference(DateTime.now().toUtc());
      if (diff.isNegative) return '곧 업데이트';
      return _durationLabel(diff);
    }
  }
  return '-';
}

String _durationLabel(Duration duration) {
  if (duration.inHours > 0) {
    return '${duration.inHours}h ${duration.inMinutes % 60}m';
  }
  final minutes = duration.inMinutes;
  return minutes > 0 ? '${minutes}m' : '1m';
}

String _formatPickDirectionLabel(Object? value) {
  if (value == null) return '—';
  final raw = value.toString().toLowerCase();
  if (raw.contains('home') || raw == 'h' || raw.contains('홈')) return '홈';
  if (raw.contains('draw') || raw == 'd' || raw.contains('무')) return '무';
  if (raw.contains('away') || raw == 'a' || raw.contains('원정')) return '원정';
  return value.toString();
}
