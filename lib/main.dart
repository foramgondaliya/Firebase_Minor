import 'dart:developer';

import 'package:firebase_chat_app/Screens/HomePage.dart';
import 'package:firebase_chat_app/Screens/Login_page.dart';
import 'package:firebase_chat_app/Screens/chat_app.dart';
import 'package:firebase_chat_app/Screens/spash_screen.dart';
import 'package:firebase_chat_app/firebase_options.dart';
import 'package:firebase_chat_app/helper/local_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> onBGFCM(RemoteMessage remoteMessage) async {
  log("========BACKGROUND NOTIFICATION=========");
  log("Title: ${remoteMessage.notification!.title}");
  log("Body: ${remoteMessage.notification!.body}");

  log("Custom Data: ${remoteMessage.data}");
  log("=================================");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
    log("========FOREGROUND NOTIFICATION=========");
    log("Title: ${remoteMessage.notification!.title}");
    log("Body: ${remoteMessage.notification!.body}");

    log("Custom Data: ${remoteMessage.data}");
    log("=================================");
    await LocalNotificationHelper.localNotificationHelper
        .showSimpleNotification(
            title: remoteMessage.notification!.title!,
            dis: remoteMessage.notification!.body!);
  });

  FirebaseMessaging.onBackgroundMessage(onBGFCM);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splash_Screen',
      routes: {
        '/': (context) => HomePage(),
        'Login_Page': (context) => Login_Page(),
        'ChatApp': (context) => ChatApp(),
        'splash_Screen': (context) => SplashScreen(),
      },
    ),
  );
}
