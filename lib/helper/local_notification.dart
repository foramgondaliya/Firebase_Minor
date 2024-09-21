import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationHelper {
  LocalNotificationHelper._();
  static final LocalNotificationHelper localNotificationHelper =
      LocalNotificationHelper._();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotifications() async {
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("mipmap/ic_launcher");
    DarwinInitializationSettings IOSInitializationSettings =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: IOSInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  //show simple notifications

  Future<void> showSimpleNotification(
      {required String title, required String dis}) async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
    );
    DarwinNotificationDetails IOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: IOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      dis,
      notificationDetails,
    );
  }

  Future<void> showScheduledNotification() async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
    );
    DarwinNotificationDetails IOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: IOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      "Simple Title",
      "Dummy Dis",
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 3)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  //show big picture notification
  Future<void> showBigPictureNotification() async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
      styleInformation: BigPictureStyleInformation(
        DrawableResourceAndroidBitmap("mipmap/ic_launcher"),
      ),
    );
    DarwinNotificationDetails IOSNotificationDetails =
        DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: IOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      1,
      "Simple Title",
      "Dummy dis",
      notificationDetails,
    );
  }
  //show Media style notification

  Future<void> showMediaStyleNotification() async {
    await initLocalNotifications();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "SN",
      "Simple Notification",
      priority: Priority.max,
      importance: Importance.max,
      colorized: true,
      color: Colors.red,
      largeIcon: DrawableResourceAndroidBitmap(
        "mipmap/ic_launcher",
      ),
      styleInformation: MediaStyleInformation(),
    );
    DarwinNotificationDetails IOSNotificationDetails =
        DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: IOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      1,
      "Simple Title",
      "Dummy dis",
      notificationDetails,
    );
  }
}
