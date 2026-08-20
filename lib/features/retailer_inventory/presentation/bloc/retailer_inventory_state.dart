import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';

sealed class RetailerInventoryState extends Equatable {
  const RetailerInventoryState();

  @override
  List<Object?> get props => [];
}

final class RetailerInventoryInitial extends RetailerInventoryState {
  const RetailerInventoryInitial();
}

final class RetailerInventoryLoading extends RetailerInventoryState {
  const RetailerInventoryLoading();
}

final class RetailerInventoryLoaded extends RetailerInventoryState {
  final List<ProductEntity> products;
  final bool hasReachedMax;
  final int currentPage;

  const RetailerInventoryLoaded({
    required this.products,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  RetailerInventoryLoaded copyWith({
    List<ProductEntity>? products,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return RetailerInventoryLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [products, hasReachedMax, currentPage];
}

final class RetailerInventoryActionSuccess extends RetailerInventoryState {
  final String message;

  const RetailerInventoryActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class RetailerInventoryError extends RetailerInventoryState {
  final Failure failure;

  const RetailerInventoryError(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class SuppliersLoaded extends RetailerInventoryState {
  final List<Map<String, dynamic>> suppliers;

  const SuppliersLoaded(this.suppliers);

  @override
  List<Object?> get props => [suppliers];
}

final class PurchaseOrdersLoaded extends RetailerInventoryState {
  final List<Map<String, dynamic>> purchaseOrders;

  const PurchaseOrdersLoaded(this.purchaseOrders);

  @override
  List<Object?> get props => [purchaseOrders];
}

final class StockHistoryLoaded extends RetailerInventoryState {
  final List<Map<String, dynamic>> stockHistory;

  const StockHistoryLoaded(this.stockHistory);

  @override
  List<Object?> get props => [stockHistory];
}
