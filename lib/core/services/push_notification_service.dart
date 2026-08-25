import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'dart:io' show Platform;

import '../network/api_constants.dart';
import 'notification_payload.dart';
import 'pending_notification_service.dart';
import 'notification_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Runs in a separate isolate for background messages
  print("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Dio _dio;
  final Logger _logger;

  PushNotificationService(this._dio, this._logger);

  Future<void> initialize() async {
    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    _logger.i('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _registerDeviceToken();

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken);
      });

      // 1. App completely terminated / killed (User taps notification)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _logger.i('App launched from terminated state via notification');
        final payload = NotificationPayload.fromMap(initialMessage.data);
        PendingNotificationService().storePendingNotification(payload);
      }

      // 2. App in foreground (Message received)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Got a message whilst in the foreground!');
        // In a real app, you might show a local notification (e.g. flutter_local_notifications)
        // We do NOT auto-navigate here unless configured.
      });

      // 3. App in background (User taps notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('App opened from background via notification tap');
        final payload = NotificationPayload.fromMap(message.data);
        // Note: we can't easily push here without a global navigator key or context.
        // We will store it in the pending service, and a listener on the router/bloc will consume it.
        PendingNotificationService().storePendingNotification(payload);
      });
    }
  }

  Future<void> _registerDeviceToken() async {
    try {
      // Get the token
      String? token;
      
      if (kIsWeb) {
        token = await _fcm.getToken(vapidKey: 'BPzUGvBPOXttHiyxwSxRuQxd9SpzOWhD6VA3WoX757XC5FBFJE6rk1J6UfLFdzkITJIODwQNX-eA9p7pITC-Lo8');
      } else {
        token = await _fcm.getToken();
      }

      if (token != null) {
        _logger.i('FCM Token: $token');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      _logger.e('Failed to get FCM token: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      String platform = 'web';
      if (!kIsWeb) {
        platform = Platform.isIOS ? 'ios' : 'android';
      }

      await _dio.post(
        '${ApiConstants.baseUrl}/notifications/devices',
        data: {
          'token': token,
          'platform': platform,
        },
      );
      _logger.i('Successfully registered device token on backend');
    } catch (e) {
      _logger.e('Failed to register device token on backend: $e');
    }
  }
}
