import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/product_entity.dart';

abstract interface class ProductRepository {
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
  });

  Future<Either<Failure, List<ProductEntity>>> getTrendingProducts(int limit);

  Future<Either<Failure, ProductEntity>> getProductDetail(String id);

  Future<Either<Failure, List<ProductEntity>>> getPriceComparison(String id, {double? lat, double? lng});
}
