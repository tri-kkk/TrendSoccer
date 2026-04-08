import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ──────────────────────────────────────────────
// Language
// ──────────────────────────────────────────────

/// Supported display languages.
enum Language {
  /// 한국어
  korean,

  /// English
  english,
}

/// Provider for the current display language.
///
/// Defaults to [Language.korean].
/// ```dart
/// ref.read(languageProvider.notifier).set(Language.english);
/// ```
final languageProvider =
    NotifierProvider<LanguageNotifier, Language>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<Language> {
  @override
  Language build() => Language.korean;

  void set(Language language) => state = language;
}

// ──────────────────────────────────────────────
// Theme
// ──────────────────────────────────────────────

/// Provider for the current theme mode.
///
/// Defaults to [ThemeMode.system].
/// ```dart
/// ref.read(themeModeProvider.notifier).set(ThemeMode.dark);
/// ```
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

// ──────────────────────────────────────────────
// Notifications
// ──────────────────────────────────────────────

/// Immutable snapshot of the user's notification preferences.
class NotificationSettings {
  const NotificationSettings({
    required this.general,
    required this.matchEvents,
    required this.breakingNews,
  });

  /// Master toggle for all notifications.
  final bool general;

  /// Receive alerts for match events (goals, cards, etc.).
  final bool matchEvents;

  /// Receive breaking news notifications.
  final bool breakingNews;

  /// Returns a copy with the given fields replaced.
  NotificationSettings copyWith({
    bool? general,
    bool? matchEvents,
    bool? breakingNews,
  }) {
    return NotificationSettings(
      general: general ?? this.general,
      matchEvents: matchEvents ?? this.matchEvents,
      breakingNews: breakingNews ?? this.breakingNews,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          general == other.general &&
          matchEvents == other.matchEvents &&
          breakingNews == other.breakingNews;

  @override
  int get hashCode => Object.hash(general, matchEvents, breakingNews);

  @override
  String toString() =>
      'NotificationSettings(general: $general, matchEvents: $matchEvents, breakingNews: $breakingNews)';
}

/// Provider for the user's notification preferences.
///
/// All toggles default to `true`.
/// ```dart
/// ref.read(notificationProvider.notifier).toggle(matchEvents: false);
/// ```
final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationSettings>(
  NotificationNotifier.new,
);

class NotificationNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() => const NotificationSettings(
        general: true,
        matchEvents: true,
        breakingNews: true,
      );

  void toggle({
    bool? general,
    bool? matchEvents,
    bool? breakingNews,
  }) {
    state = state.copyWith(
      general: general,
      matchEvents: matchEvents,
      breakingNews: breakingNews,
    );
  }
}
