import 'package:flutter/material.dart';

import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/l10n/app_localizations.dart';

class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    required this.onRetry,
    this.message,
    super.key,
  });

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TsSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: sem.textTertiary,
            ),
            const SizedBox(height: TsSpacing.lg),
            Text(
              message ?? l10n.networkErrorMessage,
              style: TsType.bodyLRegular.copyWith(color: sem.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TsSpacing.xl),
            SizedBox(
              width: 160,
              height: 48,
              child: TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  backgroundColor: sem.interactivePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TsSpacing.sm),
                  ),
                ),
                child: Text(
                  l10n.retry,
                  style: TsType.bodyLBold.copyWith(color: sem.surfaceBase),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactNetworkError extends StatelessWidget {
  const CompactNetworkError({
    required this.onRetry,
    this.message,
    super.key,
  });

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final sem = Theme.of(context).extension<TsSemanticColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TsSpacing.lg,
        vertical: TsSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              message ?? l10n.networkErrorMessage,
              style: TsType.bodyMRegular.copyWith(color: sem.textTertiary),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: sem.interactivePrimary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: l10n.retry,
          ),
        ],
      ),
    );
  }
}
