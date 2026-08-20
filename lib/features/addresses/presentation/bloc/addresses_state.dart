import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';

abstract class AddressesState extends Equatable {
  const AddressesState();

  @override
  List<Object?> get props => [];
}

class AddressesInitial extends AddressesState {
  const AddressesInitial();
}

class AddressesLoaded extends AddressesState {
  final bool isLoading;
  final bool isSuccess;
  final Failure? failure;
  final List<dynamic>? addresses;

  const AddressesLoaded({
    this.isLoading = false,
    this.isSuccess = false,
    this.failure,
    this.addresses,
  });

  AddressesLoaded copyWith({
    bool? isLoading,
    bool? isSuccess,
    Failure? failure,
    List<dynamic>? addresses,
  }) {
    return AddressesLoaded(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      failure: failure,
      addresses: addresses ?? this.addresses,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, failure, addresses];
}
