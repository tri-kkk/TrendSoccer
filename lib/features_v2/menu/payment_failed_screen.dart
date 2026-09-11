import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({this.args, super.key});

  final PaymentFailedArgs? args;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<TsThemeColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final receiptRows = failedReceiptRows(
      l10n,
      purchaseId: args?.purchaseId,
    );

    return Scaffold(
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
                        TsIcons.warning,
                        size: TsIconSize.xl,
                        color: c.textPrimary,
                      ),
                      const SizedBox(height: TsSpacing.lg),
                      Text(
                        l10n.subscribeFailTitle,
                        style: TsType.h1.copyWith(color: c.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TsSpacing.lg),
                      Text(
                        l10n.paymentFailedSubtitle,
                        style: TsType.bodyLMedium.copyWith(
                          color: c.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: TsSpacing.lg),
                      TsReceiptCard(rows: receiptRows),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TsSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TsButton(
                    label: l10n.subscribeFailRetry,
                    style: TsButtonStyle.primary,
                    size: TsButtonSize.large,
                    expand: true,
                    onPressed: () =>
                        context.pushReplacement('/menu/subscribe'),
                  ),
                  const SizedBox(height: TsSpacing.sm),
                  TsButton(
                    label: l10n.paymentContactSupport,
                    style: TsButtonStyle.ghost,
                    size: TsButtonSize.large,
                    expand: true,
                    onPressed: () => context.push('/menu/help'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
