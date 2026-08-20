import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/retailer_inventory_repository.dart';

class GetPurchaseOrdersUseCase {
  final RetailerInventoryRepository repository;

  GetPurchaseOrdersUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> execute() async {
    return await repository.getPurchaseOrders();
  }
}
