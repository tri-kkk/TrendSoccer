import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String _launchCountKey = 'app_launch_count';
  static const String _lastReviewRequestKey = 'last_review_request';
  static const String _reviewRequestedKey = 'review_ever_requested';

  static const int _minLaunchCount = 5;
  static const int _daysBetweenRequests = 30;

  final SharedPreferences _prefs;

  ReviewService(this._prefs);

  /// Call on every app launch (in splash or main)
  void recordLaunch() {
    final count = _prefs.getInt(_launchCountKey) ?? 0;
    _prefs.setInt(_launchCountKey, count + 1);
  }

  /// Check conditions and request review if appropriate
  Future<void> requestReviewIfEligible() async {
    final inAppReview = InAppReview.instance;

    if (!await inAppReview.isAvailable()) return;

    final launchCount = _prefs.getInt(_launchCountKey) ?? 0;

    if (launchCount < _minLaunchCount) return;

    final lastRequest = _prefs.getString(_lastReviewRequestKey);
    if (lastRequest != null) {
      final lastDate = DateTime.tryParse(lastRequest);
      if (lastDate != null) {
        final daysSince = DateTime.now().difference(lastDate).inDays;
        if (daysSince < _daysBetweenRequests) return;
      }
    }

    try {
      await inAppReview.requestReview();
      await _prefs.setString(
        _lastReviewRequestKey,
        DateTime.now().toIso8601String(),
      );
      await _prefs.setBool(_reviewRequestedKey, true);
    } on Object {
      // Non-fatal: review request failed
    }
  }
}
