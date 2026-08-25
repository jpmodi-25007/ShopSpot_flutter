import '../../data/models/promotion_banner_model.dart';

abstract class PromotionState {
  const PromotionState();
}

class PromotionInitial extends PromotionState {
  const PromotionInitial();
}

class PromotionLoading extends PromotionState {
  const PromotionLoading();
}

class PromotionsLoaded extends PromotionState {
  final List<PromotionBanner> banners;
  const PromotionsLoaded({required this.banners});
}

class PromotionError extends PromotionState {
  final String message;
  const PromotionError({required this.message});
}
