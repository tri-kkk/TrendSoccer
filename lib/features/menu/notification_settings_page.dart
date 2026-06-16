import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/constants/alarm_preference_keys.dart';
import 'package:trendsoccer/core/providers/shared_preferences_provider.dart';
import 'package:trendsoccer/core/services/fcm_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/toggle/ts_toggle.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _isLoading = true;
  bool _isSavingFcm = false;

  bool _appGeneral = true;
  bool _marketing = true;

  bool _soccerKickoff = true;
  bool _soccerGoal = true;
  bool _soccerHalftime = true;
  bool _soccerSecondHalf = true;
  bool _soccerFulltime = true;
  bool _soccerYellowCard = true;
  bool _soccerRedCard = true;
  bool _soccerSubstitution = true;

  bool _baseballFirstPitch = true;
  bool _baseballScore = true;
  bool _baseballHomerun = true;
  bool _baseballInningChange = true;
  bool _baseballGameEnd = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (!mounted) return;
    setState(() {
      _appGeneral = prefs.getBool(FCMService.prefAppGeneral) ?? true;
      _marketing = prefs.getBool(FCMService.prefMarketing) ?? true;

      _soccerKickoff = prefs.getBool(AlarmPreferenceKeys.soccerKickoff) ?? true;
      _soccerGoal = prefs.getBool(AlarmPreferenceKeys.soccerGoal) ?? true;
      _soccerHalftime =
          prefs.getBool(AlarmPreferenceKeys.soccerHalftime) ?? true;
      _soccerSecondHalf =
          prefs.getBool(AlarmPreferenceKeys.soccerSecondHalf) ?? true;
      _soccerFulltime =
          prefs.getBool(AlarmPreferenceKeys.soccerFulltime) ?? true;
      _soccerYellowCard =
          prefs.getBool(AlarmPreferenceKeys.soccerYellowCard) ?? true;
      _soccerRedCard = prefs.getBool(AlarmPreferenceKeys.soccerRedCard) ?? true;
      _soccerSubstitution =
          prefs.getBool(AlarmPreferenceKeys.soccerSubstitution) ?? true;

      _baseballFirstPitch =
          prefs.getBool(AlarmPreferenceKeys.baseballFirstPitch) ?? true;
      _baseballScore = prefs.getBool(AlarmPreferenceKeys.baseballScore) ?? true;
      _baseballHomerun =
          prefs.getBool(AlarmPreferenceKeys.baseballHomerun) ?? true;
      _baseballInningChange =
          prefs.getBool(AlarmPreferenceKeys.baseballInningChange) ?? true;
      _baseballGameEnd =
          prefs.getBool(AlarmPreferenceKeys.baseballGameEnd) ?? true;

      _isLoading = false;
    });
  }

  Future<void> _onFcmToggleChanged({
    required String prefKey,
    required String baseTopic,
    required bool value,
    required void Function(bool) updateState,
  }) async {
    if (_isSavingFcm || _isLoading) return;
    setState(() {
      _isSavingFcm = true;
      updateState(value);
    });

    try {
      await FCMService().setTopicEnabled(
        baseTopic: baseTopic,
        prefKey: prefKey,
        enabled: value,
      );
    } catch (_) {
      if (mounted) {
        setState(() => updateState(!value));
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingFcm = false);
      }
    }
  }

  Future<void> _saveEventPref(String key, bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final fcmEnabled = !_isLoading && !_isSavingFcm;

    return Scaffold(
      backgroundColor: semantic.surfaceRaised,
      appBar: AppBar(
        title: Text(
          l10n.notificationSettings,
          style: TsType.headingH3.copyWith(color: semantic.textPrimary),
        ),
        backgroundColor: semantic.surfaceRaised,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: semantic.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: semantic.textDisabled),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: semantic.interactivePrimary,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionBlock(
                    title: l10n.notificationGeneral,
                    children: [
                      _SettingsToggleRow(
                        label: l10n.notificationAppAlerts,
                        value: _appGeneral,
                        onChanged: fcmEnabled
                            ? (value) => _onFcmToggleChanged(
                                  prefKey: FCMService.prefAppGeneral,
                                  baseTopic: FCMService.topicAppGeneral,
                                  value: value,
                                  updateState: (val) => _appGeneral = val,
                                )
                            : null,
                      ),
                      _SettingsToggleRow(
                        label: l10n.notificationMarketing,
                        value: _marketing,
                        onChanged: fcmEnabled
                            ? (value) => _onFcmToggleChanged(
                                  prefKey: FCMService.prefMarketing,
                                  baseTopic: FCMService.topicMarketing,
                                  value: value,
                                  updateState: (val) => _marketing = val,
                                )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionBlock(
                    title: l10n.notificationSoccer,
                    children: [
                      _SettingsToggleRow(
                        label: l10n.alarmKickoff,
                        value: _soccerKickoff,
                        onChanged: (value) {
                          setState(() => _soccerKickoff = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.soccerKickoff,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmHalftime,
                        value: _soccerHalftime,
                        onChanged: (value) {
                          setState(() => _soccerHalftime = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.soccerHalftime,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmSecondHalfStart,
                        value: _soccerSecondHalf,
                        onChanged: (value) {
                          setState(() => _soccerSecondHalf = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.soccerSecondHalf,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmFulltime,
                        value: _soccerFulltime,
                        onChanged: (value) {
                          setState(() => _soccerFulltime = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.soccerFulltime,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmGoal,
                        value: _soccerGoal,
                        onChanged: (value) {
                          setState(() => _soccerGoal = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.soccerGoal,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmSubstitution,
                        value: _soccerSubstitution,
                        onChanged: (value) {
                          setState(() => _soccerSubstitution = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.soccerSubstitution,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmYellowCard,
                        value: _soccerYellowCard,
                        onChanged: (value) {
                          setState(() => _soccerYellowCard = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.soccerYellowCard,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmRedCard,
                        value: _soccerRedCard,
                        onChanged: (value) {
                          setState(() => _soccerRedCard = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.soccerRedCard,
                            value,
                          ));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionBlock(
                    title: l10n.notificationBaseball,
                    children: [
                      _SettingsToggleRow(
                        label: l10n.alarmGameStart,
                        value: _baseballFirstPitch,
                        onChanged: (value) {
                          setState(() => _baseballFirstPitch = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.baseballFirstPitch,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmScore,
                        value: _baseballScore,
                        onChanged: (value) {
                          setState(() => _baseballScore = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.baseballScore,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmHomerun,
                        value: _baseballHomerun,
                        onChanged: (value) {
                          setState(() => _baseballHomerun = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.baseballHomerun,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmInningEnd,
                        value: _baseballInningChange,
                        onChanged: (value) {
                          setState(() => _baseballInningChange = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.baseballInningChange,
                            value,
                          ));
                        },
                      ),
                      _SettingsToggleRow(
                        label: l10n.alarmGameEnd,
                        value: _baseballGameEnd,
                        onChanged: (value) {
                          setState(() => _baseballGameEnd = value);
                          unawaited(_saveEventPref(
                            AlarmPreferenceKeys.baseballGameEnd,
                            value,
                          ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TsType.headingH2.copyWith(color: semantic.textPrimary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: semantic.surfaceOverlay,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 22),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TsType.bodyLRegular.copyWith(color: semantic.textPrimary),
          ),
        ),
        TsToggle(value: value, onChanged: onChanged),
      ],
    );
  }
}
