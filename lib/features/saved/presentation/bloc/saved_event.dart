import 'package:equatable/equatable.dart';

abstract class SavedEvent extends Equatable {
  const SavedEvent();

  @override
  List<Object?> get props => [];
}

class GetSavedProductsRequested extends SavedEvent {
  const GetSavedProductsRequested();
}

class SaveProductRequested extends SavedEvent {
  final String productId;
  const SaveProductRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class RemoveSavedProductRequested extends SavedEvent {
  final String productId;
  const RemoveSavedProductRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class GetSavedShopsRequested extends SavedEvent {
  const GetSavedShopsRequested();
}

class SaveShopRequested extends SavedEvent {
  final String shopId;
  const SaveShopRequested(this.shopId);

  @override
  List<Object?> get props => [shopId];
}

class RemoveSavedShopRequested extends SavedEvent {
  final String shopId;
  const RemoveSavedShopRequested(this.shopId);

  @override
  List<Object?> get props => [shopId];
}
