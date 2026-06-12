import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:trendsoccer/core/models/auth_state.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_assets.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class PlanTicket extends StatefulWidget {
  const PlanTicket({
    required this.type,
    this.startDate,
    this.expiryDate,
    this.isCancellationPending = false,
    this.onButtonTap,
    super.key,
  });

  final PlanType type;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final bool isCancellationPending;
  final VoidCallback? onButtonTap;

  @override
  State<PlanTicket> createState() => _PlanTicketState();
}

class _PlanTicketState extends State<PlanTicket> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdownTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant PlanTicket oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type ||
        oldWidget.expiryDate != widget.expiryDate) {
      _countdownTimer?.cancel();
      _startCountdownTimerIfNeeded();
    }
  }

  void _startCountdownTimerIfNeeded() {
    if (widget.type != PlanType.trial) return;
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _title(BuildContext context) {
    final l10n = context.l10n;
    return switch (widget.type) {
      PlanType.none || PlanType.free => l10n.planTicketFreeTitle,
      PlanType.trial => l10n.planTicketTrialTitle,
      PlanType.premium => l10n.planTicketPremiumTitle,
    };
  }

  String _buttonLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (widget.type) {
      PlanType.premium => l10n.planTicketManage,
      PlanType.none || PlanType.free => l10n.planTicketStart,
      PlanType.trial => _trialCountdownLabel(context),
    };
  }

  String _trialCountdownLabel(BuildContext context) {
    final l10n = context.l10n;
    final expiry = widget.expiryDate;
    if (expiry == null) return l10n.planTicketTrialEnded;

    final remaining = expiry.difference(DateTime.now());
    if (remaining.inSeconds <= 0) return l10n.planTicketTrialEnded;

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    return l10n.planTicketTrialRemaining(hours, minutes);
  }

  String get _imageAsset {
    return switch (widget.type) {
      PlanType.none => TsAssets.planFree,
      PlanType.free => TsAssets.planFree,
      PlanType.trial => TsAssets.planTrial,
      PlanType.premium => TsAssets.planPremium,
    };
  }

  String _formatDate(DateTime date) => DateFormat('yyyy.MM.dd').format(date);

  List<String> _dateLines(BuildContext context) {
    final l10n = context.l10n;
    final lines = <String>[];

    switch (widget.type) {
      case PlanType.trial:
        if (widget.startDate != null) {
          lines.add(
            l10n.planTicketTrialStartDate(_formatDate(widget.startDate!)),
          );
        }
        if (widget.expiryDate != null) {
          lines.add(
            l10n.planTicketExpiryPendingDate(_formatDate(widget.expiryDate!)),
          );
        }
      case PlanType.premium:
        if (widget.startDate != null) {
          lines.add(l10n.planTicketStartDate(_formatDate(widget.startDate!)));
        }
        if (widget.isCancellationPending) {
          lines.add(l10n.subscriptionCancelPending);
        } else if (widget.expiryDate != null) {
          lines.add(l10n.planTicketExpiryDate(_formatDate(widget.expiryDate!)));
        }
      case PlanType.none:
      case PlanType.free:
        break;
    }

    return lines;
  }

  Widget _buildTrialCountdownButton(TsSemanticColors semantic) {
    return SizedBox(
      height: 32,
      child: IntrinsicWidth(
        child: Material(
          color: semantic.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TsSpacing.lg,
              vertical: TsSpacing.xs,
            ),
            child: Center(
              child: Text(
                _trialCountdownLabel(context),
                style: TsType.bodyMBold.copyWith(color: semantic.textTertiary),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCtaButton(TsSemanticColors semantic) {
    if (widget.type == PlanType.trial) {
      return _buildTrialCountdownButton(semantic);
    }

    return TsButton(
      label: _buttonLabel(context),
      variant: TsButtonVariant.primary,
      size: TsButtonSize.small,
      onPressed: widget.onButtonTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;
    final dateLines = _dateLines(context);
    final dateStyle = TsType.labelSRegular.copyWith(color: semantic.textTertiary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TsSpacing.lg),
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title(context),
                  style: TsType.headingH2.copyWith(color: semantic.textPrimary),
                ),
                if (dateLines.isNotEmpty) ...[
                  const SizedBox(height: TsSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < dateLines.length; i++) ...[
                        if (i > 0) const SizedBox(height: TsSpacing.xs),
                        Text(dateLines[i], style: dateStyle),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: TsSpacing.sm),
                _buildCtaButton(semantic),
              ],
            ),
          ),
          const SizedBox(width: TsSpacing.lg),
          Image.asset(
            _imageAsset,
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
