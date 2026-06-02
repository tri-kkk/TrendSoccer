import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/services/notification_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

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
        if (states.contains(WidgetState.selected)) {
          return semantic.surfaceBase;
        }
        return semantic.surfaceOverlay;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
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
                        setState(() => _enabled = value);
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
              final eventEnabled = _enabled && !_isSaving;
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
                          color: eventEnabled
                              ? semantic.textPrimary
                              : semantic.textTertiary,
                        ),
                      ),
                    ),
                    _styledSwitch(
                      semantic: semantic,
                      value: _events[event.key] ?? false,
                      onChanged: eventEnabled
                          ? (value) {
                              setState(() {
                                _events[event.key] = value;
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

void showAlarmSheet(
  BuildContext context, {
  required int matchId,
  required String sport,
  ValueChanged<bool>? onEnabledChanged,
}) {
  showModalBottomSheet<void>(
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

void showLoginPromptSheet(BuildContext context) {
  final semantic = Theme.of(context).extension<TsSemanticColors>()!;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: semantic.surfaceOverlay,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(
          top: 12,
          bottom: 24 + MediaQuery.of(sheetContext).padding.bottom,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(
              '로그인이 필요합니다',
              style: TsType.headingH3.copyWith(color: semantic.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              '경기 알림을 설정하려면 로그인해 주세요.',
              style: TsType.bodyLBold.copyWith(color: semantic.textSecondary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TsButton(
                label: '로그인하기',
                variant: TsButtonVariant.primary,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  sheetContext.push('/login');
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TsButton(
                label: '닫기',
                variant: TsButtonVariant.secondary,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
