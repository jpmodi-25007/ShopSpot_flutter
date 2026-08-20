import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../shop/domain/entities/shop_entity.dart';
import '../repositories/retailer_dashboard_repository.dart';

class GetMyShopUseCase {
  final RetailerDashboardRepository repository;
  GetMyShopUseCase(this.repository);
  Future<Either<Failure, ShopEntity>> execute() => repository.getMyShop();
}

class CreateShopUseCase {
  final RetailerDashboardRepository repository;
  CreateShopUseCase(this.repository);
  Future<Either<Failure, ShopEntity>> execute(Map<String, dynamic> data) => repository.createShop(data);
}

class UpdateShopUseCase {
  final RetailerDashboardRepository repository;
  UpdateShopUseCase(this.repository);
  Future<Either<Failure, ShopEntity>> execute(Map<String, dynamic> data) => repository.updateShop(data);
}

class GetShopAnalyticsUseCase {
  final RetailerDashboardRepository repository;
  GetShopAnalyticsUseCase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> execute() => repository.getShopAnalytics();
}
