import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.isRead,
    super.type,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'] ?? json['body'] ?? '',
      isRead: json['isRead'] ?? false,
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        title: title,
        message: message,
        isRead: isRead,
        type: type,
        createdAt: createdAt,
      );
}
