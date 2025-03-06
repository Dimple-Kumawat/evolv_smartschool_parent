// import 'package:evolvu/login.dart';
// import 'package:evolvu/username_page.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'Magpie.dart';
// import 'Utils&Config/all_routs.dart';
// import 'package:http/http.dart' as http;

// import 'Utils&Config/api.dart';

// class ApiService {
//   static const String apiUrl = 'https://api.aceventura.in/demo/evolvuURL/get_url';

//   // Function to call the API and process the response
//   Future<String> fetchUrl() async {
//     try {
//       // Make the GET request
//       final response = await http.get(Uri.parse(GET_URL));

//       // Check if the request was successful (status code 200)
//       if (response.statusCode == 200) {
//         // Get the response body
//         String responseBody = response.body;

//         // Remove double quotes from the response
//         String baseUrl = responseBody.replaceAll('"', '');

//         // Unescape the JSON string (replace \/ with /)
//         baseUrl = baseUrl.replaceAll(r'\/', '/');

//         return baseUrl;
//       } else {
//         // Handle non-200 status codes
//         throw Exception('Failed to load data: ${response.statusCode}');
//       }
//     } catch (error) {
//       // Handle any errors that occur during the request
//       throw Exception('Error: $error');
//     }
//   }
// }

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// void main() async {

//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   try {
//     await Firebase.initializeApp();
//     debugPrint("Firebase initialized successfully");
//   } on FirebaseException catch (e) {
//     debugPrint("Firebase initialization failed: ${e.message}");
//   } catch (e) {
//     debugPrint("Firebase initialization failed: $e"); // Log the entire error for further debugging
//   }

//   runApp(MyApp());
// }


// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(368, 892),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           onGenerateRoute: RouterConfigs.onGenerateRoutes,
//           home: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.pink, Colors.blue],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//             child: UserNamePage(),
//           ),
//         );
//       },
//     );
//   }
// }