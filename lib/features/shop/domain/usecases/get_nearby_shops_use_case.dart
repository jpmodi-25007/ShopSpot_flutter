import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

class GetNearbyShopsUseCase {
  final ShopRepository repository;

  GetNearbyShopsUseCase(this.repository);

  Future<Either<Failure, List<ShopEntity>>> execute({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    String? categoryId,
  }) async {
    return await repository.getNearbyShops(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      categoryId: categoryId,
    );
  }
}
