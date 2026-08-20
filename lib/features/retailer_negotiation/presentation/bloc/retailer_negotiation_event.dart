import 'package:equatable/equatable.dart';

abstract class RetailerNegotiationEvent extends Equatable {
  const RetailerNegotiationEvent();

  @override
  List<Object?> get props => [];
}

class GetShopNegotiationsRequested extends RetailerNegotiationEvent {
  final String? status;
  final int page;
  final int limit;

  const GetShopNegotiationsRequested({this.status, this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [status, page, limit];
}

class ShopkeeperCounterRequested extends RetailerNegotiationEvent {
  final String id;
  final double counterPrice;
  final String? message;

  const ShopkeeperCounterRequested({required this.id, required this.counterPrice, this.message});

  @override
  List<Object?> get props => [id, counterPrice, message];
}

class ShopkeeperAcceptRequested extends RetailerNegotiationEvent {
  final String id;

  const ShopkeeperAcceptRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ShopkeeperRejectRequested extends RetailerNegotiationEvent {
  final String id;

  const ShopkeeperRejectRequested(this.id);

  @override
  List<Object?> get props => [id];
}
