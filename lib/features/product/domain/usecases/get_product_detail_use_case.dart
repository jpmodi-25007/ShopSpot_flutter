import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductDetailUseCase {
  final ProductRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> execute(String id) async {
    return await repository.getProductDetail(id);
  }
}
