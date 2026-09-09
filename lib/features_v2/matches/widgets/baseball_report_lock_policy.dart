import 'package:flutter/foundation.dart';

import 'package:trendsoccer/l10n/app_localizations.dart';

/// Grade-based lock rules for baseball match report blocks 02, 05–07.
class BaseballReportLockPolicy {
  const BaseballReportLockPolicy({
    required this.lockedBlocks,
    required this.lockLabel,
    this.onTap,
  });

  final Set<int> lockedBlocks;
  final String lockLabel;
  final VoidCallback? onTap;

  bool isLocked(int blockNumber) => lockedBlocks.contains(blockNumber);

  static BaseballReportLockPolicy resolve({
    required AppLocalizations l10n,
    required bool isGuest,
    required bool hasFullAccess,
    required VoidCallback onGuestTap,
    required VoidCallback onSubscribeTap,
  }) {
    if (hasFullAccess) {
      return const BaseballReportLockPolicy(
        lockedBlocks: {},
        lockLabel: '',
      );
    }

    if (isGuest) {
      return BaseballReportLockPolicy(
        lockedBlocks: const {2, 5, 6, 7},
        lockLabel: l10n.matchReportLockLoginToView,
        onTap: onGuestTap,
      );
    }

    return BaseballReportLockPolicy(
      lockedBlocks: const {2, 5, 6, 7},
      lockLabel: l10n.matchReportLockPremiumContent,
      onTap: onSubscribeTap,
    );
  }
}
