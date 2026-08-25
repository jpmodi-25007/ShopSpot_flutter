import 'package:mobile_web/features/dashboard/data/models/promotion_banner_model.dart';

abstract class PromotionRepository {
  Future<List<PromotionBanner>> getActivePromotions();
}
