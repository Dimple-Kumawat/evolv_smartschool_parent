import 'package:evolvu/login.dart';
import 'package:evolvu/username_page.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Magpie.dart';
import 'Utils&Config/all_routs.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   // paste the code copied
  //   // from Firebase SDK below.
  //     options: const FirebaseOptions(
  //         apiKey: "AIzaSyC3BF5vWaxhD8YZBLNzkve5HWqNW5ZtQjg",
  //         authDomain: "flutterparentapp.firebaseapp.com",
  //         projectId: "flutterparentapp",
  //         storageBucket: "flutterparentapp.appspot.com",
  //         messagingSenderId: "997012539911",
  //         appId: "1:997012539911:web:24d67a0087ff2034cef8a2",
  //         measurementId: "G-3GX4YEY542")
  // );

  runApp(MyApp());

  // Initialize notification settings
  // final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // final initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  //
  // flutterLocalNotificationsPlugin.initialize(
  //   initializationSettings,
  //   onSelectNotification: (payload) async {
  //     if (payload != null) {
  //       OpenFile.open(payload);  // Open the downloaded file
  //     }
  //   },
  // );
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
