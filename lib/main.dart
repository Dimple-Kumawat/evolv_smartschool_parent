import 'package:evolvu/firebase_options.dart';
import 'package:evolvu/login.dart';
import 'package:evolvu/username_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Magpie.dart';
import 'Utils&Config/all_routs.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //await setupFlutterNotifications();
  // showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint('Handling a background message ${message.messageId}');
}

bool isFlutterLocalNotificationsInitialized = false;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    debugPrint("Firebase initialized successfully");
  } on FirebaseException catch (e) {
    debugPrint("Firebase initialization failed: ${e.message}");
  } catch (e) {
    debugPrint(
      "Firebase initialization failed: $e",
    );
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future requestPermission() async {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }
    }

    Future<void> getToken() async {
      try {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        var token = await messaging.getToken();

        if (token != null) {
          debugPrint("FCM Token: $token");
        } else {
          debugPrint("Failed to fetch FCM token.");
        }
      } catch (e) {
        debugPrint("Error fetching FCM token: $e");
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestPermission();
      await getToken();
    });
    return ScreenUtilInit(
      designSize: const Size(368, 892),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouterConfigs.onGenerateRoutes,
          home: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: UserNamePage(),
          ),
        );
      },
    );
  }
}
