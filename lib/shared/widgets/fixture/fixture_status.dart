import 'package:flutter/material.dart';

import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/core/theme/tokens/ts_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';

enum FixtureMatchStatus {
  scheduled,
  live,
  finished,
  interrupted,
  postponed,
  cancelled,
}

class FixtureStatus extends StatefulWidget {
  const FixtureStatus({
    required this.status,
    this.timeText,
    super.key,
  });

  final FixtureMatchStatus status;
  final String? timeText;

  @override
  State<FixtureStatus> createState() => _FixtureStatusState();
}

class _FixtureStatusState extends State<FixtureStatus> with TickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseOpacity;

  void _ensurePulseController() {
    if (widget.status == FixtureMatchStatus.live && _pulseController == null) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );
      _pulseOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
      _pulseController = controller..repeat(reverse: true);
    } else if (widget.status != FixtureMatchStatus.live && _pulseController != null) {
      _pulseController!.dispose();
      _pulseController = null;
      _pulseOpacity = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _ensurePulseController();
  }

  @override
  void didUpdateWidget(covariant FixtureStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _ensurePulseController();
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = context.l10n;
    return SizedBox(
      width: 56,
      child: switch (widget.status) {
        FixtureMatchStatus.scheduled => Center(
            child: Text(
              widget.timeText ?? 'HH:MM',
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
        FixtureMatchStatus.live => Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _pulseOpacity!,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: TsColors.systemError500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.timeText ?? l10n.fixtureLive,
                  style: TsType.labelSRegular.copyWith(color: TsColors.systemError500),
                ),
              ],
            ),
          ),
        FixtureMatchStatus.finished => Center(
            child: Text(
              widget.timeText ?? l10n.fixtureStatusFinal,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
        FixtureMatchStatus.interrupted => Center(
            child: Text(
              widget.timeText ?? l10n.statusInterrupted,
              style: TsType.labelSRegular.copyWith(
                color: TsColors.systemWarning500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        FixtureMatchStatus.postponed => Center(
            child: Text(
              widget.timeText ?? l10n.statusPostponed,
              style: TsType.labelSRegular.copyWith(
                color: TsColors.systemWarning500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        FixtureMatchStatus.cancelled => Center(
            child: Text(
              widget.timeText ?? l10n.matchCancelled,
              style: TsType.labelSRegular.copyWith(color: semantic.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
      },
    );
  }
}
