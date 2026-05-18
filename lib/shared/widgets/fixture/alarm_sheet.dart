import 'package:flutter/material.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

class AlarmSheet extends StatefulWidget {
  const AlarmSheet({super.key, required this.sport});

  final SportType sport;

  @override
  State<AlarmSheet> createState() => _AlarmSheetState();
}

class _AlarmSheetState extends State<AlarmSheet> {
  bool _masterSwitch = true;

  late List<_AlarmEvent> _events;

  @override
  void initState() {
    super.initState();
    _events = widget.sport == SportType.soccer
        ? [
            _AlarmEvent('경기 시작', true),
            _AlarmEvent('득점', true),
            _AlarmEvent('경고 및 퇴장', true),
            _AlarmEvent('하프타임', true),
            _AlarmEvent('경기 종료', true),
          ]
        : [
            _AlarmEvent('경기 시작', true),
            _AlarmEvent('득점', true),
            _AlarmEvent('이닝 종료', true),
            _AlarmEvent('퇴장', true),
            _AlarmEvent('경기 종료', true),
          ];
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
        return Colors.white;
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
        color: semantic.surfaceRaised,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 16, right: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '경기 알림 설정',
                  style: TsType.headingH3.copyWith(color: semantic.textPrimary),
                ),
              ),
              _styledSwitch(
                semantic: semantic,
                value: _masterSwitch,
                onChanged: (val) {
                  setState(() {
                    _masterSwitch = val;
                    for (final e in _events) {
                      e.isOn = val;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFD9D9D9)),
          const SizedBox(height: 16),
          ..._events.asMap().entries.map((entry) {
            final i = entry.key;
            final event = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: i < _events.length - 1 ? 16 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.label,
                      style: TsType.bodyLRegular.copyWith(color: Colors.white),
                    ),
                  ),
                  _styledSwitch(
                    semantic: semantic,
                    value: event.isOn,
                    onChanged: _masterSwitch
                        ? (val) {
                            setState(() {
                              event.isOn = val;
                            });
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

class _AlarmEvent {
  _AlarmEvent(this.label, this.isOn);

  final String label;
  bool isOn;
}

/// Usage: `showAlarmSheet(context, SportType.soccer);`
void showAlarmSheet(BuildContext context, SportType sport) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => AlarmSheet(sport: sport),
  );
}
