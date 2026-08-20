import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import 'package:dio/dio.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrderEntity>>> getMyOrders() async {
    try {
      final models = await remoteDataSource.getMyOrders();
      return Right(models);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure(
          e.response?.data?['message'] ?? e.message ?? 'Server error occurred'
        ));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
