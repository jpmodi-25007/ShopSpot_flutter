import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/retailer_inventory_repository.dart';

class GetStockHistoryUseCase {
  final RetailerInventoryRepository repository;

  GetStockHistoryUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> execute() async {
    return await repository.getStockHistory();
  }
}
