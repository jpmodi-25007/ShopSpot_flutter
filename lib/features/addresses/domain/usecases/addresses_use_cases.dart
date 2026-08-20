import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/addresses_repository.dart';

class GetAddressesUseCase {
  final AddressesRepository repository;
  GetAddressesUseCase(this.repository);
  Future<Either<Failure, List<dynamic>>> execute() => repository.getAddresses();
}

class CreateAddressUseCase {
  final AddressesRepository repository;
  CreateAddressUseCase(this.repository);
  Future<Either<Failure, void>> execute(Map<String, dynamic> data) => repository.createAddress(data);
}

class UpdateAddressUseCase {
  final AddressesRepository repository;
  UpdateAddressUseCase(this.repository);
  Future<Either<Failure, void>> execute(String addressId, Map<String, dynamic> data) => repository.updateAddress(addressId, data);
}

class DeleteAddressUseCase {
  final AddressesRepository repository;
  DeleteAddressUseCase(this.repository);
  Future<Either<Failure, void>> execute(String addressId) => repository.deleteAddress(addressId);
}
