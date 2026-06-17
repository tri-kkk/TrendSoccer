import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:trendsoccer/core/services/notification_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/toast/ts_toast.dart';

class AlarmSheet extends ConsumerStatefulWidget {
  const AlarmSheet({
    required this.matchId,
    required this.sport,
    this.onEnabledChanged,
    super.key,
  });

  final int matchId;
  final String sport;
  final ValueChanged<bool>? onEnabledChanged;

  @override
  ConsumerState<AlarmSheet> createState() => _AlarmSheetState();
}

class _AlarmSheetState extends ConsumerState<AlarmSheet> {
  bool _isLoading = true;
  Map<String, bool> _events = {};
  Timer? _saveDebounceTimer;
  bool _savePending = false;

  bool get _isEnabled => _events.values.any((value) => value);

  Map<String, String> _eventLabels(BuildContext context) {
    final l10n = context.l10n;
    if (widget.sport == 'baseball') {
      return {
        'firstPitch': l10n.baseballEventFirstPitch,
        'score': l10n.baseballEventScore,
        'inningChange': l10n.baseballEventInningChange,
        'homerun': l10n.baseballEventHomerun,
        'gameEnd': l10n.baseballEventGameEnd,
      };
    }
    return {
      'kickoff': l10n.soccerEventKickoff,
      'goal': l10n.soccerEventGoal,
      'halftime': l10n.soccerEventHalftime,
      'secondHalf': l10n.alarmSecondHalf,
      'fulltime': l10n.soccerEventFulltime,
      'yellowCard': l10n.soccerEventYellowCard,
      'redCard': l10n.soccerEventRedCard,
      'substitution': l10n.soccerEventSubstitution,
    };
  }

  bool _defaultEventValue(String key, bool serviceDefault) {
    if (widget.sport != 'soccer') return serviceDefault;
    return switch (key) {
      'kickoff' => true,
      'goal' => true,
      'fulltime' => true,
      _ => false,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    if (_savePending) {
      unawaited(_saveAlarmToServer());
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await ref
        .read(notificationServiceProvider)
        .getMatchAlarmSettings(widget.matchId, widget.sport);
    if (!mounted) return;

    final defaults = ref
        .read(notificationServiceProvider)
        .defaultSettings(widget.sport);
    final defaultEvents = _parseEvents(defaults['events']);
    final loadedEvents = _parseEvents(settings['events']);

    final labels = _eventLabels(context);
    setState(() {
      _events = {
        for (final key in labels.keys)
          key: loadedEvents.containsKey(key)
              ? loadedEvents[key]!
              : _defaultEventValue(key, defaultEvents[key] ?? false),
      };
      _isLoading = false;
    });
  }

  Map<String, bool> _parseEvents(Object? raw) {
    if (raw is! Map) return {};
    return raw.map(
      (key, value) => MapEntry(key.toString(), value == true),
    );
  }

  Future<void> _reloadSettingsFromServer() async {
    final settings = await ref
        .read(notificationServiceProvider)
        .getMatchAlarmSettings(widget.matchId, widget.sport);
    if (!mounted) return;

    final defaults = ref
        .read(notificationServiceProvider)
        .defaultSettings(widget.sport);
    final defaultEvents = _parseEvents(defaults['events']);
    final loadedEvents = _parseEvents(settings['events']);

    final labels = _eventLabels(context);
    setState(() {
      _events = {
        for (final key in labels.keys)
          key: loadedEvents.containsKey(key)
              ? loadedEvents[key]!
              : _defaultEventValue(key, defaultEvents[key] ?? false),
      };
    });
  }

  void _scheduleSave() {
    _savePending = true;
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _savePending = false;
      unawaited(_saveAlarmToServer());
    });
  }

  Future<void> _saveAlarmToServer() async {
    if (!mounted || _isLoading) return;

    final ok = await ref.read(notificationServiceProvider).saveMatchAlarmSettings(
          widget.matchId,
          widget.sport,
          _isEnabled,
          _events,
        );

    if (!mounted) return;

    if (ok) {
      widget.onEnabledChanged?.call(_isEnabled);
      return;
    }

    await _reloadSettingsFromServer();
    if (!mounted) return;
    TsToast.error(context, context.l10n.errorUnauthorized);
  }

  Widget _styledSwitch({
    required TsSemanticColors semantic,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return semantic.textTertiary;
        }
        if (states.contains(WidgetState.selected)) {
          return semantic.surfaceBase;
        }
        return semantic.surfaceOverlay;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return semantic.surfaceContainer;
        }
        if (states.contains(WidgetState.selected)) {
          return semantic.interactivePrimary;
        }
        return semantic.surfaceContainer;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    final eventLabels = _eventLabels(context);

    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceOverlay,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: semantic.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.matchAlarmSettingsTitle,
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: semantic.borderSubtle),
          const SizedBox(height: 16),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(
                color: semantic.interactivePrimary,
              ),
            )
          else
            ...eventLabels.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final eventKey = event.key;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < eventLabels.length - 1 ? 16 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.value,
                        style: TsType.bodyLRegular.copyWith(
                          color: semantic.textPrimary,
                        ),
                      ),
                    ),
                    _styledSwitch(
                      semantic: semantic,
                      value: _events[eventKey] ?? false,
                      onChanged: (value) {
                        setState(() => _events[eventKey] = value);
                        _scheduleSave();
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

/// Returns false when match-alarm flow should abort (notification permission).
/// No login required — anonymous devices use X-Device-Token via [NotificationService].
Future<bool> ensureMatchAlarmGate(BuildContext context) async {
  var status = await Permission.notification.status;

  if (!status.isPermanentlyDenied && status.isDenied) {
    await Permission.notification.request();
    status = await Permission.notification.status;
  }

  if (status.isPermanentlyDenied) {
    if (!context.mounted) return false;
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final semantic = Theme.of(ctx).extension<TsSemanticColors>()!;
        return AlertDialog(
          backgroundColor: semantic.surfaceOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            ctx.l10n.notificationPermissionTitle,
            style: TextStyle(color: semantic.textPrimary),
          ),
          content: Text(
            ctx.l10n.notificationPermissionMessageMatch,
            style: TextStyle(color: semantic.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                ctx.l10n.cancel,
                style: TextStyle(color: semantic.textTertiary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                ctx.l10n.notificationPermissionGoSettings,
                style: TextStyle(color: semantic.interactivePrimary),
              ),
            ),
          ],
        );
      },
    );
    if (shouldOpen == true) {
      await openAppSettings();
    }
    return false;
  }

  if (!status.isGranted) {
    return false;
  }

  return context.mounted;
}

/// Checks notification permission, then opens the alarm bottom sheet.
Future<void> showAlarmSheet(
  BuildContext context, {
  required int matchId,
  required String sport,
  ValueChanged<bool>? onEnabledChanged,
}) async {
  if (!await ensureMatchAlarmGate(context)) return;

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => AlarmSheet(
      matchId: matchId,
      sport: sport,
      onEnabledChanged: onEnabledChanged,
    ),
  );
}
