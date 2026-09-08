import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getMyNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String id);
}
