import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys for global per-event alarm defaults (Fixture bell).
abstract final class AlarmPreferenceKeys {
  static const soccerKickoff = 'soccer_alarm_kickoff';
  static const soccerGoal = 'soccer_alarm_goal';
  static const soccerHalftime = 'soccer_alarm_halftime';
  static const soccerSecondHalf = 'soccer_alarm_secondHalf';
  static const soccerFulltime = 'soccer_alarm_fulltime';
  static const soccerYellowCard = 'soccer_alarm_yellowCard';
  static const soccerRedCard = 'soccer_alarm_redCard';
  static const soccerSubstitution = 'soccer_alarm_substitution';

  static const baseballFirstPitch = 'baseball_alarm_firstPitch';
  static const baseballScore = 'baseball_alarm_score';
  static const baseballHomerun = 'baseball_alarm_homerun';
  static const baseballInningChange = 'baseball_alarm_inningChange';
  static const baseballGameEnd = 'baseball_alarm_gameEnd';

  static Map<String, bool> globalEvents(SharedPreferences prefs, String sport) {
    if (sport == 'soccer') {
      return {
        'kickoff': prefs.getBool(soccerKickoff) ?? true,
        'goal': prefs.getBool(soccerGoal) ?? true,
        'halftime': prefs.getBool(soccerHalftime) ?? true,
        'secondHalf': prefs.getBool(soccerSecondHalf) ?? true,
        'fulltime': prefs.getBool(soccerFulltime) ?? true,
        'yellowCard': prefs.getBool(soccerYellowCard) ?? true,
        'redCard': prefs.getBool(soccerRedCard) ?? true,
        'substitution': prefs.getBool(soccerSubstitution) ?? true,
      };
    }

    return {
      'firstPitch': prefs.getBool(baseballFirstPitch) ?? true,
      'score': prefs.getBool(baseballScore) ?? true,
      'homerun': prefs.getBool(baseballHomerun) ?? true,
      'inningChange': prefs.getBool(baseballInningChange) ?? true,
      'gameEnd': prefs.getBool(baseballGameEnd) ?? true,
    };
  }

  static Map<String, bool> disabledEvents(SharedPreferences prefs, String sport) {
    return globalEvents(prefs, sport).map(
      (key, _) => MapEntry(key, false),
    );
  }
}
