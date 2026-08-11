import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

  /// Fired when flutter_secure_storage throws (no token values logged).
  static Future<void> logSecureStorageError({
    required String operation,
    required String where,
  }) async {
    await _analytics.logEvent(
      name: 'secure_storage_error',
      parameters: {
        'operation': operation,
        'where': where,
      },
    );
  }

  /// Fired when the user taps a social login button.
  static Future<void> logLoginAttempt({required String provider}) async {
    await _analytics.logEvent(
      name: 'login_attempt',
      parameters: {'provider': provider},
    );
  }

  /// Fired when a social login flow fails.
  static Future<void> logLoginFailure({
    required String provider,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'login_failure',
      parameters: {
        'provider': provider,
        'reason': reason,
      },
    );
  }

  /// Track sign_up event — call after agree-terms API success.
  static Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
      }

  /// Track purchase event — call after IAP verify API success.
  static Future<void> logPurchase({
    required String basePlanId,
  }) async {
    final isMonthly = basePlanId.contains('monthly');
    await _analytics.logPurchase(
      currency: 'KRW',
      value: isMonthly ? 4900 : 9900,
      items: [
        AnalyticsEventItem(
          itemName: 'premium',
          itemCategory: isMonthly ? 'monthly' : 'quarterly',
          price: isMonthly ? 4900 : 9900,
          currency: 'KRW',
          quantity: 1,
        ),
      ],
    );
      }
}
