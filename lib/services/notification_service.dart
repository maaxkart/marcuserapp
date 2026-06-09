import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  // =====================================================

  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // =====================================================

  static Future<void> initialize() async {

    FirebaseMessaging messaging =
        FirebaseMessaging.instance;

    // REQUEST PERMISSION

    await messaging.requestPermission(

      alert: true,

      badge: true,

      sound: true,
    );

    // TOKEN

    String? token =
    await messaging.getToken();

    print("FCM TOKEN : $token");

    // =====================================================
    // ANDROID INIT
    // =====================================================

    const AndroidInitializationSettings
    androidInitializationSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings
    initializationSettings =
    InitializationSettings(

      android:
      androidInitializationSettings,
    );

    // =====================================================
    // INITIALIZE LOCAL NOTIFICATION
    // =====================================================

    await flutterLocalNotificationsPlugin
        .initialize(
      initializationSettings,
    );

    // =====================================================
    // FOREGROUND MESSAGE
    // =====================================================

    FirebaseMessaging.onMessage.listen(

          (RemoteMessage message) {

        showNotification(

          title:
          message.notification?.title ??
              "Notification",

          body:
          message.notification?.body ??
              "",
        );
      },
    );
  }

  // =====================================================

  static Future<void> showNotification({

    required String title,

    required String body,
  }) async {

    const AndroidNotificationDetails
    androidNotificationDetails =
    AndroidNotificationDetails(

      'high_importance_channel',

      'High Importance Notifications',

      importance: Importance.max,

      priority: Priority.high,
    );

    const NotificationDetails
    notificationDetails =
    NotificationDetails(

      android:
      androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin
        .show(

      0,

      title,

      body,

      notificationDetails,
    );
  }
}