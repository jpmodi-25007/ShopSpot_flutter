import 'package:dio/dio.dart';

class SubscriptionService {
  final Dio _dio;

  SubscriptionService(this._dio);

  Future<List<dynamic>> getPlans() async {
    final res = await _dio.get('/subscriptions/plans');
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['data'] != null) return data['data'] as List;
    return [];
  }

  Future<Map<String, dynamic>> getMySubscription() async {
    final res = await _dio.get('/subscriptions/me');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createOrder(String planId) async {
    final res = await _dio.post('/payments/create-order', data: {'planId': planId});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final res = await _dio.post('/payments/verify', data: {
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPaymentHistory() async {
    final res = await _dio.get('/payments/history');
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['data'] != null) return data['data'] as List;
    return [];
  }
}

