import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/order_remote_data_source.dart';

// Events
abstract class RetailerOrderEvent extends Equatable {
  const RetailerOrderEvent();
  @override
  List<Object?> get props => [];
}

class FetchShopOrdersRequested extends RetailerOrderEvent {
  const FetchShopOrdersRequested();
}

class UpdateOrderStatusRequested extends RetailerOrderEvent {
  final String orderId;
  final String status;
  const UpdateOrderStatusRequested({required this.orderId, required this.status});
  @override
  List<Object?> get props => [orderId, status];
}

// States
abstract class RetailerOrderState extends Equatable {
  const RetailerOrderState();
  @override
  List<Object?> get props => [];
}

class RetailerOrderInitial extends RetailerOrderState {}

class RetailerOrderLoading extends RetailerOrderState {}

class RetailerOrdersLoaded extends RetailerOrderState {
  final List<ShopOrderModel> orders;
  const RetailerOrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class RetailerOrderUpdating extends RetailerOrderState {
  final List<ShopOrderModel> orders;
  final String orderId;
  const RetailerOrderUpdating({required this.orders, required this.orderId});
  @override
  List<Object?> get props => [orders, orderId];
}

class RetailerOrderUpdated extends RetailerOrderState {
  final List<ShopOrderModel> orders;
  const RetailerOrderUpdated(this.orders);
  @override
  List<Object?> get props => [orders];
}

class RetailerOrderError extends RetailerOrderState {
  final String message;
  const RetailerOrderError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class RetailerOrderBloc extends Bloc<RetailerOrderEvent, RetailerOrderState> {
  final OrderRemoteDataSource _dataSource;

  RetailerOrderBloc(this._dataSource) : super(RetailerOrderInitial()) {
    on<FetchShopOrdersRequested>(_onFetch);
    on<UpdateOrderStatusRequested>(_onUpdateStatus);
  }

  Future<void> _onFetch(FetchShopOrdersRequested event, Emitter<RetailerOrderState> emit) async {
    emit(RetailerOrderLoading());
    try {
      final orders = await _dataSource.getShopOrders();
      emit(RetailerOrdersLoaded(orders));
    } catch (e) {
      final msg = e is DioException
          ? (e.response?.data?['message'] ?? e.message ?? 'Failed to load orders')
          : e.toString();
      emit(RetailerOrderError(msg));
    }
  }

  Future<void> _onUpdateStatus(UpdateOrderStatusRequested event, Emitter<RetailerOrderState> emit) async {
    final currentOrders = state is RetailerOrdersLoaded
        ? (state as RetailerOrdersLoaded).orders
        : <ShopOrderModel>[];

    emit(RetailerOrderUpdating(orders: currentOrders, orderId: event.orderId));
    try {
      await _dataSource.updateOrderStatus(event.orderId, event.status);
      emit(RetailerOrderUpdated(currentOrders));
    } catch (e) {
      final msg = e is DioException
          ? (e.response?.data?['message'] ?? e.message ?? 'Failed to update order')
          : e.toString();
      emit(RetailerOrderError(msg));
    }
  }
}
