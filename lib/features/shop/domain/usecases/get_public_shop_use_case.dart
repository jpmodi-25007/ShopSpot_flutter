import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/shop_entity.dart';
import '../repositories/shop_repository.dart';

class GetPublicShopUseCase {
  final ShopRepository repository;

  GetPublicShopUseCase(this.repository);

  Future<Either<Failure, ShopEntity>> execute(String id) async {
    return await repository.getPublicShop(id);
  }
}
