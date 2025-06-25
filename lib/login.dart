import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:evolvu/username_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
// Update the import path accordingly
import 'package:shared_preferences/shared_preferences.dart';

import 'forgotPassword.dart';

class LogUrls {
  final String reg_id;
  final String user_id;
  final String academic_yr;
  final String role_id;
  final String name;
  final String answer_one;

  LogUrls(
      {required this.reg_id,
      required this.user_id,
      required this.academic_yr,
      required this.role_id,
      required this.name,
      required this.answer_one});

  factory LogUrls.fromJson(Map<String, dynamic> json) {
    return LogUrls(
        reg_id: json['reg_id'],
        user_id: json['user_id'],
        academic_yr: json['academic_yr'],
        role_id: json['role_id'],
        name: json['name'],
        answer_one: json['answer_one']);
  }

  // Method to serialize SchoolInfo object into JSON
  Map<String, dynamic> toJson() {
    return {
      'reg_id': reg_id,
      'name': name,
      'user_id': user_id,
      'academic_yr': academic_yr,
      'role_id': role_id,
      'answer_one': answer_one
    };
  }
}

class LoginPage extends StatefulWidget {
  final String emailstr;

  const LoginPage(this.emailstr, {super.key});

  @override
  _LoginState createState() => _LoginState();
}

String shortName1 = "";
String schoolnamestr = "";
String teacherApkUrl = "";
String academic_yr1 = "";

class _LoginState extends State<LoginPage> {
  String? _token;

  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();
  bool shouldShowText2 = false; // Set this based on your condition
  bool _passwordVisible = false;
  bool shouldShowText = false; // Set this based on your condition
  bool _isLoading = false; // Add this line
  String teacherApkUrl = "";
  String url = "";
  String? token;
  @override
  void initState() {
    super.initState();
    _getSchoolInfo();
    requestPermission(); // Request notification permission
    getToken(); // Get FCM token

    getDeviceId();
    email = TextEditingController(text: widget.emailstr);
    checkLoginStatus(); // Check login status when the login screen is initialized
  }

  Future<void> _getSchoolInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

        setState(() {
          shortName = parsedData['short_name'];
          url = parsedData['url'];
          durl = parsedData['project_url'];
          teacherApkUrl = parsedData['teacherapk_url']; // Ensure this updates
        });

        log('Updated School Info:');
        log('Short Name: $shortName');
        log('URL: $url');
        log('Project URL: $durl');
        log('Teacher APK URL: $teacherApkUrl');
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }
  }

  // Request Permission for Notifications
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
      debugPrint("Failed to fetch FCM token111111.");
    } else {
      log('User declined or has not accepted permission');
      debugPrint("Failed to fetch FCM token22222.");
    }
  }

  void getToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      token = await messaging.getToken();

      if (token != null) {
        debugPrint("FCM Token: $token");
      } else {
        debugPrint("Failed to fetch FCM token.");
      }
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
    }
  }

  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.androidId; // Returns the Android ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor; // Returns the iOS ID
    }
    return 'Unknown';
  }

  void logIn(String ema, String pass) async {
    setState(() {
      _isLoading = true; // Start the loading indicator
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? schoolInfoJson = prefs.getString('school_info');

      if (schoolInfoJson != null) {
        try {
          Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

          String schoolId = parsedData['school_id'];
          String name = parsedData['name'];
          shortName = parsedData['short_name'];
          schoolnamestr = parsedData['short_name'];
          url = parsedData['url'];
          String teacherApkUrl = parsedData['teacherapk_url'];
          String projectUrl = parsedData['project_url'];
          String defaultPassword = parsedData['default_password'];

          log('School ID: $schoolId');
          log('Name: $name');
          log('Short Name: $shortName');
          log('URL: $url');
          log('Teacher APK URL: $teacherApkUrl');
          log('Project URL: $projectUrl');
          log('Default Password: $defaultPassword');
        } catch (e) {
          log('Error parsing school info: $e');
        }
      } else {
        log('School info not found in SharedPreferences.');
      }

      String deviceId = await getDeviceId();
      log('Device ID: $url');

      http.Response response = await http.post(
        Uri.parse("${url}get_login"),
        body: {
          'user_id': ema,
          'password': pass,
          'short_name': shortName,
          'device_id': deviceId
        },
      );

      log('Response status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        log('Success');

        if (response.body.contains('"error":true')) {
          setState(() {
            shouldShowText = true;
          });
        } else {
          setState(() {
            shouldShowText = false;
          });

          // Parse the API response into SchoolInfo object
          LogUrls logUrls = LogUrls.fromJson(jsonDecode(response.body));

          // Convert SchoolInfo object to JSON
          String logDetJson = jsonEncode(logUrls.toJson());
          Map<String, dynamic> logUrls11 = jsonDecode(logDetJson);

          // Extract the academic_yr field
          String academicYr = logUrls11['academic_yr'];
          log('logDetJson===>  $academicYr');

          // Store JSON string in shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('logUrls', logDetJson);

          log('logDetJson===>  $logDetJson');

          // Store login status in SharedPreferences
          storeLoginStatus(true);
          // Navigate to QRScannerPage after successful login
          //**dashboard push */
          //  ElevatedButton(
          //             onPressed: () {
          //               Navigator.of(context).pushNamed(loginPage);
          //             },

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => ParentDashBoardPage(
                  academic_yr: academicYr, shortName: shortName),
            ),
            (Route<dynamic> route) => false, // This removes all previous routes
          );
        }
      } else {
        setState(() {
          shouldShowText = true;
        });

        log('Failed');
        // Handle failed login
      }
    } catch (e) {
      log('Exception: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop the loading indicator
      });
    }
  }

  // Store login status in SharedP
  // Store login status in SharedPreferences
  Future<void> storeLoginStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // Check login status
  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

        String schoolId = parsedData['school_id'];
        String name = parsedData['name'];
        shortName = parsedData['short_name'];
        schoolnamestr = parsedData['short_name'];
        url = parsedData['url'];
        teacherApkUrl = parsedData['project_url'];
        String projectUrl = parsedData['project_url'];
        String defaultPassword = parsedData['default_password'];
      } catch (e) {
        log('Error parsing school info: $e');
      }
    }

    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // If user is already logged in, navigate to QRScannerPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserNamePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String logoPath = '';
    // if(schoolnamestr == 'SACS'){

    logoPath = '${teacherApkUrl}uploads/logo.jpg';

    // } else if (schoolnamestr == 'HSCS'){
    //   logoPath = teacherApkUrl+'uploads/logo.jpg';
    // }
    String schoolName = schoolnamestr == 'HSCS'
        ? 'Holy Spirit Convent School'
        : 'St. Arnolds Central School';
    // log('Error parsing school info: $logoPath');

    return WillPopScope(
      onWillPop: () async {
        // Go back to the previous screen
        Navigator.pop(context);
        return Future.value(false); // Prevent default back button behavior
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/img.png', // Replace with your background image
                fit: BoxFit.cover,
              ),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Image.asset(
                        'assets/logo.png',
                        width: 200,
                        height: 140,
                      ),
                      // SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo with loading indicator
                            logoPath.isNotEmpty
                                ? Image.network(
                                    logoPath,
                                    width: 40,
                                    height: 40,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        // The image has loaded successfully

                                        Image.network(
                                          logoPath, // Replace with your small logo image
                                          width: 40,
                                          height: 40,
                                        );

                                        return child;
                                      }
                                      // Display a CircularProgressIndicator while loading
                                      return SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    (loadingProgress
                                                            .expectedTotalBytes ??
                                                        1)
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      // Display a local fallback image if network image fails
                                      return Image.asset(
                                        'assets/logo.png',
                                        width: 40,
                                        height: 40,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/logo.png',
                                    width: 40,
                                    height: 40,
                                  ),
                            SizedBox(width: 8),

                            // School name
                            schoolName.isNotEmpty
                                ? Text(
                                    schoolName,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    'EvolvU Smart Parent App',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      Image.asset(
                        'assets/school.png', // Replace with your logo image
                        width: 380,
                        height: 300,
                      ),
                      SizedBox(height: 30),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          enabled: false,
                          controller: email,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.person_outline),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: password,
                          obscureText:
                              !_passwordVisible, // Negate the visibility state
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.lock_person_outlined),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible =
                                      !_passwordVisible; // Toggle visibility state
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 20.0),
                          //   child: Checkbox(
                          //     value: _passwordVisible, // Use the same visibility state for the checkbox
                          //     onChanged: (bool? newValue) {
                          //       setState(() {
                          //         _passwordVisible = newValue ?? false;
                          //       });
                          //     },
                          //   ),
                          // ),
                          // Text(
                          //   'Show Password',
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //   ),
                          // ),
                          Spacer(), // Use Spacer to push the next widget to the end of the row
                          Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: TextButton(
                              onPressed: () {
                                // Fluttertoast.showToast(msg: "$shortName abcd $academic_yr");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ForgotPasswordPage(
                                          widget.emailstr,
                                          shortName: shortName,
                                          academic_yr: academic_yr)),
                                );

                                // Handle "Forgot password"
                              },
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Visibility(
                        visible:
                            shouldShowText, // Set this boolean based on your condition
                        child: Text(
                          'Login credentials are wrong. Please try again!',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            shouldShowText2, // Set this boolean based on your condition
                        child: Text(
                          'Please Enter Password!!',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // SizedBox(height: 10),
                      _isLoading
                          ? CircularProgressIndicator() // Show progress indicator when loading
                          : ElevatedButton(
                              onPressed: () {
                                if (password.text.toString().isEmpty) {
                                  setState(() {
                                    shouldShowText2 = true;
                                  });

                                  Fluttertoast.showToast(
                                    msg: 'Please Enter Password!!',
                                    backgroundColor: Colors.black45,
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                  );
                                } else {
                                  setState(() {
                                    shouldShowText2 = false;
                                  });
                                  logIn(email.text.toString(),
                                      password.text.toString());
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.blue, // Button background color
                                shape: StadiumBorder(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 72, vertical: 12),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                      SizedBox(height: 20),
                      Text(
                        'aceventuraservices@gmail.com',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
