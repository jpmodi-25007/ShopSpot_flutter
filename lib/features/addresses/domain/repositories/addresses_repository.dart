import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';

abstract class AddressesRepository {
  Future<Either<Failure, List<dynamic>>> getAddresses();
  Future<Either<Failure, void>> createAddress(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateAddress(String addressId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteAddress(String addressId);
}
