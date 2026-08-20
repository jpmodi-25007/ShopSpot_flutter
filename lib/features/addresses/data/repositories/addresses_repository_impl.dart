import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/addresses_repository.dart';
import '../datasources/addresses_remote_data_source.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  final AddressesRemoteDataSource remoteDataSource;

  AddressesRepositoryImpl({required this.remoteDataSource});

  Failure _handleError(dynamic e) {
    if (e is DioException) {
      return ServerFailure(e.response?.data?['message'] ?? e.message ?? 'Server error occurred');
    }
    return ServerFailure(e.toString());
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAddresses() async {
    try {
      final addresses = await remoteDataSource.getAddresses();
      return Right(addresses);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> createAddress(Map<String, dynamic> data) async {
    try {
      await remoteDataSource.createAddress(data);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateAddress(String addressId, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateAddress(addressId, data);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    try {
      await remoteDataSource.deleteAddress(addressId);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }
}
