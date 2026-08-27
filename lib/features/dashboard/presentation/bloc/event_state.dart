import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/event_entity.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<EventEntity> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class ShopEventsLoaded extends EventState {
  final List<EventEntity> events;
  const ShopEventsLoaded(this.events);

  @override
  List<Object> get props => [events];
}

class EventDetailLoaded extends EventState {
  final EventEntity event;

  const EventDetailLoaded(this.event);

  @override
  List<Object?> get props => [event];
}

class EventError extends EventState {
  final Failure failure;

  const EventError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class EventCreating extends EventState {}

class EventCreated extends EventState {}
