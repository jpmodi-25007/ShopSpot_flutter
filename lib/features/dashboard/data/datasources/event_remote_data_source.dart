import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/event_model.dart';
import '../../domain/entities/event_entity.dart';

abstract class EventRemoteDataSource {
  Future<List<EventEntity>> getEvents();
  Future<EventEntity> getEventDetail(String id);
  Future<void> createEvent(EventModel event);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;

  EventRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EventEntity>> getEvents() async {
    try {
      final response = await dio.get('${ApiConstants.baseUrl}/events/all');
      if (response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => EventModel.fromJson(json).toEntity()).toList();
      }
      throw Exception('Failed to load events');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<EventEntity> getEventDetail(String id) async {
    try {
      final response = await dio.get('${ApiConstants.baseUrl}/events/$id');
      if (response.data['status'] == 'success') {
        return EventModel.fromJson(response.data['data']).toEntity();
      }
      throw Exception('Failed to load event detail');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> createEvent(EventModel event) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/events',
        data: event.toJson(),
      );
      if (response.data['status'] != 'success') {
        throw Exception('Failed to create event');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
