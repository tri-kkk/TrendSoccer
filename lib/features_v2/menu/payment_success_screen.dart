import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:trendsoccer/core/providers/auth_provider.dart';
import 'package:trendsoccer/design_system/icons/ts_icon.dart';
import 'package:trendsoccer/design_system/icons/ts_icons.dart';
import 'package:trendsoccer/design_system/tokens/ts_icon_size.dart';
import 'package:trendsoccer/design_system/tokens/ts_spacing.dart';
import 'package:trendsoccer/design_system/tokens/ts_theme_colors.dart';
import 'package:trendsoccer/design_system/tokens/ts_type.dart';
import 'package:trendsoccer/design_system/widgets/ts_button.dart';
import 'package:trendsoccer/design_system/widgets/ts_receipt_card.dart';
import 'package:trendsoccer/features_v2/menu/payment_receipt_rows.dart';
import 'package:trendsoccer/features_v2/menu/payment_route_args.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({this.args, super.key});

  final PaymentSuccessArgs? args;

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  int _seconds = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_seconds <= 1) {
        _goHome();
        return;
      }
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goHome() {
    _timer?.cancel();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final args = widget.args;
    final nextBilling =
        ref.watch(authProvider).subscriptionInfo?.nextBillingDate;
    final receiptRows = successReceiptRows(
      l10n,
      basePlanId: args?.basePlanId,
      storePrice: args?.storePrice,
      nextBillingDate: nextBilling,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goHome();
      },
      child: Scaffold(
        backgroundColor: c.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      TsSpacing.lg,
                      TsSpacing.lg,
                      TsSpacing.lg,
                      TsSpacing.xl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TsIcon(
                          TsIcons.checkCircleOutline,
                          size: TsIconSize.xl,
                          color: c.textPrimary,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        Text(
                          l10n.paymentSuccessTitle,
                          style: TsType.h1.copyWith(color: c.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: TsSpacing.lg),
                        Text(
                          l10n.paymentSuccessSubtitle,
                          style: TsType.bodyLMedium.copyWith(
                            color: c.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (receiptRows.isNotEmpty) ...[
                          const SizedBox(height: TsSpacing.lg),
                          TsReceiptCard(rows: receiptRows),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(TsSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TsButton(
                      label: l10n.paymentSuccessGoHome,
                      style: TsButtonStyle.primary,
                      size: TsButtonSize.large,
                      expand: true,
                      onPressed: _goHome,
                    ),
                    const SizedBox(height: TsSpacing.sm),
                    Text(
                      l10n.signupCompleteHomeCountdown(_seconds),
                      style: TsType.labelSMedium.copyWith(color: c.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
