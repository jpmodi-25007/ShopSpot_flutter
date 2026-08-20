import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_data_source.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;

  ShopRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ShopEntity>> getPublicShop(String id) async {
    try {
      final model = await remoteDataSource.getPublicShop(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getShopProducts({
    required String id,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await remoteDataSource.getShopProducts(
        id: id,
        page: page,
        limit: limit,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShopEntity>>> getNearbyShops({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    String? categoryId,
  }) async {
    try {
      final models = await remoteDataSource.getNearbyShops(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        categoryId: categoryId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
