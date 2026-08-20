import '../../../influencer/domain/entities/influencer_campaign_entity.dart';
import '../../../influencer/domain/entities/influencer_bid_entity.dart';

class CreateCampaignParams {
  final String title;
  final String description;
  final List<String> platforms;
  final List<String> contentTypes;
  final String budgetType;
  final double budgetMin;
  final double budgetMax;
  final String? productId;

  CreateCampaignParams({
    required this.title,
    required this.description,
    required this.platforms,
    required this.contentTypes,
    required this.budgetType,
    required this.budgetMin,
    required this.budgetMax,
    this.productId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'platforms': platforms,
      'contentTypes': contentTypes,
      'budgetType': budgetType,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      if (productId != null) 'productId': productId,
    };
  }
}

abstract class RetailerCampaignRepository {
  Future<InfluencerCampaignEntity> createCampaign(CreateCampaignParams params);
  Future<List<InfluencerCampaignEntity>> getMyCampaigns({int page = 1, int limit = 20});
  Future<List<InfluencerBidEntity>> getCampaignBids(String campaignId, {int page = 1, int limit = 20});
  Future<InfluencerBidEntity> acceptBid(String bidId);
}
