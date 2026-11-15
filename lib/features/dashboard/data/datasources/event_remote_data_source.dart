import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../models/event_model.dart';
import '../../domain/entities/event_entity.dart';

abstract class EventRemoteDataSource {
  Future<List<EventEntity>> getEvents();
  Future<List<EventEntity>> getShopEvents();
  Future<EventEntity> getEventDetail(String id);
  Future<void> createEvent(EventModel event);
  Future<void> updateEvent(String id, EventModel event);
  Future<void> deleteEvent(String id);
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final Dio dio;

  EventRemoteDataSourceImpl({required this.dio});

  Exception _handleError(dynamic e) {
    if (e is DioException) {
      final resData = e.response?.data;
      if (resData is Map) {
        final msg = resData['message'];
        if (msg is List) {
          return Exception(msg.join(', '));
        } else if (msg != null && msg.toString().isNotEmpty) {
          return Exception(msg.toString());
        }
      }
      if (e.message != null && e.message!.isNotEmpty) {
        return Exception(e.message!);
      }
    }
    return Exception(e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''));
  }

  @override
  Future<List<EventEntity>> getEvents() async {
    try {
      final response = await dio.get('${ApiConstants.baseUrl}/events/all');
      final body = response.data;
      final raw = body is Map ? body['data'] : body;
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((json) => EventModel.fromJson(Map<String, dynamic>.from(json)).toEntity())
            .where((event) => event.isActive)
            .toList();
      }
      throw Exception('Failed to load events');
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<EventEntity>> getShopEvents() async {
    try {
      final response = await dio.get('${ApiConstants.baseUrl}/events/shop');
      if (response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'];
        return data
            .map((json) => EventModel.fromJson(json).toEntity())
            .toList();
      }
      throw Exception('Failed to load shop events');
    } catch (e) {
      throw _handleError(e);
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
      throw _handleError(e);
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
      throw _handleError(e);
    }
  }

  @override
  Future<void> updateEvent(String id, EventModel event) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.baseUrl}/events/$id',
        data: event.toJson(),
      );
      if (response.data['status'] != 'success') {
        throw Exception('Failed to update event');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.baseUrl}/events/$id');
      if (response.data['status'] != 'success') {
        throw Exception('Failed to delete event');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }
}
