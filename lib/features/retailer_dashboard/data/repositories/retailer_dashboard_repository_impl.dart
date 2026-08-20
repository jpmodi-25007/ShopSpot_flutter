import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../shop/domain/entities/shop_entity.dart';
import '../../domain/repositories/retailer_dashboard_repository.dart';
import '../datasources/retailer_dashboard_remote_data_source.dart';

class RetailerDashboardRepositoryImpl implements RetailerDashboardRepository {
  final RetailerDashboardRemoteDataSource remoteDataSource;

  RetailerDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ShopEntity>> getMyShop() async {
    try {
      final model = await remoteDataSource.getMyShop();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopEntity>> createShop(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.createShop(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopEntity>> updateShop(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.updateShop(data);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getShopAnalytics() async {
    try {
      final data = await remoteDataSource.getShopAnalytics();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
