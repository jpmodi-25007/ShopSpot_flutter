import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetMyOrdersUseCase {
  final OrderRepository repository;

  GetMyOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> execute() async {
    return await repository.getMyOrders();
  }
}
