import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/retailer_inventory_repository.dart';

class DeleteProductUseCase {
  final RetailerInventoryRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> execute(String id) async {
    return await repository.deleteProduct(id);
  }
}
