import 'package:flutter/foundation.dart';

/// Grade-based lock rules for soccer match report blocks 02–09.
class SoccerReportLockPolicy {
  const SoccerReportLockPolicy({
    required this.lockedBlocks,
    required this.lockLabel,
    this.onTap,
  });

  final Set<int> lockedBlocks;
  final String lockLabel;
  final VoidCallback? onTap;

  bool isLocked(int blockNumber) => lockedBlocks.contains(blockNumber);

  bool get shouldFetchPrediction =>
      !isLocked(2) && !isLocked(3) && !isLocked(4) && !isLocked(5);

  bool get shouldFetchTeamStats =>
      !isLocked(6) || !isLocked(7) || !isLocked(9);

  bool get shouldFetchH2h => !isLocked(8);

  static SoccerReportLockPolicy resolve({
    required bool isGuest,
    required bool hasFullAccess,
    required bool guestFactBlocksUnlocked,
    required VoidCallback onGuestTap,
    required VoidCallback onSubscribeTap,
  }) {
    if (hasFullAccess) {
      return const SoccerReportLockPolicy(
        lockedBlocks: {},
        lockLabel: '',
      );
    }

    if (isGuest) {
      final locked = <int>{2, 3, 4, 5, 6, 7};
      if (!guestFactBlocksUnlocked) {
        locked.addAll(const [8, 9]);
      }
      return SoccerReportLockPolicy(
        lockedBlocks: locked,
        lockLabel: 'Log in to view',
        onTap: onGuestTap,
      );
    }

    return SoccerReportLockPolicy(
      lockedBlocks: const {2, 3, 4, 5, 6, 7},
      lockLabel: 'Premium content',
      onTap: onSubscribeTap,
    );
  }
}
