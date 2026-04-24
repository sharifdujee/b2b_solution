
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// ✅ This MUST be a top-level function (outside any class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log("🔔 Background message received!");
  developer.log("Title: ${message.notification?.title}");
  developer.log("Body: ${message.notification?.body}");
  developer.log("Data: ${message.data}");
}

/// ✅ Provider for PushNotificationService
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});

/// ✅ Provider for FCM Token
final fcmTokenProvider = StateProvider<String?>((ref) => null);

/// ✅ Provider for notification permission status
final notificationPermissionProvider = StateProvider<AuthorizationStatus?>((ref) => null);

class PushNotificationService {
  final Ref ref;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  PushNotificationService(this.ref) {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  /// ✅ Initialize Push Notification Service
  Future<void> initialize() async {
    /// 🔹 STEP 1: Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    /// 🔹 STEP 2: Request notification permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    ref.read(notificationPermissionProvider.notifier).state = settings.authorizationStatus;

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      developer.log("❌ Notification permissions not granted.");
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        developer.log("⚠️ User denied notification permissions");
      } else {
        developer.log("⚠️ Notification permissions not determined");
      }
      return;
    }

    developer.log("✅ User granted notification permissions");

    /// 🔹 STEP 3: Set iOS foreground presentation behavior
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    /// 🔹 STEP 4: iOS - get APNs token
    if (Platform.isIOS) {
      String? apnsToken;
      int attempts = 0;
      const int maxAttempts = 10;

      do {
        apnsToken = await _firebaseMessaging.getAPNSToken();
        await Future.delayed(const Duration(milliseconds: 300));
        attempts++;
      } while (apnsToken == null && attempts < maxAttempts);

      if (apnsToken == null) {
        developer.log("⚠️ Failed to get APNs token after $maxAttempts attempts.");
        return;
      }

      developer.log("📱 APNs Token: $apnsToken");
    }

    /// 🔹 STEP 5: Get FCM token
    final token = await _firebaseMessaging.getToken();
    developer.log("🔥 FCM Token: $token");
    ref.read(fcmTokenProvider.notifier).state = token;

    /// 🔹 STEP 6: Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      developer.log("🔄 FCM Token refreshed: $newToken");
      ref.read(fcmTokenProvider.notifier).state = newToken;
    });

    /// 🔹 STEP 7: Initialize local notifications
    await _initializeLocalNotifications();

    /// 🔹 STEP 8: Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        "📥 Foreground message received: ${message.notification?.title ?? 'Data message'}",
      );
      developer.log("Message data: ${message.data}");

      _refreshNotificationList();

      if (message.notification != null) {
        _showNotification(message);
      } else {
        _handleDataOnlyMessage(message);
      }
    });

    /// 🔹 STEP 9: When app is opened from background notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log("🔁 App opened from background notification");
      developer.log("Notification data: ${message.data}");

      _refreshNotificationList();
      _navigateToScreen(message);
    });

    /// 🔹 STEP 10: When app is opened from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      developer.log("🚀 App opened from terminated notification");
      developer.log("Notification data: ${initialMessage.data}");

      Future.delayed(const Duration(milliseconds: 500), () {
        _refreshNotificationList();
        _navigateToScreen(initialMessage);
      });
    }

    developer.log("✅ Push notification service initialized successfully");
  }

  void _refreshNotificationList() {
    try {
      // TODO: Implement your Riverpod notification controller refresh here
      developer.log("✅ Notification list refresh triggered");
    } catch (e) {
      developer.log("❌ Error refreshing lists: $e");
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        developer.log("Android notification permission granted: $granted");

        const channel = AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'Used for important notifications',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

        await androidImplementation.createNotificationChannel(channel);
      }
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
    );

    developer.log("✅ Local notifications initialized");
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    developer.log("📲 Notification clicked (foreground)");
    developer.log("Payload: ${response.payload}");

    if (response.payload != null) {
      _refreshNotificationList();
      _handleNotificationTap(response.payload!);
    }
  }

  @pragma('vm:entry-point')
  static void _onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
    developer.log("📲 Notification clicked (background/terminated)");
    developer.log("Payload: ${response.payload}");
  }

  /// ✅ FIXED: Always pass notificationDetails
  Future<void> _showNotification(RemoteMessage message) async {
    if (message.notification == null) {
      developer.log("⚠️ No notification payload, skipping local notification");
      return;
    }

    final payload = jsonEncode({
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'time': message.sentTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'data': message.data,
    });

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch.remainder(1000000),
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? 'You have a new message',
      notificationDetails: notificationDetails, // ← FIXED: this was missing!
      payload: payload,
    );

    developer.log("✅ Local notification shown");
  }

  void _handleDataOnlyMessage(RemoteMessage message) {
    developer.log("🧾 Processing data-only message: ${message.data}");

    if (message.data.isNotEmpty) {
      if (message.data['type'] == 'chat_message') {
        _showCustomNotification(
          title: message.data['senderName'] ?? 'New Message',
          body: message.data['message'] ?? 'You have a new message',
          data: message.data,
        );
      }
    }
  }

  /// ✅ FIXED: Always pass notificationDetails + safer ID
  Future<void> _showCustomNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final payload = jsonEncode({
      'title': title,
      'body': body,
      'time': DateTime.now().toIso8601String(),
      'data': data ?? {},
    });

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
      title: title,
      body: body,
      notificationDetails: notificationDetails, // ← FIXED: this was missing!
      payload: payload,
    );

    developer.log("✅ Custom local notification shown");
  }

  void _handleNotificationTap(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      developer.log("🔍 Notification tapped with data: $data");

      final notificationData = data['data'] as Map<String, dynamic>?;

      if (notificationData != null) {
        _navigateBasedOnData(notificationData);
      }
    } catch (e) {
      developer.log("❌ Error parsing notification payload: $e");
    }
  }

  void _navigateToScreen(RemoteMessage message) {
    final title = message.notification?.title ?? 'No Title';
    final body = message.notification?.body ?? 'No Body';
    final data = message.data;

    developer.log("🔍 Navigate to screen with title: $title");
    developer.log("Navigation data: $data");

    _navigateBasedOnData(data);
  }

  void _navigateBasedOnData(Map<String, dynamic> data) {
    developer.log("🧭 Navigating based on data: $data");

    final type = data['type'] as String?;
    final typeId = data['typeId'] as String?;
    final senderId = data['senderId'] as String?;

    if (type == null) {
      developer.log("⚠️ No notification type found");
      return;
    }

    developer.log("Navigation type: $type, typeId: $typeId, senderId: $senderId");
    // TODO: Implement your actual navigation logic here
  }

  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      developer.log("📱 Current FCM Token: $token");
      ref.read(fcmTokenProvider.notifier).state = token;
      return token;
    } catch (e) {
      developer.log("❌ Error getting FCM token: $e");
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      ref.read(fcmTokenProvider.notifier).state = null;
      developer.log("🗑️ FCM token deleted");
    } catch (e) {
      developer.log("❌ Error deleting FCM token: $e");
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      developer.log("✅ Subscribed to topic: $topic");
    } catch (e) {
      developer.log("❌ Error subscribing to topic: $e");
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      developer.log("✅ Unsubscribed from topic: $topic");
    } catch (e) {
      developer.log("❌ Error unsubscribing from topic: $e");
    }
  }

  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    ref.read(notificationPermissionProvider.notifier).state = settings.authorizationStatus;
    return settings.authorizationStatus;
  }

  Future<bool> areNotificationsEnabled() async {
    final status = await getPermissionStatus();
    return status == AuthorizationStatus.authorized;
  }
}