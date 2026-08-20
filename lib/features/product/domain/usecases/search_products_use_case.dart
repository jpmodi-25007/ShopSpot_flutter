import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute({
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
    return await repository.searchProducts(
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
  }
}
