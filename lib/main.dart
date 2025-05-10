import 'package:evolvu/username_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import 'AcademicYearProvider.dart';
import 'Utils&Config/all_routs.dart';
import 'package:http/http.dart' as http;

import 'Utils&Config/api.dart';

class ApiService {
  static const String apiUrl = 'https://api.aceventura.in/demo/evolvuURL/get_url';

  // Function to call the API and process the response
  Future<String> fetchUrl() async {
    try {
      // Make the GET request
      final response = await http.get(Uri.parse(GET_URL));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Get the response body
        String responseBody = response.body;

        // Remove double quotes from the response
        String baseUrl = responseBody.replaceAll('"', '');

        // Unescape the JSON string (replace \/ with /)
        baseUrl = baseUrl.replaceAll(r'\/', '/');

        return baseUrl;
      } else {
        // Handle non-200 status codes
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors that occur during the request
      throw Exception('Error: $error');
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully");
  } on FirebaseException catch (e) {
    debugPrint("Firebase initialization failed: ${e.message}");
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings()
  );


  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Handle notification tap
      if (response.payload != null) {
        // Open the file using the open_file package
        final filePath = response.payload!;
        final result = await OpenFile.open(filePath);

        // Check if the file was opened successfully
        if (result.type != ResultType.done) {
          // Show an error message if the file could not be opened
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('Failed to open file: ${result.message}'),
            ),
          );
        }
      }
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AcademicYearProvider()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(368, 892),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
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

