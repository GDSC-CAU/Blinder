import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyst {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent({
    required String eventName,
    required Map<String, dynamic> data,
  }) async {
    await analytics.logEvent(
      name: eventName,
      parameters: data,
    );
  }

  FirebaseAnalyst();
}
