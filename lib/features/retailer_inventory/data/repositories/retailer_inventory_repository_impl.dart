import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../../domain/repositories/retailer_inventory_repository.dart';
import '../datasources/retailer_inventory_remote_data_source.dart';

class RetailerInventoryRepositoryImpl implements RetailerInventoryRepository {
  final RetailerInventoryRemoteDataSource remoteDataSource;

  RetailerInventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getMyProducts({
    String? query,
    String? categoryId,
    String? stockStatus,
    int? page,
    int? limit,
  }) async {
    try {
      final models = await remoteDataSource.getMyProducts(
        query: query,
        categoryId: categoryId,
        stockStatus: stockStatus,
        page: page,
        limit: limit,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final model = await remoteDataSource.createProduct(
        name: name,
        sellingPrice: sellingPrice,
        description: description,
        categoryId: categoryId,
        brand: brand,
        images: images,
        mrp: mrp,
        stockQuantity: stockQuantity,
        lowStockThreshold: lowStockThreshold,
        sku: sku,
        barcode: barcode,
        tags: tags,
      );
      return Right(model.toEntity());
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final model = await remoteDataSource.updateProduct(
        id: id,
        name: name,
        sellingPrice: sellingPrice,
        description: description,
        categoryId: categoryId,
        brand: brand,
        images: images,
        mrp: mrp,
        stockQuantity: stockQuantity,
        lowStockThreshold: lowStockThreshold,
        sku: sku,
        barcode: barcode,
        tags: tags,
      );
      return Right(model.toEntity());
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateStock({
    required String id,
    required int quantity,
  }) async {
    try {
      final model = await remoteDataSource.updateStock(id: id, quantity: quantity);
      return Right(model.toEntity());
    } on ValidationException catch (e) {
      return Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSuppliers() async {
    try {
      final data = await remoteDataSource.getSuppliers();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSupplier(Map<String, dynamic> data) async {
    try {
      final res = await remoteDataSource.createSupplier(data);
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPurchaseOrders() async {
    try {
      final data = await remoteDataSource.getPurchaseOrders();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getStockHistory() async {
    try {
      final data = await remoteDataSource.getStockHistory();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
