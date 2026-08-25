class NotificationPayload {
  final String? notificationId;
  final String? notificationType;
  final String? entityType;
  final String? entityId;
  final String? actionType;
  final String? route;
  final Map<String, dynamic> rawData;

  NotificationPayload({
    this.notificationId,
    this.notificationType,
    this.entityType,
    this.entityId,
    this.actionType,
    this.route,
    this.rawData = const {},
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      notificationId: map['notificationId']?.toString(),
      notificationType: map['notificationType']?.toString() ?? map['type']?.toString(),
      entityType: map['entityType']?.toString(),
      entityId: map['entityId']?.toString(),
      actionType: map['actionType']?.toString(),
      route: map['route']?.toString(),
      rawData: map,
    );
  }

  bool get hasRoute => route != null && route!.isNotEmpty;
  
  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'notificationType': notificationType,
      'entityType': entityType,
      'entityId': entityId,
      'actionType': actionType,
      'route': route,
    };
  }

  @override
  String toString() {
    return 'NotificationPayload(type: $notificationType, entityId: $entityId, route: $route)';
  }
}
