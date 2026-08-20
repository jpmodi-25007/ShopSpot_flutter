import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/shop_entity.dart';
import '../../../product/domain/entities/product_entity.dart';

abstract interface class ShopRepository {
  Future<Either<Failure, ShopEntity>> getPublicShop(String id);
  
  Future<Either<Failure, List<ProductEntity>>> getShopProducts({
    required String id,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<ShopEntity>>> getNearbyShops({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    String? categoryId,
  });
  
  // Future<Either<Failure, List<ReviewEntity>>> getShopReviews(...)
  // Future<Either<Failure, List<OfferEntity>>> getShopOffers(...)
}
