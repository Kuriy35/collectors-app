import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: _analytics,
  );

  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logPasswordReset() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'password_reset_requested',
      parameters: {'screen': 'forgot_password'},
    );
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}
