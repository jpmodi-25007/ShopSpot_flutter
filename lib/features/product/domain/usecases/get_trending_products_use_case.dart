import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetTrendingProductsUseCase {
  final ProductRepository repository;

  GetTrendingProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute(int limit) async {
    return await repository.getTrendingProducts(limit);
  }
}
