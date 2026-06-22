import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';

Future<void> showExitDialog(BuildContext context) {
  final sem = Theme.of(context).extension<TsSemanticColors>()!;
  final l10n = AppLocalizations.of(context)!;

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 348,
          padding: const EdgeInsets.all(TsSpacing.xl),
          decoration: BoxDecoration(
            color: sem.surfaceOverlay,
            borderRadius: BorderRadius.circular(TsSpacing.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.exitDialogTitle,
                style: TsType.headingH3.copyWith(color: sem.textPrimary),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: TsSpacing.sm),
              Text(
                l10n.exitDialogMessage,
                style: TsType.bodyLRegular.copyWith(color: sem.textSecondary),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: TsSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: sem.surfaceContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(TsSpacing.sm),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: TsType.bodyLBold.copyWith(
                            color: sem.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TsSpacing.sm),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () => SystemNavigator.pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: sem.interactivePrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(TsSpacing.sm),
                          ),
                        ),
                        child: Text(
                          l10n.exitDialogConfirm,
                          style: TsType.bodyLBold.copyWith(
                            color: sem.surfaceBase,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
