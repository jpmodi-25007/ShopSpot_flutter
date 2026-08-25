import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    required super.startDate,
    required super.endDate,
    super.location,
    super.isActive = true,
    super.shopId,
    super.shopName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 1)),
      location: json['location']?.toString(),
      isActive: json['isActive'] ?? true,
      shopId: json['shopId']?.toString(),
      shopName: json['shop'] != null ? json['shop']['name']?.toString() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'isActive': isActive,
      'shopId': shopId,
    };
  }

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      startDate: startDate,
      endDate: endDate,
      location: location,
      isActive: isActive,
      shopId: shopId,
      shopName: shopName,
    );
  }
}
