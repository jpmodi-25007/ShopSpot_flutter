import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../../domain/usecases/get_my_orders_use_case.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetMyOrdersUseCase getMyOrdersUseCase;

  OrderBloc({
    required this.getMyOrdersUseCase,
  }) : super(OrderInitial()) {
    on<FetchMyOrders>(_onFetchMyOrders);
  }

  Future<void> _onFetchMyOrders(FetchMyOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    final result = await getMyOrdersUseCase.execute();
    result.fold(
      (failure) => emit(OrderError(failure)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }
}
