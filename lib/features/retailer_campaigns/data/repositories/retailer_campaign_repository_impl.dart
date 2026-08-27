import '../../domain/repositories/retailer_campaign_repository.dart';

import '../../../influencer/domain/entities/influencer_campaign_entity.dart';
import '../../../influencer/domain/entities/influencer_bid_entity.dart';
import '../datasources/retailer_campaign_remote_data_source.dart';

class RetailerCampaignRepositoryImpl implements RetailerCampaignRepository {
  final RetailerCampaignRemoteDataSource remoteDataSource;

  RetailerCampaignRepositoryImpl({required this.remoteDataSource});

  @override
  Future<InfluencerCampaignEntity> createCampaign(CreateCampaignParams params) async {
    final model = await remoteDataSource.createCampaign(params.toJson());
    return model.toEntity();
  }

  @override
  Future<List<InfluencerCampaignEntity>> getMyCampaigns({int page = 1, int limit = 20}) async {
    final models = await remoteDataSource.getMyCampaigns(page: page, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<InfluencerBidEntity>> getCampaignBids(String campaignId, {int page = 1, int limit = 20}) async {
    final models = await remoteDataSource.getCampaignBids(campaignId, page: page, limit: limit);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<InfluencerBidEntity> acceptBid(String bidId) async {
    final model = await remoteDataSource.acceptBid(bidId);
    return model.toEntity();
  }

  @override
  Future<InfluencerBidEntity> counterBid(String bidId, double amount, {String? message}) async {
    final model = await remoteDataSource.counterBid(bidId, amount, message: message);
    return model.toEntity();
  }

  @override
  Future<void> updateCampaign(String campaignId, Map<String, dynamic> data) async {
    await remoteDataSource.updateCampaign(campaignId, data);
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    await remoteDataSource.deleteCampaign(campaignId);
  }
}
