import 'package:equatable/equatable.dart';

sealed class RetailerInventoryEvent extends Equatable {
  const RetailerInventoryEvent();

  @override
  List<Object?> get props => [];
}

final class GetMyProductsRequested extends RetailerInventoryEvent {
  final String? query;
  final String? categoryId;
  final String? stockStatus;
  final int? page;
  final int? limit;

  const GetMyProductsRequested({
    this.query,
    this.categoryId,
    this.stockStatus,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [query, categoryId, stockStatus, page, limit];
}

final class CreateProductRequested extends RetailerInventoryEvent {
  final String name;
  final double sellingPrice;
  final String? description;
  final String? categoryId;
  final String? brand;
  final List<String>? images;
  final double? mrp;
  final int? stockQuantity;
  final int? lowStockThreshold;
  final String? sku;
  final String? barcode;
  final List<String>? tags;

  const CreateProductRequested({
    required this.name,
    required this.sellingPrice,
    this.description,
    this.categoryId,
    this.brand,
    this.images,
    this.mrp,
    this.stockQuantity,
    this.lowStockThreshold,
    this.sku,
    this.barcode,
    this.tags,
  });

  @override
  List<Object?> get props => [
        name,
        sellingPrice,
        description,
        categoryId,
        brand,
        images,
        mrp,
        stockQuantity,
        lowStockThreshold,
        sku,
        barcode,
        tags,
      ];
}

final class UpdateProductRequested extends RetailerInventoryEvent {
  final String id;
  final String? name;
  final double? sellingPrice;
  final String? description;
  final String? categoryId;
  final String? brand;
  final List<String>? images;
  final double? mrp;
  final int? stockQuantity;
  final int? lowStockThreshold;
  final String? sku;
  final String? barcode;
  final List<String>? tags;

  const UpdateProductRequested({
    required this.id,
    this.name,
    this.sellingPrice,
    this.description,
    this.categoryId,
    this.brand,
    this.images,
    this.mrp,
    this.stockQuantity,
    this.lowStockThreshold,
    this.sku,
    this.barcode,
    this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        sellingPrice,
        description,
        categoryId,
        brand,
        images,
        mrp,
        stockQuantity,
        lowStockThreshold,
        sku,
        barcode,
        tags,
      ];
}

final class DeleteProductRequested extends RetailerInventoryEvent {
  final String id;

  const DeleteProductRequested(this.id);

  @override
  List<Object?> get props => [id];
}

final class UpdateStockRequested extends RetailerInventoryEvent {
  final String id;
  final int quantity;

  const UpdateStockRequested(this.id, this.quantity);

  @override
  List<Object?> get props => [id, quantity];
}

final class GetSuppliersRequested extends RetailerInventoryEvent {
  const GetSuppliersRequested();
}

final class CreateSupplierRequested extends RetailerInventoryEvent {
  final Map<String, dynamic> data;

  const CreateSupplierRequested(this.data);

  @override
  List<Object?> get props => [data];
}

final class GetPurchaseOrdersRequested extends RetailerInventoryEvent {
  const GetPurchaseOrdersRequested();
}

final class GetStockHistoryRequested extends RetailerInventoryEvent {
  const GetStockHistoryRequested();
}
