import 'package:equatable/equatable.dart';
import '../../domain/entities/negotiation_entity.dart';

abstract class NegotiationState extends Equatable {
  const NegotiationState();

  @override
  List<Object?> get props => [];
}

class NegotiationInitial extends NegotiationState {}

class NegotiationLoading extends NegotiationState {}

class NegotiationLoaded extends NegotiationState {
  final List<NegotiationEntity>? negotiations;
  final NegotiationEntity? activeNegotiation;
  final bool isSubmitting;
  final bool hasReachedMax;
  final int currentPage;

  const NegotiationLoaded({
    this.negotiations,
    this.activeNegotiation,
    this.isSubmitting = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  NegotiationLoaded copyWith({
    List<NegotiationEntity>? negotiations,
    NegotiationEntity? activeNegotiation,
    bool? isSubmitting,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return NegotiationLoaded(
      negotiations: negotiations ?? this.negotiations,
      activeNegotiation: activeNegotiation ?? this.activeNegotiation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [negotiations, activeNegotiation, isSubmitting, hasReachedMax, currentPage];
}

class NegotiationError extends NegotiationState {
  final String message;

  const NegotiationError(this.message);

  @override
  List<Object?> get props => [message];
}
