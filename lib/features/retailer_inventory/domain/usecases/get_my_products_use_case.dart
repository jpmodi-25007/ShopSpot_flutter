import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../repositories/retailer_inventory_repository.dart';

class GetMyProductsUseCase {
  final RetailerInventoryRepository repository;

  GetMyProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute({
    String? query,
    String? categoryId,
    String? stockStatus,
    int? page,
    int? limit,
  }) async {
    return await repository.getMyProducts(
      query: query,
      categoryId: categoryId,
      stockStatus: stockStatus,
      page: page,
      limit: limit,
    );
  }
}
