import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';

enum AppLanguage { ko, en }

const _languageKey = 'language_code';

final languageProvider =
    NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => _readLanguage(ref.read(sharedPreferencesProvider));

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await ref.read(sharedPreferencesProvider).setString(_languageKey, language.name);
  }
}

AppLanguage _readLanguage(SharedPreferences prefs) {
  final code = prefs.getString(_languageKey);
  return switch (code) {
    'en' => AppLanguage.en,
    'ko' => AppLanguage.ko,
    _ => AppLanguage.ko,
  };
}
