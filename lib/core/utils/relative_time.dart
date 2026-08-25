import 'package:intl/intl.dart';

// ARB migration target: English literals below.

/// Formats [timestamp] relative to [now] (defaults to clock time) in local time.
String formatRelativeTime(DateTime timestamp, {DateTime? now}) {
  final reference = (now ?? DateTime.now()).toLocal();
  final localTimestamp = timestamp.toLocal();
  final difference = reference.difference(localTimestamp);

  if (difference.inSeconds < 60) {
    return 'Just now';
  }

  final minutes = difference.inMinutes;
  if (minutes < 60) {
    return '${minutes}m ago';
  }

  final hours = difference.inHours;
  if (hours < 24) {
    return '${hours}h ago';
  }

  final days = difference.inDays;
  if (days < 7) {
    return '${days}d ago';
  }

  return DateFormat('MMM d', 'en').format(localTimestamp);
}
