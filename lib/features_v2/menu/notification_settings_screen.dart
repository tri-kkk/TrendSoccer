import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/constants/alarm_preference_keys.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/fcm_service.dart';
import 'package:trendsoccer/design_system/tokens/ts_radius.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/widgets/ts_app_bar.dart';
import 'package:trendsoccer/design_system/widgets/ts_section_header.dart';
import 'package:trendsoccer/design_system/widgets/ts_settings_toggle_row.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  static const _sportSubtitle =
      'Applies to matches you turn alerts on for from now.';

  late final Map<String, bool> _values;
  final Set<String> _topicTogglesInFlight = {};

  @override
  void initState() {
    super.initState();
    _values = _loadValues(ref.read(sharedPreferencesProvider));
  }

  Map<String, bool> _loadValues(SharedPreferences prefs) {
    return {
      FCMService.prefAppGeneral:
          prefs.getBool(FCMService.prefAppGeneral) ?? true,
      FCMService.prefMatchEvents:
          prefs.getBool(FCMService.prefMatchEvents) ?? true,
      FCMService.prefMarketing:
          prefs.getBool(FCMService.prefMarketing) ?? true,
      for (final key in AlarmPreferenceKeys.allSoccerKeys)
        key: prefs.getBool(key) ?? true,
      for (final key in AlarmPreferenceKeys.allBaseballKeys)
        key: prefs.getBool(key) ?? true,
    };
  }

  Future<void> _onTopicToggle({
    required String prefKey,
    required String baseTopic,
    required bool enabled,
  }) async {
    if (_topicTogglesInFlight.contains(prefKey)) return;

    final previous = _values[prefKey] ?? true;
    setState(() {
      _values[prefKey] = enabled;
      _topicTogglesInFlight.add(prefKey);
    });

    try {
      await FCMService().setTopicEnabled(
        baseTopic: baseTopic,
        prefKey: prefKey,
        enabled: enabled,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _values[prefKey] = previous);
    } finally {
      if (mounted) {
        setState(() => _topicTogglesInFlight.remove(prefKey));
      }
    }
  }

  Future<void> _onPrefToggle(String prefKey, bool enabled) async {
    setState(() => _values[prefKey] = enabled);
    await ref.read(sharedPreferencesProvider).setBool(prefKey, enabled);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: 'Notifications',
        onBack: () => context.go('/menu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          TsSpacing.lg,
          TsSpacing.lg,
          TsSpacing.lg,
          TsSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TsSectionHeader(title: 'General'),
            const SizedBox(height: TsSpacing.lg),
            _settingsGroup(
              c,
              [
                _topicRow(
                  label: 'App alerts',
                  prefKey: FCMService.prefAppGeneral,
                  baseTopic: FCMService.topicAppGeneral,
                ),
                _topicRow(
                  label: 'Announcements',
                  prefKey: FCMService.prefMatchEvents,
                  baseTopic: FCMService.topicMatchEvents,
                ),
                _topicRow(
                  label: 'Marketing',
                  prefKey: FCMService.prefMarketing,
                  baseTopic: FCMService.topicMarketing,
                ),
              ],
            ),
            const SizedBox(height: TsSpacing.lg),
            const TsSectionHeader(
              title: 'Soccer',
              subtitle: _sportSubtitle,
            ),
            const SizedBox(height: TsSpacing.lg),
            _settingsGroup(
              c,
              [
                _prefRow('Kickoff', AlarmPreferenceKeys.soccerKickoff),
                _prefRow('Halftime', AlarmPreferenceKeys.soccerHalftime),
                _prefRow('Second half', AlarmPreferenceKeys.soccerSecondHalf),
                _prefRow('Full time', AlarmPreferenceKeys.soccerFulltime),
                _prefRow('Goal', AlarmPreferenceKeys.soccerGoal),
                _prefRow('Substitution', AlarmPreferenceKeys.soccerSubstitution),
                _prefRow('Yellow card', AlarmPreferenceKeys.soccerYellowCard),
                _prefRow('Red card', AlarmPreferenceKeys.soccerRedCard),
              ],
            ),
            const SizedBox(height: TsSpacing.lg),
            const TsSectionHeader(
              title: 'Baseball',
              subtitle: _sportSubtitle,
            ),
            const SizedBox(height: TsSpacing.lg),
            _settingsGroup(
              c,
              [
                _prefRow('Game start', AlarmPreferenceKeys.baseballFirstPitch),
                _prefRow('Score', AlarmPreferenceKeys.baseballScore),
                _prefRow('Home run', AlarmPreferenceKeys.baseballHomerun),
                _prefRow('Inning end', AlarmPreferenceKeys.baseballInningChange),
                _prefRow('Game end', AlarmPreferenceKeys.baseballGameEnd),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsGroup(TsThemeColors c, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: TsRadius.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _topicRow({
    required String label,
    required String prefKey,
    required String baseTopic,
  }) {
    return TsSettingsToggleRow(
      label: label,
      value: _values[prefKey] ?? true,
      onChanged: (enabled) => _onTopicToggle(
        prefKey: prefKey,
        baseTopic: baseTopic,
        enabled: enabled,
      ),
    );
  }

  Widget _prefRow(String label, String prefKey) {
    return TsSettingsToggleRow(
      label: label,
      value: _values[prefKey] ?? true,
      onChanged: (enabled) => _onPrefToggle(prefKey, enabled),
    );
  }
}
