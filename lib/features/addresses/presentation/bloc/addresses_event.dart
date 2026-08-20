import 'package:equatable/equatable.dart';

abstract class AddressesEvent extends Equatable {
  const AddressesEvent();

  @override
  List<Object?> get props => [];
}

class GetAddressesRequested extends AddressesEvent {
  const GetAddressesRequested();
}

class CreateAddressRequested extends AddressesEvent {
  final Map<String, dynamic> data;
  const CreateAddressRequested(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateAddressRequested extends AddressesEvent {
  final String addressId;
  final Map<String, dynamic> data;
  const UpdateAddressRequested(this.addressId, this.data);

  @override
  List<Object?> get props => [addressId, data];
}

class DeleteAddressRequested extends AddressesEvent {
  final String addressId;
  const DeleteAddressRequested(this.addressId);

  @override
  List<Object?> get props => [addressId];
}
