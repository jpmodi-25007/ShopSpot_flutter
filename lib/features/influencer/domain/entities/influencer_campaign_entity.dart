import 'package:equatable/equatable.dart';

class InfluencerCampaignEntity extends Equatable {
  final String id;
  final String shopkeeperId;
  final String shopId;
  final String? productId;
  final String title;
  final String description;
  final List<String> platforms;
  final List<String> contentTypes;
  final int creatorCount;
  final String budgetType;
  final double budgetMin;
  final double budgetMax;
  final String? city;
  final List<String> targetCategories;
  final DateTime? applicationDeadline;
  final String status;
  final DateTime createdAt;

  const InfluencerCampaignEntity({
    required this.id,
    required this.shopkeeperId,
    required this.shopId,
    this.productId,
    required this.title,
    required this.description,
    required this.platforms,
    required this.contentTypes,
    required this.creatorCount,
    required this.budgetType,
    required this.budgetMin,
    required this.budgetMax,
    this.city,
    required this.targetCategories,
    this.applicationDeadline,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, shopkeeperId, shopId, productId, title, description,
        platforms, contentTypes, creatorCount, budgetType, budgetMin,
        budgetMax, city, targetCategories, applicationDeadline, status, createdAt,
      ];
}
