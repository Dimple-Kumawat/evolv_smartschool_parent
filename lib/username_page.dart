import 'dart:convert';

import 'package:evolvu/login.dart';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;

import 'main.dart';

class SchoolInfo {
  final String schoolId;
  final String name;
  final String shortName;
  final String url;
  final String teacherApkUrl;
  final String projectUrl;
  final String defaultPassword;

  SchoolInfo({
    required this.schoolId,
    required this.name,
    required this.shortName,
    required this.url,
    required this.teacherApkUrl,
    required this.projectUrl,
    required this.defaultPassword,
  });

  // Method to deserialize JSON into SchoolInfo object
  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      schoolId: json['school_id'],
      name: json['name'],
      shortName: json['short_name'],
      url: json['url'],
      teacherApkUrl: json['teacherapk_url'],
      projectUrl: json['project_url'],
      defaultPassword: json['default_password'],
    );
  }

  // Method to serialize SchoolInfo object into JSON
  Map<String, dynamic> toJson() {
    return {
      'school_id': schoolId,
      'name': name,
      'short_name': shortName,
      'url': url,
      'teacherapk_url': teacherApkUrl,
      'project_url': projectUrl,
      'default_password': defaultPassword,
    };
  }
}

class UserNamePage extends StatefulWidget {
  const UserNamePage({super.key});

  @override
  _LoginDemoState createState() => _LoginDemoState();
}

class _LoginDemoState extends State<UserNamePage> {
  late BuildContext _context;
  String BaseURl = "";
  String packageInfoVar = "";

  @override
  void initState() {
    super.initState();
    // email = TextEditingController(text: widget.emailstr);
    checkLoginStatus();

    getURL();

    // _getSchoolInfo();
// Check login status when the login screen is initialized
  }

// Define a class to represent the user's school information

  TextEditingController email = TextEditingController();

  bool shouldShowText = false; // Set this based on your condition
  bool shouldShowText2 = false; // Set this based on your condition
  bool _isLoading = false; // Add this line

// Modify your login function to store school info in shared preferences
  void loginfun(String emailstr) async {
    setState(() {
      _isLoading = true; // Start the loading indicator
    });

    try {
      log('emailstr body: $BaseURl');

      Response response = await post(
        Uri.parse('$BaseURl/validate_user'),
        body: {'user_id': emailstr},
      );

      log('Response status code: ${response.statusCode}');
      log('Response body: ${response.body}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        log('Success');

        List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty && responseData.isNotEmpty) {
          // Assuming responseData contains the required data
          // Convert the first item in the list to a SchoolInfo object
          Map<String, dynamic> data = responseData[0];
          SchoolInfo schoolInfo = SchoolInfo.fromJson(data);

          // Convert SchoolInfo object to JSON
          String schoolInfoJson = jsonEncode(schoolInfo.toJson());
          log('School Info JSON: $schoolInfoJson');

          // Store JSON string in shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('school_info', schoolInfoJson);
          await _getSchoolInfo();
          // Navigate to the login screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginPage(emailstr)),
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Invalid User ID!!',
            backgroundColor: Colors.black45,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
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

  String shortName = "";
  String academic_yr = "";
  String reg_id = "";
  String user_id = "";
  String url = "";
  String durl = "";

  Future<void> _getSchoolInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');
    log('logUrls====\\\\: $logUrls');
    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        log('logUrls====\\\\11111: $logUrls');

        user_id = logUrlsparsed['user_id'];
        academic_yr = logUrlsparsed['academic_yr'];
        reg_id = logUrlsparsed['reg_id'];

        log('academic_yr ID: $academic_yr');
        log('reg_id: $reg_id');
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

        shortName = parsedData['short_name'];
        url = parsedData['url'];
        durl = parsedData['project_url'];
        checkLoginStatus(); // Check login status when the login screen is initialized

        log('Short Name: $shortName');
        log('URL: $url');
        log('URL: $durl');
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      //   If user is already logged in, navigate to QRScannerPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => ParentDashBoardPage(
                shortName: shortName, academic_yr: academic_yr)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _getSchoolInfo(); // Check login status when the login screen is initialized

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
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
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/logo.png', // Replace with your logo image
                      width: 200,
                      height: 140,
                    ),
                    Center(
                      child: Text(
                        'Don\'t miss any update from school.  Follow your child\'s activity and   progress with our smart Parent App.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 5),
                    Image.asset(
                      'assets/school_runing.png',
                      // Replace with your logo image
                      width: 400,
                      height: 340,
                    ),

                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: email,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.person_outline),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 5),
                    Visibility(
                      visible: shouldShowText,
                      // Set this boolean based on your condition
                      child: Text(
                        'Invalid UserId!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: shouldShowText2,
                      // Set this boolean based on your condition
                      child: Text(
                        'Please Enter User Name!!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator() // Show progress indicator when loading
                        : Container(
                            height: 40,
                            width: 180,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: TextButton(
                              onPressed: () {
                                if (email.text.toString().isEmpty) {
                                  setState(() {
                                    shouldShowText2 = true;
                                  });

                                  Fluttertoast.showToast(
                                    msg: 'Please Enter User Name!!',
                                    backgroundColor: Colors.black45,
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,
                                  );
                                } else {
                                  setState(() {
                                    shouldShowText2 = false;
                                  });
                                  loginfun(email.text.toString());
                                }
                              },
                              child: Text(
                                'Next',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),

                    SizedBox(height: 20),
                    Text(
                      'Fv1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(height: 50),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     Container(
                    //       width: 60,
                    //       height: 60,
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: AssetImage('assets/chemistry.png'),
                    //         ),
                    //       ),
                    //     ),
                    //     Container(
                    //       width: 60,
                    //       height: 60,
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: AssetImage('assets/nextimg.png'),
                    //         ),
                    //       ),
                    //     ),
                    //     Container(
                    //       width: 60,
                    //       height: 60,
                    //       decoration: BoxDecoration(
                    //         image: DecorationImage(
                    //           image: AssetImage('assets/cup.png'),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'aceventuraservices@gmail.com',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getURL() async {
    final apiService = ApiService();

    try {
      // Call the API and get the cleaned response
      BaseURl = await apiService.fetchUrl();
      log('BaseURl Cleaned URL: $BaseURl');
      getVersion(context);
    } catch (error) {
      // Handle any errors
      log('BaseURl Error: $error');
    }
  }

  Future<void> getVersion(BuildContext _context) async {
    log('latest_version11 => ${BaseURl + 'flutter_latest_version'}');

    final url = Uri.parse(BaseURl + 'flutter_latest_version');

    try {
      final response = await http.post(
        url,
        body: {'type': 'ios'},
      );
      log('latest_version => ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        log('latest_version => ${response.body}');

        if (jsonData is List && jsonData.isNotEmpty) {
          final packageInfo = await PackageInfo.fromPlatform();
          packageInfoVar = packageInfo.version;
          log('Current_version => ${packageInfo.version}');
          log('Current_version packageInfoVar=> ${packageInfoVar}');

          final androidVersion = jsonData[0]['lattest_version'] as String;
          final releaseNotes = jsonData[0]['release_notes'] as String;
          final forcedUpdate = jsonData[0]['forced_update'] as String;

          if (androidVersion != null) {
            log('Current_version => 22222 ${packageInfo.version}');

            final localAndroidVersion = packageInfo.version;

            // Compare versions
            if (_isVersionGreater(androidVersion, localAndroidVersion)) {
              log('Current_version => 3333 ${packageInfo.version}');

              if (forcedUpdate == 'N') {
                log('Current_version => NNNNN ${packageInfo.version}');

                showDialog(
                  context: _context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('V ${packageInfo.version}'),
                      content: Text(releaseNotes),
                      actions: [
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://play.google.com/store/apps/details?id=in.aceventura.evolvuschool'));
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              } else if (forcedUpdate == 'Y') {
                log('Current_version => 44444 ${packageInfo.version}');

                showDialog(
                  context: _context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('V ${packageInfo.version}'),
                      content: Text(releaseNotes),
                      actions: [
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://play.google.com/store/apps/details?id=in.aceventura.evolvuschool'));
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          }
        } else {
          log("Unexpected JSON format");
        }
      } else {
        log('Error Response: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

// Helper function to compare version strings
  bool _isVersionGreater(String newVersion, String currentVersion) {
    // Split version strings into parts
    List<int> newParts =
        newVersion.split('.').map((e) => int.parse(e)).toList();
    List<int> currentParts =
        currentVersion.split('.').map((e) => int.parse(e)).toList();

    // Compare each part of the version
    for (int i = 0; i < newParts.length; i++) {
      if (i >= currentParts.length) {
        // If current version has fewer parts, new version is greater
        return true;
      }
      if (newParts[i] > currentParts[i]) {
        return true;
      } else if (newParts[i] < currentParts[i]) {
        return false;
      }
    }

    // If all parts are equal, new version is not greater
    return false;
  }
}
