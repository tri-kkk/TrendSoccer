import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trendsoccer/core/services/fcm_service.dart';
import 'package:trendsoccer/core/services/notification_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

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
  static const _soccerEventLabels = <String, String>{
    'kickoff': '경기 시작',
    'goal': '득점',
    'halftime': '하프타임',
    'fulltime': '경기 종료',
    'yellowCard': '경고',
    'redCard': '퇴장',
    'substitution': '선수 교체',
  };

  static const _baseballEventLabels = <String, String>{
    'firstPitch': '경기 시작',
    'score': '득점',
    'inningChange': '이닝 종료',
    'homerun': '홈런',
    'gameEnd': '경기 종료',
  };

  bool _isLoading = true;
  bool _isSaving = false;
  bool _enabled = false;
  Map<String, bool> _events = {};

  Map<String, String> get _eventLabels =>
      widget.sport == 'baseball' ? _baseballEventLabels : _soccerEventLabels;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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

    setState(() {
      _enabled = settings['enabled'] == true;
      _events = {
        for (final key in _eventLabels.keys)
          key: loadedEvents[key] ?? defaultEvents[key] ?? false,
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

  Future<void> _save() async {
    if (_isSaving || _isLoading) return;
    setState(() => _isSaving = true);

    final ok = await ref.read(notificationServiceProvider).saveMatchAlarmSettings(
          widget.matchId,
          widget.sport,
          _enabled,
          _events,
        );

    if (ok) {
      widget.onEnabledChanged?.call(_enabled);
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
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
              '경기 알림 설정',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '알림 받기',
                  style: TsType.bodyLRegular.copyWith(
                    color: semantic.textPrimary,
                  ),
                ),
              ),
              _styledSwitch(
                semantic: semantic,
                value: _enabled,
                onChanged: _isLoading || _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          _enabled = value;
                          if (value) {
                            _events = _events.map(
                              (key, _) => MapEntry(key, true),
                            );
                          }
                        });
                        _save();
                      },
              ),
            ],
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
            ..._eventLabels.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final eventKey = event.key;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _eventLabels.length - 1 ? 16 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.value,
                        style: TsType.bodyLRegular.copyWith(
                          color: _enabled
                              ? semantic.textPrimary
                              : semantic.textTertiary,
                        ),
                      ),
                    ),
                    _styledSwitch(
                      semantic: semantic,
                      value: _events[eventKey] ?? false,
                      onChanged: _enabled && !_isSaving
                          ? (value) {
                              setState(() {
                                _events[eventKey] = value;
                              });
                              _save();
                            }
                          : null,
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

/// Checks notification permission, then opens the alarm bottom sheet.
Future<void> showAlarmSheet(
  BuildContext context, {
  required int matchId,
  required String sport,
  ValueChanged<bool>? onEnabledChanged,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final matchEventsEnabled =
      prefs.getBool(FCMService.prefMatchEvents) ?? true;

  if (!matchEventsEnabled) {
    if (context.mounted) {
      final shouldGoMenu = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final sem = Theme.of(ctx).extension<TsSemanticColors>()!;
          return AlertDialog(
            backgroundColor: sem.surfaceOverlay,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '경기 알림 비활성화',
              style: TextStyle(color: sem.textPrimary),
            ),
            content: Text(
              '경기 알림이 꺼져 있습니다.\n메뉴 > 알림 설정에서 경기 알림을 켜주세요.',
              style: TextStyle(color: sem.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  '취소',
                  style: TextStyle(color: sem.textTertiary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  '설정으로 이동',
                  style: TextStyle(color: sem.interactivePrimary),
                ),
              ),
            ],
          );
        },
      );
      if (shouldGoMenu == true && context.mounted) {
        context.go('/menu');
      }
    }
    return;
  }

  var status = await Permission.notification.status;

  if (!status.isPermanentlyDenied && status.isDenied) {
    await Permission.notification.request();
    status = await Permission.notification.status;
  }

  if (status.isPermanentlyDenied) {
    if (!context.mounted) return;
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
            '알림 권한 필요',
            style: TextStyle(color: semantic.textPrimary),
          ),
          content: Text(
            '경기 알림을 받으려면 알림 권한이 필요합니다.\n설정에서 알림을 허용해주세요.',
            style: TextStyle(color: semantic.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                '취소',
                style: TextStyle(color: semantic.textTertiary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                '설정으로 이동',
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
    return;
  }

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
