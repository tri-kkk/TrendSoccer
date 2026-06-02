import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trendsoccer/core/models/sport_type.dart';
import 'package:trendsoccer/core/navigation/subscribe_navigation.dart';
import 'package:trendsoccer/core/theme/tokens/ts_type.dart';
import 'package:trendsoccer/core/theme/ts_semantic_colors.dart';
import 'package:trendsoccer/core/utils/l10n_helper.dart';
import 'package:trendsoccer/shared/widgets/buttons/ts_button.dart';

class SubscribeSheet extends ConsumerWidget {
  const SubscribeSheet({super.key, required this.sport});

  final SportType sport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = Theme.of(context).extension<TsSemanticColors>()!;

    final l10n = context.l10n;
    final description = sport == SportType.soccer
        ? l10n.premiumSubscribeSheetSoccerDesc
        : l10n.premiumSubscribeSheetBaseballDesc;

    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceOverlay,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
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
            l10n.premiumExclusiveContent,
            style: TsType.headingH3.copyWith(color: semantic.textPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TsType.bodyLBold.copyWith(color: semantic.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TsButton(
              label: l10n.premiumSubscribeNow,
              variant: TsButtonVariant.primary,
              onPressed: () {
                Navigator.of(context).pop();
                navigateToSubscribe(context, ref);
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TsButton(
              label: l10n.close,
              variant: TsButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Usage: `showSubscribeSheet(context, SportType.soccer);`
void showSubscribeSheet(BuildContext context, SportType sport) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => SubscribeSheet(sport: sport),
  );
}
