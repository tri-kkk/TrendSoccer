import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;

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
