import 'notification_payload.dart';

class PendingNotificationService {
  static final PendingNotificationService _instance = PendingNotificationService._internal();

  factory PendingNotificationService() {
    return _instance;
  }

  PendingNotificationService._internal();

  NotificationPayload? _pendingPayload;

  void storePendingNotification(NotificationPayload payload) {
    _pendingPayload = payload;
  }

  NotificationPayload? consumePendingNotification() {
    final payload = _pendingPayload;
    _pendingPayload = null;
    return payload;
  }

  bool get hasPendingNotification => _pendingPayload != null;
}
