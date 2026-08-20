import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/saved_repository.dart';
import '../datasources/saved_remote_data_source.dart';

class SavedRepositoryImpl implements SavedRepository {
  final SavedRemoteDataSource remoteDataSource;

  SavedRepositoryImpl({required this.remoteDataSource});

  Failure _handleError(dynamic e) {
    if (e is DioException) {
      return ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Server error occurred');
    }
    return ServerFailure(e.toString());
  }

  @override
  Future<Either<Failure, List<dynamic>>> getSavedProducts() async {
    try {
      final products = await remoteDataSource.getSavedProducts();
      return Right(products);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveProduct(String productId) async {
    try {
      await remoteDataSource.saveProduct(productId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeSavedProduct(String productId) async {
    try {
      await remoteDataSource.removeSavedProduct(productId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getSavedShops() async {
    try {
      final shops = await remoteDataSource.getSavedShops();
      return Right(shops);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveShop(String shopId) async {
    try {
      await remoteDataSource.saveShop(shopId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeSavedShop(String shopId) async {
    try {
      await remoteDataSource.removeSavedShop(shopId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
}
