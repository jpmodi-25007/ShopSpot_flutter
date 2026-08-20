import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    String? query,
    double? lat,
    double? lng,
    double? radiusKm,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int? page,
    int? limit,
  }) async {
    try {
      final models = await remoteDataSource.searchProducts(
        query: query,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sort: sort,
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
  Future<Either<Failure, List<ProductEntity>>> getTrendingProducts(int limit) async {
    try {
      final models = await remoteDataSource.getTrendingProducts(limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductDetail(String id) async {
    try {
      final model = await remoteDataSource.getProductDetail(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getPriceComparison(String id, {double? lat, double? lng}) async {
    try {
      final models = await remoteDataSource.getPriceComparison(id, lat: lat, lng: lng);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
