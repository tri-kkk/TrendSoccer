import 'package:shared_preferences/shared_preferences.dart';

const apiLanguageCodeKey = 'language_code';

/// Current API language code (`ko` or `en`) from app locale prefs.
String getApiLanguage(SharedPreferences prefs) {
  final lang = prefs.getString(apiLanguageCodeKey) ?? 'ko';
  return lang == 'en' ? 'en' : 'ko';
}
