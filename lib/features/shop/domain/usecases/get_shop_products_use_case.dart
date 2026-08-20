import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../repositories/shop_repository.dart';

class GetShopProductsUseCase {
  final ShopRepository repository;

  GetShopProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute({
    required String id,
    int page = 1,
    int limit = 20,
  }) async {
    return await repository.getShopProducts(id: id, page: page, limit: limit);
  }
}
