import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetPriceComparisonUseCase {
  final ProductRepository repository;

  GetPriceComparisonUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> execute(String id, {double? lat, double? lng}) async {
    return await repository.getPriceComparison(id, lat: lat, lng: lng);
  }
}
