import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final bool isActive;
  final String? shopId;
  final String? shopName;

  const EventEntity({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.location,
    this.isActive = true,
    this.shopId,
    this.shopName,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        startDate,
        endDate,
        location,
        isActive,
        shopId,
        shopName,
      ];
}
