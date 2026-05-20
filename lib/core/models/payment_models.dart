DateTime? _parseDateTime(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

class PaymentInitResponse {
  const PaymentInitResponse({
    required this.paymentUrl,
    required this.ordNo,
  });

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitResponse(
      paymentUrl: json['paymentUrl'] as String? ??
          json['payment_url'] as String? ??
          '',
      ordNo: json['ordNo'] as String? ?? json['ord_no'] as String? ?? '',
    );
  }

  final String paymentUrl;
  final String ordNo;
}

class SubscriptionStatus {
  const SubscriptionStatus({
    required this.status,
    this.expiresAt,
    this.plan,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      status: json['status'] as String? ?? '',
      expiresAt: _parseDateTime(json['expiresAt'] ?? json['expires_at']),
      plan: json['plan'] as String?,
    );
  }

  final String status;
  final DateTime? expiresAt;
  final String? plan;

  bool get isActive {
    if (status != 'active') return false;
    final expiresAt = this.expiresAt;
    if (expiresAt == null) return true;
    return expiresAt.toUtc().isAfter(DateTime.now().toUtc());
  }
}
