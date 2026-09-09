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
import 'package:trendsoccer/l10n/app_localizations.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: TsAppBar(
        type: TsAppBarType.back,
        title: l10n.menuNotifications,
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
            TsSectionHeader(title: l10n.notificationGeneral),
            const SizedBox(height: TsSpacing.lg),
            _settingsGroup(
              c,
              [
                _topicRow(
                  label: l10n.notificationSettingsAppAlerts,
                  prefKey: FCMService.prefAppGeneral,
                  baseTopic: FCMService.topicAppGeneral,
                ),
                _topicRow(
                  label: l10n.notificationSettingsAnnouncements,
                  prefKey: FCMService.prefMatchEvents,
                  baseTopic: FCMService.topicMatchEvents,
                ),
                _topicRow(
                  label: l10n.notificationMarketing,
                  prefKey: FCMService.prefMarketing,
                  baseTopic: FCMService.topicMarketing,
                ),
              ],
            ),
            const SizedBox(height: TsSpacing.lg),
            TsSectionHeader(
              title: l10n.feedNewsSportSoccer,
              subtitle: l10n.notificationSettingsSportSubtitle,
            ),
            const SizedBox(height: TsSpacing.lg),
            _settingsGroup(
              c,
              [
                _prefRow(l10n.alarmKickoff, AlarmPreferenceKeys.soccerKickoff),
                _prefRow(l10n.alarmHalftime, AlarmPreferenceKeys.soccerHalftime),
                _prefRow(
                  l10n.alarmSecondHalf,
                  AlarmPreferenceKeys.soccerSecondHalf,
                ),
                _prefRow(l10n.alarmFulltime, AlarmPreferenceKeys.soccerFulltime),
                _prefRow(l10n.alarmGoal, AlarmPreferenceKeys.soccerGoal),
                _prefRow(
                  l10n.alarmSubstitution,
                  AlarmPreferenceKeys.soccerSubstitution,
                ),
                _prefRow(
                  l10n.alarmYellowCard,
                  AlarmPreferenceKeys.soccerYellowCard,
                ),
                _prefRow(l10n.alarmRedCard, AlarmPreferenceKeys.soccerRedCard),
              ],
            ),
            const SizedBox(height: TsSpacing.lg),
            TsSectionHeader(
              title: l10n.feedNewsSportBaseball,
              subtitle: l10n.notificationSettingsSportSubtitle,
            ),
            const SizedBox(height: TsSpacing.lg),
            _settingsGroup(
              c,
              [
                _prefRow(
                  l10n.alarmGameStart,
                  AlarmPreferenceKeys.baseballFirstPitch,
                ),
                _prefRow(l10n.alarmScore, AlarmPreferenceKeys.baseballScore),
                _prefRow(l10n.alarmHomerun, AlarmPreferenceKeys.baseballHomerun),
                _prefRow(
                  l10n.alarmInningEnd,
                  AlarmPreferenceKeys.baseballInningChange,
                ),
                _prefRow(l10n.alarmGameEnd, AlarmPreferenceKeys.baseballGameEnd),
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
