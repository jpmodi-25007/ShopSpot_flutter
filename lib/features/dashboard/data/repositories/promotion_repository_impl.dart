import '../../../../core/network/api_client.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../models/promotion_banner_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final ApiClient apiClient;

  PromotionRepositoryImpl({required this.apiClient});

  @override
  Future<List<PromotionBanner>> getActivePromotions() async {
    try {
      final response = await apiClient.get('/promotions');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PromotionBanner.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
