import '../../../../core/network/api_client.dart';
import '../../../influencer/data/models/influencer_campaign_model.dart';

abstract class RetailerCampaignRemoteDataSource {
  Future<InfluencerCampaignModel> createCampaign(Map<String, dynamic> data);
  Future<List<InfluencerCampaignModel>> getMyCampaigns({int page = 1, int limit = 20});
  Future<List<InfluencerBidModel>> getCampaignBids(String campaignId, {int page = 1, int limit = 20});
  Future<void> acceptBid(String bidId);
  Future<void> counterBid(String bidId, double amount, {String? message});
  Future<void> updateCampaign(String campaignId, Map<String, dynamic> data);
  Future<void> deleteCampaign(String campaignId);
}

class RetailerCampaignRemoteDataSourceImpl implements RetailerCampaignRemoteDataSource {
  final ApiClient apiClient;

  RetailerCampaignRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<InfluencerCampaignModel> createCampaign(Map<String, dynamic> data) async {
    final response = await apiClient.post('/shopkeeper/influencer-campaigns', data: data);
    return InfluencerCampaignModel.fromJson(response.data);
  }

  @override
  Future<List<InfluencerCampaignModel>> getMyCampaigns({int page = 1, int limit = 20}) async {
    final response = await apiClient.get('/shopkeeper/influencer-campaigns', queryParameters: {'page': page, 'limit': limit});
    final list = response.data as List;
    return list.map((j) => InfluencerCampaignModel.fromJson(j)).toList();
  }

  @override
  Future<List<InfluencerBidModel>> getCampaignBids(String campaignId, {int page = 1, int limit = 20}) async {
    final response = await apiClient.get('/shopkeeper/influencer-campaigns/$campaignId/bids', queryParameters: {'page': page, 'limit': limit});
    final list = response.data as List;
    return list.map((j) => InfluencerBidModel.fromJson(j)).toList();
  }

  @override
  Future<void> acceptBid(String bidId) async {
    await apiClient.post('/shopkeeper/influencer-campaigns/bids/$bidId/accept');
  }

  @override
  Future<void> counterBid(String bidId, double amount, {String? message}) async {
    final data = {
      'counterAmount': amount,
      if (message != null) 'message': message,
    };
    await apiClient.post('/shopkeeper/influencer-campaigns/bids/$bidId/counter', data: data);
  }

  @override
  Future<void> updateCampaign(String campaignId, Map<String, dynamic> data) async {
    await apiClient.patch('/shopkeeper/influencer-campaigns/$campaignId', data: data);
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    await apiClient.delete('/shopkeeper/influencer-campaigns/$campaignId');
  }
}
