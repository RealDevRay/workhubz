import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService();

  Future<void> initialize() async {
    debugPrint(
      '[Notification] Push notifications not configured (no Firebase)',
    );
  }

  Future<String?> getToken() async => null;

  Future<void> requestPermission() async {}

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('[Notification] $title: $body');
  }
}
