/// Subscription tier of the current user.
enum SubscriptionType {
  /// No active subscription — limited features.
  free,

  /// Time-limited trial with full access.
  trial,

  /// Paid subscription with full access.
  premium,
}

/// Immutable snapshot of the current user's subscription.
///
/// ```dart
/// const free = SubscriptionState(type: SubscriptionType.free);
///
/// final trial = SubscriptionState(
///   type: SubscriptionType.trial,
///   remainingTime: Duration(hours: 48),
/// );
///
/// final premium = SubscriptionState(
///   type: SubscriptionType.premium,
///   expiryDate: DateTime(2026, 12, 31),
/// );
/// ```
class SubscriptionState {
  const SubscriptionState({
    required this.type,
    this.expiryDate,
    this.remainingTime,
  });

  /// Current subscription tier.
  final SubscriptionType type;

  /// When the premium subscription expires. Null for [SubscriptionType.free]
  /// and [SubscriptionType.trial].
  final DateTime? expiryDate;

  /// Time left in the trial period. Null for [SubscriptionType.free]
  /// and [SubscriptionType.premium].
  final Duration? remainingTime;

  /// Returns a copy with the given fields replaced.
  SubscriptionState copyWith({
    SubscriptionType? type,
    DateTime? expiryDate,
    Duration? remainingTime,
  }) {
    return SubscriptionState(
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionState &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          expiryDate == other.expiryDate &&
          remainingTime == other.remainingTime;

  @override
  int get hashCode => Object.hash(type, expiryDate, remainingTime);

  @override
  String toString() =>
      'SubscriptionState(type: $type, expiryDate: $expiryDate, remainingTime: $remainingTime)';
}
