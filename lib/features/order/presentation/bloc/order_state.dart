import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../../../core/error/failure.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final Failure failure;

  const OrderError(this.failure);

  @override
  List<Object?> get props => [failure];
}
