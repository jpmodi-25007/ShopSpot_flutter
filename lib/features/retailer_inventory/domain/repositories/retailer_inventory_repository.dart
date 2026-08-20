import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';

abstract interface class RetailerInventoryRepository {
  Future<Either<Failure, List<ProductEntity>>> getMyProducts({
    String? query,
    String? categoryId,
    String? stockStatus,
    int? page,
    int? limit,
  });

  Future<Either<Failure, ProductEntity>> createProduct({
    required String name,
    required double sellingPrice,
    String? description,
    String? categoryId,
    String? brand,
    List<String>? images,
    double? mrp,
    int? stockQuantity,
    int? lowStockThreshold,
    String? sku,
    String? barcode,
    List<String>? tags,
  });

  Future<Either<Failure, ProductEntity>> updateProduct({
    required String id,
    String? name,
    double? sellingPrice,
    String? description,
    String? categoryId,
    String? brand,
    List<String>? images,
    double? mrp,
    int? stockQuantity,
    int? lowStockThreshold,
    String? sku,
    String? barcode,
    List<String>? tags,
  });

  Future<Either<Failure, void>> deleteProduct(String id);

  Future<Either<Failure, ProductEntity>> updateStock({
    required String id,
    required int quantity,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getSuppliers();
  Future<Either<Failure, Map<String, dynamic>>> createSupplier(Map<String, dynamic> data);
  Future<Either<Failure, List<Map<String, dynamic>>>> getPurchaseOrders();
  Future<Either<Failure, List<Map<String, dynamic>>>> getStockHistory();
}
