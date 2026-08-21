import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'dart:io' show Platform;

import '../network/api_constants.dart';
import '../../features/dashboard/presentation/bloc/notification_event.dart';
import '../../features/dashboard/presentation/bloc/notification_bloc.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
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

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Got a message whilst in the foreground!');
        _logger.i('Message data: ${message.data}');

        if (message.notification != null) {
          _logger.i('Message also contained a notification: ${message.notification}');
          // In a real app, you might show a local notification here, or update the UI
          // For now, we will just rely on the BLoC to refresh notifications if needed.
        }
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
