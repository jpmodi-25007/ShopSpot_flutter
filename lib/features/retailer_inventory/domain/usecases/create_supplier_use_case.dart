import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/retailer_inventory_repository.dart';

class CreateSupplierUseCase {
  final RetailerInventoryRepository repository;

  CreateSupplierUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> execute(Map<String, dynamic> data) async {
    return await repository.createSupplier(data);
  }
}
