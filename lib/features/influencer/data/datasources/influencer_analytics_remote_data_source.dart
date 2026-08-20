import '../../../../core/network/api_client.dart';

class InfluencerAnalyticsRemoteDataSource {
  final ApiClient apiClient;

  InfluencerAnalyticsRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> getAnalytics() async {
    final response = await apiClient.get('/analytics/influencer');
    return response.data['data'];
  }
}
