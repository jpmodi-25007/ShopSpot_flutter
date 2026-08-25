import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'notification_payload.dart';
import '../dependency_injection/injection.dart';

class NotificationRouter {
  static final Logger _logger = getIt<Logger>();

  static void handleNotificationTap(NotificationPayload payload, BuildContext context) {
    _logger.i('Handling Notification Tap: \${payload.toString()}');

    // Always prefer the explicit route if backend provided one
    if (payload.hasRoute) {
      context.push(payload.route!);
      return;
    }

    // Fallback manual resolution if route wasn't explicitly passed
    switch (payload.notificationType) {
      case 'PRICE_DROP':
      case 'PRODUCT_OFFER':
        if (payload.entityId != null) {
          context.push('/product-detail/\${payload.entityId}');
        }
        break;
      case 'NEGOTIATION_RECEIVED':
      case 'NEGOTIATION_COUNTERED':
        if (payload.entityId != null) {
          // Note: In a fully role-aware setup without a strict backend route, we would check the current user's role here
          // Since the backend now provides the exact route, this is just a safety net.
          context.push('/negotiation/\${payload.entityId}');
        }
        break;
      case 'RESERVATION_CREATED':
        context.push('/reservations');
        break;
      case 'ORDER_STATUS_CHANGED':
        context.push('/my-orders');
        break;
      case 'BID_RECEIVED':
        if (payload.entityId != null) {
          context.push('/retailer/campaigns/\${payload.entityId}/bids');
        }
        break;
      default:
        _logger.w('Unknown notification type or missing route: \${payload.notificationType}');
        break;
    }
  }
}
