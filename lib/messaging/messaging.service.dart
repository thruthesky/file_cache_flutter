import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/messaging/messaging.defines.dart';
import 'package:philgo/messaging/messaging.functions.dart';

/// Firebase Cloud Messaging service for push notifications
class MessagingService {
  static MessagingService? _instance;
  static MessagingService get instance => _instance ??= MessagingService._();
  MessagingService._();

  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  FirebaseDatabase get database => FirebaseDatabase.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;

  String? lastSavedToken;

  bool isInitialized = false;

  Function(RemoteMessage)? onForegroundMessage;
  Function(RemoteMessage)? onMessageOpenedFromTerminated;
  Function(RemoteMessage)? onMessageOpenedFromBackground;

  // Will be save to php database as domain when token is being saved
  String domain = 'app_default';

  /// Initialize Firebase Messaging
  /// [onBackgroundMessage] - Function to handle background messages.
  ///   This is invoked when the app is closed(terminated). (NOT running the app.)
  ///   Usage: (updating icon badge, etc.)
  ///
  /// [onForegroundMessage] will be called when the user(or device) receives a push notification
  /// while the app is running and in foreground state.
  ///
  /// [onMessageOpenedFromBackground] will be called when the user tapped on the push notification
  ///
  /// [onMessageOpenedFromTerminated] will be called when the user tapped on the push notification
  /// on system tray while the app was closed(terminated).
  ///
  ///
  Future<void> initialize({
    required String domain,
    Function(RemoteMessage)? onForegroundMessage,
    Function(RemoteMessage)? onMessageOpenedFromTerminated,
    Function(RemoteMessage)? onMessageOpenedFromBackground,
    Future<void> Function(RemoteMessage)? onBackgroundMessage,
  }) async {
    if (isInitialized) return;

    this.domain = domain;

    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    // Set callbacks for message handlers
    this.onForegroundMessage = onForegroundMessage;
    this.onMessageOpenedFromTerminated = onMessageOpenedFromTerminated;
    this.onMessageOpenedFromBackground = onMessageOpenedFromBackground;

    try {
      // Request notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // debugPrint(
      //   'Notification permission granted: ${settings.authorizationStatus}',
      // );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Setup message handlers
        await _setupMessageHandlers();

        // Listen to auth state changes
        auth.authStateChanges().listen((User? user) async {
          if (user != null) {
            await saveToken();
          }
        });

        await saveToken();
      }

      isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing messaging service: $e');
    }
  }

  /// Get FCM token and save to database
  Future<void> saveToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    log("$token", name: '[FCM TOKEN]::');
    if (token == null || token.isEmpty) {
      debugPrint('FCM token is null or empty');
      return;
    }

    // debugPrint('FCM Token: $token');

    final data = <String, dynamic>{
      DEVICE: getDeviceType(),
      TOKEN: token,
      DOMAIN: domain,
    };
    String tokenCache = token;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      data['uid'] = user.uid;
      tokenCache = token + user.uid;
    }

    // debugPrint('FCM token saved to database: $token');

    // If token is the same as last saved, skip API call
    if (tokenCache == lastSavedToken) {
      // debugPrint('Skip subscribing to all users topic: $token');
      return;
    }

    lastSavedToken = tokenCache;

    try {
      await ApiService.instance.v7api(
        MessagingConfig.messagingSaveTokenApi,
        data: data,
      );
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Setup message handlers for foreground, background, and terminated states
  Future<void> _setupMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    // Handle message when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedFromBackground);

    // Check for initial message when app is launched from notification
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      // debugPrint('Initial message detected: ${initialMessage.messageId}');
      // debugPrint('Initial message data: ${initialMessage.data}');
      // debugPrint(
      //   'Initial message notification: ${initialMessage.notification?.title} - ${initialMessage.notification?.body}',
      // );
      // Store the initial message to handle it when app is ready
      // _pendingInitialMessage = initialMessage;
      onMessageOpenedFromTerminated?.call(initialMessage);
    } else {
      // debugPrint('No initial message found');
    }
  }

  /// Handle foreground messages -  while the app is open
  void handleForegroundMessage({
    required BuildContext context,
    required RemoteMessage message,
    required Function(RemoteMessage) onPressed,
  }) {
    // debugPrint('Received foreground message: ${message.messageId}');
    // debugPrint('Title: ${message.notification?.title}');
    // debugPrint('Body: ${message.notification?.body}');
    // debugPrint('Data: ${message.data}');
    showInAppNotification(
      context: context,
      message: message,
      onPressed: onPressed,
    );
  }

  /// Show in-app notification for foreground messages
  void showInAppNotification({
    required BuildContext context,
    required RemoteMessage message,
    required Function(RemoteMessage) onPressed,
  }) {
    debugPrint('Showing in-app notification: ${message.messageId}');

    final notification = message.notification;
    if (notification == null) return;

    // Show snackbar or custom notification widget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notification.title != null)
              Text(
                notification.title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            if (notification.body != null) Text(notification.body!),
          ],
        ),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () => onPressed(message),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Subscribe to a specific topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a specific topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
