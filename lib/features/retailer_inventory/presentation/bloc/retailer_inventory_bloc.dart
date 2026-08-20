import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_products_use_case.dart';
import '../../domain/usecases/create_product_use_case.dart';
import '../../domain/usecases/update_product_use_case.dart';
import '../../domain/usecases/delete_product_use_case.dart';
import '../../domain/usecases/update_stock_use_case.dart';
import '../../domain/usecases/get_suppliers_use_case.dart';
import '../../domain/usecases/create_supplier_use_case.dart';
import '../../domain/usecases/get_purchase_orders_use_case.dart';
import '../../domain/usecases/get_stock_history_use_case.dart';
import 'retailer_inventory_event.dart';
import 'retailer_inventory_state.dart';

class RetailerInventoryBloc extends Bloc<RetailerInventoryEvent, RetailerInventoryState> {
  final GetMyProductsUseCase _getMyProductsUseCase;
  final CreateProductUseCase _createProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;
  final UpdateStockUseCase _updateStockUseCase;
  
  final GetSuppliersUseCase _getSuppliersUseCase;
  final CreateSupplierUseCase _createSupplierUseCase;
  final GetPurchaseOrdersUseCase _getPurchaseOrdersUseCase;
  final GetStockHistoryUseCase _getStockHistoryUseCase;

  RetailerInventoryBloc({
    required GetMyProductsUseCase getMyProductsUseCase,
    required CreateProductUseCase createProductUseCase,
    required UpdateProductUseCase updateProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
    required UpdateStockUseCase updateStockUseCase,
    required GetSuppliersUseCase getSuppliersUseCase,
    required CreateSupplierUseCase createSupplierUseCase,
    required GetPurchaseOrdersUseCase getPurchaseOrdersUseCase,
    required GetStockHistoryUseCase getStockHistoryUseCase,
  })  : _getMyProductsUseCase = getMyProductsUseCase,
        _createProductUseCase = createProductUseCase,
        _updateProductUseCase = updateProductUseCase,
        _deleteProductUseCase = deleteProductUseCase,
        _updateStockUseCase = updateStockUseCase,
        _getSuppliersUseCase = getSuppliersUseCase,
        _createSupplierUseCase = createSupplierUseCase,
        _getPurchaseOrdersUseCase = getPurchaseOrdersUseCase,
        _getStockHistoryUseCase = getStockHistoryUseCase,
        super(const RetailerInventoryInitial()) {
    on<GetMyProductsRequested>(_onGetMyProductsRequested);
    on<CreateProductRequested>(_onCreateProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
    on<DeleteProductRequested>(_onDeleteProductRequested);
    on<UpdateStockRequested>(_onUpdateStockRequested);
    
    on<GetSuppliersRequested>(_onGetSuppliersRequested);
    on<CreateSupplierRequested>(_onCreateSupplierRequested);
    on<GetPurchaseOrdersRequested>(_onGetPurchaseOrdersRequested);
    on<GetStockHistoryRequested>(_onGetStockHistoryRequested);
  }

  Future<void> _onGetMyProductsRequested(GetMyProductsRequested event, Emitter<RetailerInventoryState> emit) async {
    final isLoadMore = (event.page ?? 1) > 1;
    if (!isLoadMore) {
      emit(const RetailerInventoryLoading());
    }
    
    final result = await _getMyProductsUseCase.execute(
      query: event.query,
      categoryId: event.categoryId,
      stockStatus: event.stockStatus,
      page: event.page,
      limit: event.limit,
    );
    result.fold(
      (failure) {
        if (!isLoadMore) emit(RetailerInventoryError(failure));
      },
      (products) {
        if (isLoadMore && state is RetailerInventoryLoaded) {
          final currentProducts = (state as RetailerInventoryLoaded).products;
          emit(RetailerInventoryLoaded(
            products: [...currentProducts, ...products],
            hasReachedMax: products.isEmpty || products.length < (event.limit ?? 20),
            currentPage: event.page ?? 1,
          ));
        } else {
          emit(RetailerInventoryLoaded(
            products: products,
            hasReachedMax: products.isEmpty || products.length < (event.limit ?? 20),
            currentPage: event.page ?? 1,
          ));
        }
      },
    );
  }

  Future<void> _onCreateProductRequested(CreateProductRequested event, Emitter<RetailerInventoryState> emit) async {
    emit(const RetailerInventoryLoading());
    final result = await _createProductUseCase.execute(
      name: event.name,
      sellingPrice: event.sellingPrice,
      description: event.description,
      categoryId: event.categoryId,
      brand: event.brand,
      images: event.images,
      mrp: event.mrp,
      stockQuantity: event.stockQuantity,
      lowStockThreshold: event.lowStockThreshold,
      sku: event.sku,
      barcode: event.barcode,
      tags: event.tags,
    );
    result.fold(
      (failure) => emit(RetailerInventoryError(failure)),
      (_) => emit(const RetailerInventoryActionSuccess('Product created successfully')),
    );
  }

  Future<void> _onUpdateProductRequested(UpdateProductRequested event, Emitter<RetailerInventoryState> emit) async {
    emit(const RetailerInventoryLoading());
    final result = await _updateProductUseCase.execute(
      id: event.id,
      name: event.name,
      sellingPrice: event.sellingPrice,
      description: event.description,
      categoryId: event.categoryId,
      brand: event.brand,
      images: event.images,
      mrp: event.mrp,
      stockQuantity: event.stockQuantity,
      lowStockThreshold: event.lowStockThreshold,
      sku: event.sku,
      barcode: event.barcode,
      tags: event.tags,
    );
    result.fold(
      (failure) => emit(RetailerInventoryError(failure)),
      (_) => emit(const RetailerInventoryActionSuccess('Product updated successfully')),
    );
  }

  Future<void> _onDeleteProductRequested(DeleteProductRequested event, Emitter<RetailerInventoryState> emit) async {
    emit(const RetailerInventoryLoading());
    final result = await _deleteProductUseCase.execute(event.id);
    result.fold(
      (failure) => emit(RetailerInventoryError(failure)),
      (_) => emit(const RetailerInventoryActionSuccess('Product deleted successfully')),
    );
  }

  Future<void> _onUpdateStockRequested(UpdateStockRequested event, Emitter<RetailerInventoryState> emit) async {
    emit(const RetailerInventoryLoading());
    final result = await _updateStockUseCase.execute(event.id, event.quantity);
    result.fold(
      (failure) => emit(RetailerInventoryError(failure)),
      (_) => emit(const RetailerInventoryActionSuccess('Stock updated successfully')),
    );
  }

  Future<void> _onGetSuppliersRequested(GetSuppliersRequested event, Emitter<RetailerInventoryState> emit) async {
    emit(const RetailerInventoryLoading());
    final result = await _getSuppliersUseCase.execute();
    result.fold(
      (failure) => emit(RetailerInventoryError(failure)),
      (suppliers) => emit(SuppliersLoaded(suppliers)),
    );
  }

  Future<void> _onCreateSupplierRequested(CreateSupplierRequested event, Emitter<RetailerInventoryState> emit) async {
    emit(const RetailerInventoryLoading());
    final result = await _createSupplierUseCase.execute(event.data);
    result.fold(
      (failure) => emit(RetailerInventoryError(failure)),
      (_) => emit(const RetailerInventoryActionSuccess('Supplier created successfully')),
    );
  }

  Future<void> _onGetPurchaseOrdersRequested(GetPurchaseOrdersRequested event, Emitter<RetailerInventoryState> emit) async {
    emit(const RetailerInventoryLoading());
    final result = await _getPurchaseOrdersUseCase.execute();
    result.fold(
      (failure) => emit(RetailerInventoryError(failure)),
      (orders) => emit(PurchaseOrdersLoaded(orders)),
    );
  }

  Future<void> _onGetStockHistoryRequested(GetStockHistoryRequested event, Emitter<RetailerInventoryState> emit) async {
    emit(const RetailerInventoryLoading());
    final result = await _getStockHistoryUseCase.execute();
    result.fold(
      (failure) => emit(RetailerInventoryError(failure)),
      (history) => emit(StockHistoryLoaded(history)),
    );
  }
}
