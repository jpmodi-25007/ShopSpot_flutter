import 'dart:convert';
import 'package:dio/dio.dart';

class SubscriptionService {
  final Dio _dio;

  SubscriptionService(this._dio);

  Future<List<dynamic>> getPlans() async {
    List<dynamic> serverPlans = [];
    try {
      final res = await _dio.get('/subscriptions/plans');
      dynamic data = res.data;
      if (data is String && data.isNotEmpty) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is List && data.isNotEmpty) {
        serverPlans = data;
      } else if (data is Map && data['data'] is List && (data['data'] as List).isNotEmpty) {
        serverPlans = data['data'] as List;
      }
    } catch (_) {}

    // Helper to find a matching plan from server by tier candidates
    Map<String, dynamic>? findServerPlan(List<String> matchTiers) {
      for (final p in serverPlans) {
        if (p is Map) {
          final t = (p['tier'] ?? '').toString().toUpperCase();
          if (matchTiers.contains(t)) {
            return Map<String, dynamic>.from(p);
          }
        }
      }
      return null;
    }

    final freeServer = findServerPlan(['FREE']);
    final proServer = findServerPlan(['PRO', 'BASIC']);
    final premiumServer = findServerPlan(['PREMIUM', 'ELITE']);

    // Canonical 3 tiers with rich metadata and seamless mapping to server IDs
    return [
      {
        'id': freeServer?['id']?.toString() ?? 'free',
        'tier': 'FREE',
        'name': (freeServer?['name'] != null && freeServer!['name'] != 'FREE')
            ? freeServer['name'].toString()
            : 'Free Starter',
        'tagline': freeServer?['tagline']?.toString().isNotEmpty == true
            ? freeServer!['tagline'].toString()
            : 'Get your shop online in minutes — zero cost, zero risk',
        'price': 0,
        'yearlyPrice': null,
        'productLimit': int.tryParse(freeServer?['productLimit']?.toString() ?? '') ?? 50,
        'eventLimit': int.tryParse(freeServer?['eventLimit']?.toString() ?? '') ?? 0,
        'badge': 'STARTER',
        'features': [
          'Up to 50 products upload',
          'Basic shop listing in local search',
          'WhatsApp & call customer inquiries',
          'Order & inquiry management inbox',
          'Basic sales & visitor analytics',
          '1st month completely free for new shops',
        ],
        'isHighlighted': false,
      },
      {
        'id': proServer?['id']?.toString() ?? 'pro',
        'tier': 'PRO',
        'name': (proServer?['name'] != null && !['PRO', 'BASIC'].contains(proServer!['name']))
            ? proServer['name'].toString()
            : 'Pro Growth',
        'tagline': proServer?['tagline']?.toString().isNotEmpty == true
            ? proServer!['tagline'].toString()
            : 'Grow your reach — promote events, attract more customers',
        'price': double.tryParse(proServer?['price']?.toString() ?? '') ?? 499,
        'yearlyPrice': double.tryParse(proServer?['yearlyPrice']?.toString() ?? '') ?? 4788,
        'productLimit': int.tryParse(proServer?['productLimit']?.toString() ?? '') ?? 200,
        'eventLimit': int.tryParse(proServer?['eventLimit']?.toString() ?? '') ?? 1,
        'badge': 'MOST POPULAR',
        'features': [
          'Up to 200 products upload limit (4x more)',
          '1 promoted event/month on customer home banner',
          '🔵 Pro Verified badge on shop profile',
          '20% boosted ranking in local search results',
          'Customer direct chat & special offer sharing',
          'Promotional banner in nearby shopper feeds',
          'Automated GST-compliant invoices',
          'Advanced revenue & customer analytics',
        ],
        'isHighlighted': true,
      },
      {
        'id': premiumServer?['id']?.toString() ?? 'premium',
        'tier': 'PREMIUM',
        'name': (premiumServer?['name'] != null && !['PREMIUM', 'ELITE'].contains(premiumServer!['name']))
            ? premiumServer['name'].toString()
            : 'Premium VIP',
        'tagline': premiumServer?['tagline']?.toString().isNotEmpty == true
            ? premiumServer!['tagline'].toString()
            : 'Dominate your locality — maximum visibility, maximum sales',
        'price': double.tryParse(premiumServer?['price']?.toString() ?? '') ?? 1199,
        'yearlyPrice': double.tryParse(premiumServer?['yearlyPrice']?.toString() ?? '') ?? 11508,
        'productLimit': int.tryParse(premiumServer?['productLimit']?.toString() ?? '') ?? 500,
        'eventLimit': int.tryParse(premiumServer?['eventLimit']?.toString() ?? '') ?? 3,
        'badge': 'BEST VALUE',
        'features': [
          'Up to 500 products upload limit (10x more)',
          'Up to 3 events & flash promotions on home carousel',
          '👑 Gold Crown VIP badge on shop & products',
          '50% search ranking boost + Top-3 category placement',
          'Influencer campaign invites (2/month)',
          'Full-width home screen banner placement',
          'Price negotiation & instant counter-offers',
          'Bulk CSV product inventory upload & stock alerts',
          'Automated GST-compliant invoices',
          'Priority 24/7 retailer support hotline',
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

  Future<Map<String, dynamic>> createOrder(String planId, {String? planTier}) async {
    try {
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
    } on DioException catch (dioErr) {
      // If 404, the remote backend hasn't deployed the new /payments/create-order endpoint yet
      if (dioErr.response?.statusCode == 404) {
        final tier = (planTier ?? planId).toUpperCase();
        try {
          final mappedTier = (tier == 'PRO') ? 'BASIC' : tier;
          final subRes = await _dio.post('/subscriptions/subscribe', data: {
            'tier': mappedTier,
          });
          return {
            'activatedDirectly': true,
            'message': 'Plan activated successfully!',
            'data': subRes.data,
          };
        } catch (_) {
          throw Exception(
            'The payment service is being updated on the server. Please ensure the backend is deployed on Render Dashboard to enable live Razorpay transactions.',
          );
        }
      }
      rethrow;
    }
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
