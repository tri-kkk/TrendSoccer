import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/subscription_state.dart';

/// Global provider that holds the current user's subscription state.
///
/// Defaults to [SubscriptionType.free]. Update via:
/// ```dart
/// ref.read(subscriptionProvider.notifier).activate(
///   SubscriptionType.premium,
///   expiryDate: DateTime(2026, 12, 31),
/// );
/// ```
final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() =>
      const SubscriptionState(type: SubscriptionType.free);

  void activate(
    SubscriptionType type, {
    DateTime? expiryDate,
    Duration? remainingTime,
  }) {
    state = SubscriptionState(
      type: type,
      expiryDate: expiryDate,
      remainingTime: remainingTime,
    );
  }

  void reset() {
    state = const SubscriptionState(type: SubscriptionType.free);
  }
}
