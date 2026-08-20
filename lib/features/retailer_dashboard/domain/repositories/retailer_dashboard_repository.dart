import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../shop/domain/entities/shop_entity.dart';

abstract interface class RetailerDashboardRepository {
  Future<Either<Failure, ShopEntity>> getMyShop();
  Future<Either<Failure, ShopEntity>> createShop(Map<String, dynamic> data);
  Future<Either<Failure, ShopEntity>> updateShop(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> getShopAnalytics();
}
