import 'package:equatable/equatable.dart';
import '../../../negotiation/domain/entities/negotiation_entity.dart';

abstract class RetailerNegotiationState extends Equatable {
  const RetailerNegotiationState();

  @override
  List<Object?> get props => [];
}

class RetailerNegotiationInitial extends RetailerNegotiationState {}

class RetailerNegotiationLoading extends RetailerNegotiationState {}

class RetailerNegotiationLoaded extends RetailerNegotiationState {
  final List<NegotiationEntity>? negotiations;
  final NegotiationEntity? activeNegotiation;
  final bool isSubmitting;

  const RetailerNegotiationLoaded({
    this.negotiations,
    this.activeNegotiation,
    this.isSubmitting = false,
  });

  RetailerNegotiationLoaded copyWith({
    List<NegotiationEntity>? negotiations,
    NegotiationEntity? activeNegotiation,
    bool? isSubmitting,
  }) {
    return RetailerNegotiationLoaded(
      negotiations: negotiations ?? this.negotiations,
      activeNegotiation: activeNegotiation ?? this.activeNegotiation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [negotiations, activeNegotiation, isSubmitting];
}

class RetailerNegotiationError extends RetailerNegotiationState {
  final String message;

  const RetailerNegotiationError(this.message);

  @override
  List<Object?> get props => [message];
}
