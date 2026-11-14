import 'dart:convert';
import 'package:dio/dio.dart';

class SubscriptionService {
  final Dio _dio;

  SubscriptionService(this._dio);

  Future<List<dynamic>> getPlans() async {
    try {
      final res = await _dio.get('/subscriptions/plans');
      dynamic data = res.data;
      if (data is String && data.isNotEmpty) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is List && data.isNotEmpty) return data;
      if (data is Map && data['data'] is List && (data['data'] as List).isNotEmpty) {
        return data['data'] as List;
      }
    } catch (_) {}

    // Fallback default marketing plans if server returned empty or is updating
    return [
      {
        'id': 'free',
        'tier': 'FREE',
        'name': 'Free',
        'tagline': 'Get your shop online in minutes — zero cost, zero risk',
        'price': 0,
        'yearlyPrice': null,
        'productLimit': 50,
        'eventLimit': 0,
        'features': [
          'Up to 50 products',
          'Basic shop profile',
          'WhatsApp & call inquiries',
          'Order & reservation management',
          'Basic analytics',
          'Standard search listing',
        ],
        'isHighlighted': false,
      },
      {
        'id': 'pro',
        'tier': 'PRO',
        'name': 'Pro',
        'tagline': 'Grow your reach — promote events, attract more customers',
        'price': 499,
        'yearlyPrice': 4788,
        'productLimit': 200,
        'eventLimit': 1,
        'features': [
          'Up to 200 products',
          '1 promoted event/month on home screen',
          'Advanced analytics',
          '🔵 Pro badge on shop listing',
          '20% higher search ranking',
          'Customer chat enabled',
          'Promotional banner in nearby feed',
          'Auto GST invoice',
        ],
        'isHighlighted': true,
      },
      {
        'id': 'premium',
        'tier': 'PREMIUM',
        'name': 'Premium',
        'tagline': 'Dominate your locality — maximum visibility, maximum sales',
        'price': 1199,
        'yearlyPrice': 11508,
        'productLimit': 500,
        'eventLimit': 3,
        'features': [
          'Up to 500 products',
          'Up to 3 events/promotions on home carousel',
          'Full analytics suite',
          '👑 Premium gold badge',
          '50% search boost + category top-3',
          'Influencer campaigns (2/month)',
          'Full-width home screen banner',
          'Price negotiation feature',
          'Bulk CSV inventory upload',
          'Stock alerts',
          'Auto GST invoice',
          'Early access to new features',
        ],
        'isHighlighted': false,
      },
    ];
  }

  Future<Map<String, dynamic>?> getMySubscription() async {
    try {
      final res = await _dio.get('/subscriptions/me');
      dynamic data = res.data;
      if (data == null || data == '') return null;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          return null;
        }
      }
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      // If 404 or unauthenticated, return null safely
      return null;
    }
  }

  Future<Map<String, dynamic>> createOrder(String planId) async {
    final res = await _dio.post('/payments/create-order', data: {'planId': planId});
    dynamic data = res.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Unexpected response format');
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
    dynamic data = res.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Unexpected response format');
  }

  Future<List<dynamic>> getPaymentHistory() async {
    try {
      final res = await _dio.get('/payments/history');
      dynamic data = res.data;
      if (data is String && data.isNotEmpty) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is List) return data;
      if (data is Map && data['data'] is List) return data['data'] as List;
      return [];
    } catch (_) {
      return [];
    }
  }
}
