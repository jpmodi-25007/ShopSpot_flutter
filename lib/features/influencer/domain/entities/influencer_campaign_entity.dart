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
  final DateTime? publishByDate;
  final String status;
  final DateTime createdAt;
  
  final String? shopName;
  final String? shopLogoUrl;
  final String? shopCoverUrl;
  final String? productName;
  final String? productImageUrl;

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
    this.publishByDate,
    required this.status,
    required this.createdAt,
    this.shopName,
    this.shopLogoUrl,
    this.shopCoverUrl,
    this.productName,
    this.productImageUrl,
  });

  bool get isHighBudget => budgetMax >= 10000;

  @override
  List<Object?> get props => [
        id, shopkeeperId, shopId, productId, title, description,
        platforms, contentTypes, creatorCount, budgetType, budgetMin,
        budgetMax, city, targetCategories, applicationDeadline, publishByDate, status, createdAt,
        shopName, shopLogoUrl, shopCoverUrl, productName, productImageUrl,
      ];
}
