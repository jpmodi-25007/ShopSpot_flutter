import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getMyOrders();
}
