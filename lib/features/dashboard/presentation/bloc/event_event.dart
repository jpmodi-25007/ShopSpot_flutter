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
