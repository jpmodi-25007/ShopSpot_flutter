import '../../../../core/network/api_client.dart';
import '../models/influencer_profile_model.dart';
import '../models/influencer_campaign_model.dart';

abstract interface class InfluencerRemoteDataSource {
  Future<InfluencerProfileModel> getProfile();
  Future<InfluencerProfileModel> updateProfile(Map<String, dynamic> data);
  Future<List<InfluencerCampaignModel>> getEligibleCampaigns({int page = 1, int limit = 20, String? industry, String? search});
  Future<List<InfluencerBidModel>> getMyBids({int page = 1, int limit = 20});
  Future<InfluencerBidModel> submitBid({
    required String campaignId,
    required Map<String, dynamic> data,
  });
  Future<void> withdrawBid(String bidId);
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
  Future<List<InfluencerCampaignModel>> getEligibleCampaigns({int page = 1, int limit = 20, String? industry, String? search}) async {
    final queryParams = {
      'page': page, 
      'limit': limit,
      if (industry != null && industry.isNotEmpty && industry != 'All Campaigns') 'industry': industry,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await apiClient.get('/influencer/campaigns', queryParameters: queryParams);
    
    final responseData = response.data;
    final List<dynamic> data = responseData is List ? responseData : (responseData['data'] ?? []);
    return data.map((json) => InfluencerCampaignModel.fromJson(json)).toList();
  }

  @override
  Future<List<InfluencerBidModel>> getMyBids({int page = 1, int limit = 20}) async {
    final response = await apiClient.get('/influencer/bids', queryParameters: {'page': page, 'limit': limit});
    final responseData = response.data;
    final List<dynamic> list = responseData is List ? responseData : (responseData['data'] ?? []);
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

  @override
  Future<void> withdrawBid(String bidId) async {
    await apiClient.delete('/influencer/bids/$bidId');
  }
}
