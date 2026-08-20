import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../repositories/retailer_inventory_repository.dart';

class UpdateStockUseCase {
  final RetailerInventoryRepository repository;

  UpdateStockUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> execute(String id, int quantity) async {
    return await repository.updateStock(id: id, quantity: quantity);
  }
}
