// ignore_for_file: use_null_aware_elements
import 'package:dio/dio.dart';
import '../models/negotiation_model.dart';

abstract class NegotiationRemoteDataSource {
  Future<NegotiationModel> startNegotiation(String productId, double offeredPrice, {String? message});
  Future<List<NegotiationModel>> getMyNegotiations({int page = 1, int limit = 20});
  Future<NegotiationModel> getNegotiationDetail(String id);
  Future<NegotiationModel> counterOffer(String id, double counterPrice);
  Future<NegotiationModel> acceptDeal(String id);
  Future<NegotiationModel> rejectDeal(String id);

  Future<List<NegotiationModel>> getShopNegotiations({String? status, int page = 1, int limit = 20});
  Future<NegotiationModel> shopkeeperCounter(String id, double counterPrice, {String? message});
  Future<NegotiationModel> shopkeeperAccept(String id);
  Future<NegotiationModel> shopkeeperReject(String id);
}

class NegotiationRemoteDataSourceImpl implements NegotiationRemoteDataSource {
  final Dio dio;

  NegotiationRemoteDataSourceImpl(this.dio);

  @override
  Future<NegotiationModel> startNegotiation(String productId, double offeredPrice, {String? message}) async {
    final response = await dio.post('/negotiations', data: {
      'productId': productId,
      'offeredPrice': offeredPrice,
      if (message != null) 'message': message,
    });
    return NegotiationModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<List<NegotiationModel>> getMyNegotiations({int page = 1, int limit = 20}) async {
    final response = await dio.get('/negotiations', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final List data = response.data['data'] ?? response.data;
    return data.map((json) => NegotiationModel.fromJson(json)).toList();
  }

  @override
  Future<NegotiationModel> getNegotiationDetail(String id) async {
    final response = await dio.get('/negotiations/$id');
    return NegotiationModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<NegotiationModel> counterOffer(String id, double counterPrice) async {
    final response = await dio.post('/negotiations/$id/counter', data: {
      'counterPrice': counterPrice,
    });
    return NegotiationModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<NegotiationModel> acceptDeal(String id) async {
    final response = await dio.post('/negotiations/$id/accept');
    return NegotiationModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<NegotiationModel> rejectDeal(String id) async {
    final response = await dio.post('/negotiations/$id/reject');
    return NegotiationModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<List<NegotiationModel>> getShopNegotiations({String? status, int page = 1, int limit = 20}) async {
    final response = await dio.get('/shopkeeper/negotiations', queryParameters: {
      if (status != null) 'status': status,
      'page': page,
      'limit': limit,
    });
    final List data = response.data['data'] ?? response.data;
    return data.map((json) => NegotiationModel.fromJson(json)).toList();
  }

  @override
  Future<NegotiationModel> shopkeeperCounter(String id, double counterPrice, {String? message}) async {
    final response = await dio.post('/shopkeeper/negotiations/$id/counter', data: {
      'counterPrice': counterPrice,
      if (message != null) 'message': message,
    });
    return NegotiationModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<NegotiationModel> shopkeeperAccept(String id) async {
    final response = await dio.post('/shopkeeper/negotiations/$id/accept');
    return NegotiationModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<NegotiationModel> shopkeeperReject(String id) async {
    final response = await dio.post('/shopkeeper/negotiations/$id/reject');
    return NegotiationModel.fromJson(response.data['data'] ?? response.data);
  }
}
