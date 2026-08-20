import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String? type;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, message, isRead, type, createdAt];
}
