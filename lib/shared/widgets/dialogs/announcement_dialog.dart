import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trendsoccer/core/services/announcement_service.dart';
import 'package:trendsoccer/core/theme/tokens/ts_spacing.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showAnnouncementDialog(
  BuildContext context,
  AnnouncementConfig config,
  AnnouncementService service,
) {
  final sem = Theme.of(context).extension<TsSemanticColors>()!;
  final router = GoRouter.of(context);

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (dialogContext) => Center(
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
                config.title,
                style: TsType.headingH3.copyWith(color: sem.textPrimary),
                textAlign: TextAlign.start,
              ),
              if (config.message.isNotEmpty) ...[
                const SizedBox(height: TsSpacing.sm),
                Text(
                  config.message,
                  style: TsType.bodyLRegular.copyWith(color: sem.textSecondary),
                  textAlign: TextAlign.start,
                ),
              ],
              const SizedBox(height: TsSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () {
                    final url = config.url;
                    unawaited(service.markDismissed(config.id));
                    Navigator.pop(dialogContext);

                    if (url.isEmpty) return;

                    if (url.startsWith('/')) {
                      router.push(url);
                    } else if (url.startsWith('http')) {
                      unawaited(
                        launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: sem.interactivePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TsSpacing.sm),
                    ),
                  ),
                  child: Text(
                    config.buttonText.isNotEmpty
                        ? config.buttonText
                        : dialogContext.l10n.confirm,
                    style: TsType.bodyLBold.copyWith(color: sem.surfaceBase),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
