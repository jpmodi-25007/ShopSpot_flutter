import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class GetEventsRequested extends EventEvent {
  const GetEventsRequested();
}

class GetShopEventsRequested extends EventEvent {
  const GetShopEventsRequested();
}

class GetEventDetailRequested extends EventEvent {
  final String id;

  const GetEventDetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateEventRequested extends EventEvent {
  final String title;
  final String? description;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;

  const CreateEventRequested({
    required this.title,
    this.description,
    this.location,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [title, description, location, startDate, endDate, imageUrl];
}


class UpdateEventRequested extends EventEvent {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;

  const UpdateEventRequested({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, description, location, startDate, endDate, imageUrl];
}

class DeleteEventRequested extends EventEvent {
  final String id;

  const DeleteEventRequested(this.id);

  @override
  List<Object?> get props => [id];
}
