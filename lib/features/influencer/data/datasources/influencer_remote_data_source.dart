import '../../../../core/network/api_client.dart';
import '../models/influencer_profile_model.dart';
import '../models/influencer_campaign_model.dart';

abstract interface class InfluencerRemoteDataSource {
  Future<InfluencerProfileModel> getProfile();
  Future<InfluencerProfileModel> updateProfile(Map<String, dynamic> data);
  Future<List<InfluencerCampaignModel>> getEligibleCampaigns({int page = 1, int limit = 20, String? industry});
  Future<List<InfluencerBidModel>> getMyBids({int page = 1, int limit = 20});
  Future<InfluencerBidModel> submitBid({
    required String campaignId,
    required Map<String, dynamic> data,
  });
  Future<Map<String, dynamic>> getInfluencerAnalytics();
}

class InfluencerRemoteDataSourceImpl implements InfluencerRemoteDataSource {
  final ApiClient apiClient;

  InfluencerRemoteDataSourceImpl(this.apiClient);

  @override
  Future<InfluencerProfileModel> getProfile() async {
    final response = await apiClient.get('/influencer/profile');
    return InfluencerProfileModel.fromJson(response.data);
  }

  @override
  Future<InfluencerProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put('/influencer/profile', data: data);
    return InfluencerProfileModel.fromJson(response.data);
  }

  @override
  Future<List<InfluencerCampaignModel>> getEligibleCampaigns({int page = 1, int limit = 20, String? industry}) async {
    final queryParams = {
      'page': page, 
      'limit': limit,
      if (industry != null && industry.isNotEmpty && industry != 'All Campaigns') 'industry': industry,
    };
    final response = await apiClient.get('/influencer/campaigns', queryParameters: queryParams);
    
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => InfluencerCampaignModel.fromJson(json)).toList();
  }

  @override
  Future<List<InfluencerBidModel>> getMyBids({int page = 1, int limit = 20}) async {
    final response = await apiClient.get('/influencer/bids', queryParameters: {'page': page, 'limit': limit});
    final List<dynamic> list = response.data['data'] ?? response.data;
    return list.map((j) => InfluencerBidModel.fromJson(j)).toList();
  }

  @override
  Future<InfluencerBidModel> submitBid({
    required String campaignId,
    required Map<String, dynamic> data,
  }) async {
    final response = await apiClient.post(
      '/influencer/campaigns/$campaignId/bids',
      data: data,
    );
    return InfluencerBidModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> getInfluencerAnalytics() async {
    final response = await apiClient.get('/analytics/influencer');
    return response.data;
  }
}
