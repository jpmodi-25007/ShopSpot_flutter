import 'package:equatable/equatable.dart';

abstract class NegotiationEvent extends Equatable {
  const NegotiationEvent();

  @override
  List<Object?> get props => [];
}

class StartNegotiationRequested extends NegotiationEvent {
  final String productId;
  final double offeredPrice;
  final String? message;

  const StartNegotiationRequested({
    required this.productId,
    required this.offeredPrice,
    this.message,
  });

  @override
  List<Object?> get props => [productId, offeredPrice, message];
}

class GetMyNegotiationsRequested extends NegotiationEvent {
  final int page;
  final int limit;

  const GetMyNegotiationsRequested({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

class GetNegotiationDetailRequested extends NegotiationEvent {
  final String id;

  const GetNegotiationDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class CounterOfferRequested extends NegotiationEvent {
  final String id;
  final double counterPrice;

  const CounterOfferRequested({required this.id, required this.counterPrice});

  @override
  List<Object?> get props => [id, counterPrice];
}

class AcceptDealRequested extends NegotiationEvent {
  final String id;

  const AcceptDealRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class RejectDealRequested extends NegotiationEvent {
  final String id;

  const RejectDealRequested(this.id);

  @override
  List<Object?> get props => [id];
}
