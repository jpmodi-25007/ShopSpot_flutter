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
  final DateTime? publishByDate;
  final String status;
  final DateTime createdAt;
  
  final String? shopName;
  final String? shopLogoUrl;
  final String? shopCoverUrl;
  final String? productName;
  final String? productImageUrl;

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
    this.publishByDate,
    required this.status,
    required this.createdAt,
    this.shopName,
    this.shopLogoUrl,
    this.shopCoverUrl,
    this.productName,
    this.productImageUrl,
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
      publishByDate: json['publishByDate'] != null
          ? DateTime.parse(json['publishByDate'])
          : null,
      status: json['status'] ?? 'DRAFT',
      createdAt: DateTime.parse(json['createdAt']),
      shopName: json['shop']?['name'],
      shopLogoUrl: json['shop']?['logoUrl'],
      shopCoverUrl: json['shop']?['coverImageUrl'],
      productName: json['product']?['name'],
      productImageUrl: json['imageUrl'] ?? json['coverImage'] ?? json['coverImageUrl'] ?? _parseProductImage(json['product']),
    );
  }

  static String? _parseProductImage(Map<String, dynamic>? productJson) {
    if (productJson == null) return null;
    if (productJson['imageUrl'] != null) return productJson['imageUrl'];
    
    if (productJson['mediaAssets'] != null && productJson['mediaAssets'] is List && (productJson['mediaAssets'] as List).isNotEmpty) {
      final media = (productJson['mediaAssets'] as List).first;
      if (media is Map && media['secureUrl'] != null) {
        return media['secureUrl'].toString();
      }
    }
    
    if (productJson['images'] != null && productJson['images'] is List && (productJson['images'] as List).isNotEmpty) {
      return productJson['images'][0].toString();
    }
    return null;
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
        publishByDate: publishByDate,
        status: status,
        createdAt: createdAt,
        shopName: shopName,
        shopLogoUrl: shopLogoUrl,
        shopCoverUrl: shopCoverUrl,
        productName: productName,
        productImageUrl: productImageUrl,
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
  
  final String? influencerName;
  final String? influencerAvatar;
  final String? influencerInstagram;
  final String? influencerBio;
  final int? influencerFollowers;
  final double? influencerEngagement;
  final String? influencerNiche;

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
    this.influencerName,
    this.influencerAvatar,
    this.influencerInstagram,
    this.influencerBio,
    this.influencerFollowers,
    this.influencerEngagement,
    this.influencerNiche,
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
      influencerName: json['influencer']?['name'],
      influencerAvatar: json['influencer']?['profileImage'] ?? json['influencer']?['profileImageUrl'],
      influencerInstagram: json['influencer']?['instagramHandle'],
      influencerBio: json['influencer']?['bio'],
      influencerFollowers: json['influencer']?['followersCount'] != null ? int.tryParse(json['influencer']!['followersCount'].toString()) : null,
      influencerEngagement: json['influencer']?['engagementRate'] != null ? double.tryParse(json['influencer']!['engagementRate'].toString()) : null,
      influencerNiche: json['influencer']?['niche'],
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
        influencerName: influencerName,
        influencerAvatar: influencerAvatar,
        influencerInstagram: influencerInstagram,
        influencerBio: influencerBio,
        influencerFollowers: influencerFollowers,
        influencerEngagement: influencerEngagement,
        influencerNiche: influencerNiche,
      );
}
