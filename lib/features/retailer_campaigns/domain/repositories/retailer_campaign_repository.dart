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
  final DateTime? applicationDeadline;
  final DateTime? publishByDate;

  CreateCampaignParams({
    required this.title,
    required this.description,
    required this.platforms,
    required this.contentTypes,
    required this.budgetType,
    required this.budgetMin,
    required this.budgetMax,
    this.productId,
    this.applicationDeadline,
    this.publishByDate,
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
      if (applicationDeadline != null) 'applicationDeadline': applicationDeadline!.toIso8601String(),
      if (publishByDate != null) 'publishByDate': publishByDate!.toIso8601String(),
    };
  }
}

abstract class RetailerCampaignRepository {
  Future<InfluencerCampaignEntity> createCampaign(CreateCampaignParams params);
  Future<List<InfluencerCampaignEntity>> getMyCampaigns({int page = 1, int limit = 20});
  Future<List<InfluencerBidEntity>> getCampaignBids(String campaignId, {int page = 1, int limit = 20});
  Future<InfluencerBidEntity> acceptBid(String bidId);
  Future<InfluencerBidEntity> counterBid(String bidId, double amount, {String? message});
  Future<void> updateCampaign(String campaignId, Map<String, dynamic> data);
  Future<void> deleteCampaign(String campaignId);
}
