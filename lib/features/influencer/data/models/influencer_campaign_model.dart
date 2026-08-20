import '../../domain/entities/influencer_campaign_entity.dart';
import '../../domain/entities/influencer_bid_entity.dart';

class InfluencerCampaignModel {
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

  InfluencerCampaignModel({
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

  factory InfluencerCampaignModel.fromJson(Map<String, dynamic> json) {
    return InfluencerCampaignModel(
      id: json['id'],
      shopkeeperId: json['shopkeeperId'],
      shopId: json['shopId'],
      productId: json['productId'],
      title: json['title'],
      description: json['description'],
      platforms: List<String>.from(json['platforms'] ?? []),
      contentTypes: List<String>.from(json['contentTypes'] ?? []),
      creatorCount: json['creatorCount'] ?? 1,
      budgetType: json['budgetType'] ?? 'PER_CREATOR',
      budgetMin: double.tryParse(json['budgetMin']?.toString() ?? '0') ?? 0.0,
      budgetMax: double.tryParse(json['budgetMax']?.toString() ?? '0') ?? 0.0,
      city: json['city'],
      targetCategories: List<String>.from(json['targetCategories'] ?? []),
      applicationDeadline: json['applicationDeadline'] != null
          ? DateTime.parse(json['applicationDeadline'])
          : null,
      status: json['status'] ?? 'DRAFT',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  InfluencerCampaignEntity toEntity() => InfluencerCampaignEntity(
        id: id,
        shopkeeperId: shopkeeperId,
        shopId: shopId,
        productId: productId,
        title: title,
        description: description,
        platforms: platforms,
        contentTypes: contentTypes,
        creatorCount: creatorCount,
        budgetType: budgetType,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        city: city,
        targetCategories: targetCategories,
        applicationDeadline: applicationDeadline,
        status: status,
        createdAt: createdAt,
      );
}

class InfluencerBidModel {
  final String id;
  final String campaignId;
  final String influencerId;
  final double proposedAmount;
  final DateTime availableDate;
  final DateTime deliveryDate;
  final String? proposal;
  final String status;
  final bool isShortlisted;
  final DateTime createdAt;

  InfluencerBidModel({
    required this.id,
    required this.campaignId,
    required this.influencerId,
    required this.proposedAmount,
    required this.availableDate,
    required this.deliveryDate,
    this.proposal,
    required this.status,
    required this.isShortlisted,
    required this.createdAt,
  });

  factory InfluencerBidModel.fromJson(Map<String, dynamic> json) {
    return InfluencerBidModel(
      id: json['id'],
      campaignId: json['campaignId'],
      influencerId: json['influencerId'],
      proposedAmount: double.tryParse(json['proposedAmount']?.toString() ?? '0') ?? 0.0,
      availableDate: DateTime.parse(json['availableDate']),
      deliveryDate: DateTime.parse(json['deliveryDate']),
      proposal: json['proposal'],
      status: json['status'] ?? 'SUBMITTED',
      isShortlisted: json['isShortlisted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  InfluencerBidEntity toEntity() => InfluencerBidEntity(
        id: id,
        campaignId: campaignId,
        influencerId: influencerId,
        proposedAmount: proposedAmount,
        availableDate: availableDate,
        deliveryDate: deliveryDate,
        proposal: proposal,
        status: status,
        isShortlisted: isShortlisted,
        createdAt: createdAt,
      );
}
