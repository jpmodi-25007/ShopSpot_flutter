import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import 'event_event.dart';
import 'event_state.dart';
import '../../data/datasources/event_remote_data_source.dart';
import '../../data/models/event_model.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRemoteDataSource remoteDataSource;

  EventBloc({required this.remoteDataSource}) : super(EventInitial()) {
    on<GetEventsRequested>(_onGetEventsRequested);
    on<GetEventDetailRequested>(_onGetEventDetailRequested);
    on<CreateEventRequested>(_onCreateEventRequested);
  }

  Future<void> _onGetEventsRequested(
    GetEventsRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final events = await remoteDataSource.getEvents();
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onGetEventDetailRequested(
    GetEventDetailRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final eventDetail = await remoteDataSource.getEventDetail(event.id);
      emit(EventDetailLoaded(eventDetail));
    } catch (e) {
      emit(EventError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventCreating());
    try {
      final newEvent = EventModel(
        id: '', // Backend will generate
        title: event.title,
        description: event.description,
        location: event.location,
        startDate: event.startDate,
        endDate: event.endDate,
        imageUrl: event.imageUrl,
      );
      await remoteDataSource.createEvent(newEvent);
      emit(EventCreated());
    } catch (e) {
      emit(EventError(ServerFailure(e.toString())));
    }
  }
}
