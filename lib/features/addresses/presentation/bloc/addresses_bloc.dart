import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/addresses_use_cases.dart';
import 'addresses_event.dart';
import 'addresses_state.dart';

class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  final GetAddressesUseCase _getAddresses;
  final CreateAddressUseCase _createAddress;
  final UpdateAddressUseCase _updateAddress;
  final DeleteAddressUseCase _deleteAddress;

  AddressesBloc({
    required GetAddressesUseCase getAddresses,
    required CreateAddressUseCase createAddress,
    required UpdateAddressUseCase updateAddress,
    required DeleteAddressUseCase deleteAddress,
  })  : _getAddresses = getAddresses,
        _createAddress = createAddress,
        _updateAddress = updateAddress,
        _deleteAddress = deleteAddress,
        super(const AddressesInitial()) {
    on<GetAddressesRequested>(_onGetAddresses);
    on<CreateAddressRequested>(_onCreateAddress);
    on<UpdateAddressRequested>(_onUpdateAddress);
    on<DeleteAddressRequested>(_onDeleteAddress);
  }

  AddressesLoaded get _current => state is AddressesLoaded ? state as AddressesLoaded : const AddressesLoaded();

  Future<void> _onGetAddresses(GetAddressesRequested event, Emitter<AddressesState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _getAddresses.execute();
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (addresses) => emit(_current.copyWith(isLoading: false, addresses: addresses)),
    );
  }

  Future<void> _onCreateAddress(CreateAddressRequested event, Emitter<AddressesState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _createAddress.execute(event.data);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (_) {
        emit(_current.copyWith(isLoading: false, isSuccess: true));
        add(const GetAddressesRequested());
      },
    );
  }

  Future<void> _onUpdateAddress(UpdateAddressRequested event, Emitter<AddressesState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _updateAddress.execute(event.addressId, event.data);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (_) {
        emit(_current.copyWith(isLoading: false, isSuccess: true));
        add(const GetAddressesRequested());
      },
    );
  }

  Future<void> _onDeleteAddress(DeleteAddressRequested event, Emitter<AddressesState> emit) async {
    emit(_current.copyWith(isLoading: true));
    final result = await _deleteAddress.execute(event.addressId);
    result.fold(
      (f) => emit(_current.copyWith(isLoading: false, failure: f)),
      (_) {
        emit(_current.copyWith(isLoading: false, isSuccess: true));
        add(const GetAddressesRequested());
      },
    );
  }
}
