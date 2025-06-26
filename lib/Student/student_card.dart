import 'dart:convert';
import 'dart:developer';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';

import '../AcademicYearProvider.dart';
import '../Attendance/circleAttendance.dart';
import '../ExamTimeTable/examTimeTable.dart';
import 'StudentDashboard.dart';

class StudentCard extends StatefulWidget {
  final Function(int index) onTap;
  final String acd;
  const StudentCard({super.key, required this.onTap, required this.acd});

  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  List<Map<String, dynamic>> students = [];
  bool showNoDataMessage = false;
  String shortName = "";
  String AcademicResponse = "";
  String _message = "";
  String _message2 = "";
  String url = "";
  String academicYr = "";
  String academicYrCard = "";
  String regId = "";
  List<Map<String, dynamic>> examData = [];

  bool isBirthdayToday = false;
  List<String> birthdayStudentNames = [];

  List<dynamic> newsData = [];
  List<dynamic> EvolvUData = [];
  List<Map<String, dynamic>> importantLinks = [];
  bool isLoading = true;
  String message1_url = "";
  String message2_url = "";

  Future<void> _fetchTodaysExams() async {
    final academicYearProvider =
        Provider.of<AcademicYearProvider>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');

    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsParsed = json.decode(logUrls);
        academicYrCard = logUrlsParsed['academic_yr'];
        academicYearProvider.setAcademicYear(logUrlsParsed['academic_yr']);

        log('academic_yr ID: ${academicYearProvider.academic_yr}');
        academicYr = academicYearProvider.academic_yr;
        log('academic_yr ID: $academic_yr');

        regId = logUrlsParsed['reg_id'];
      } catch (e) {
        log('Error parsing log URLs: $e');
      }
    } else {
      log('Log URLs not found in SharedPreferences.');
    }
    fetchDashboardData(url);
    getSchoolNews(url); //get_news
    get_important_links(url);
    getEvolvuUpdate(url); //get_evolvu_updates

    try {
      final response = await http.post(
        Uri.parse('$url/get_todays_exam'),
        body: {
          'reg_id': regId,
          'academic_yr': academicYr,
          'short_name': shortName,
        },
      );

      log('get_todays_exam: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> apiResponse = json.decode(response.body);
        setState(() {
          // Use this data to dynamically display the exam data
          examData = List<Map<String, dynamic>>.from(apiResponse);
        });
      } else {
        log('Failed to load exam data with status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching exam data: $e');
    }
  }

  Future<void> _getSchoolInfo(BuildContext context) async {
    final academicYearProvider =
        Provider.of<AcademicYearProvider>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');

    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsParsed = json.decode(logUrls);
        academicYrCard = logUrlsParsed['academic_yr'];
        academicYearProvider.setAcademicYear(logUrlsParsed['academic_yr']);

        log('academic_yr ID: ${academicYearProvider.academic_yr}');
        academicYr = widget.acd;
        log('academic_yr ID: $academic_yr');

        regId = logUrlsParsed['reg_id'];

        _fetchTodaysExams();
      } catch (e) {
        log('Error parsing log URLs: $e');
      }
    } else {
      log('Log URLs not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        shortName = parsedData['short_name'];
        url = parsedData['url'];
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }

    if (url.isNotEmpty) {
      try {
        http.Response response = await http.post(
          Uri.parse("${url}get_childs"),
          body: {
            'reg_id': regId,
            'academic_yr': academicYr,
            'short_name': shortName,
          },
        );
        log('Response get_childs: ${response.body}');

        AcademicResponse = response.body;

        if (response.statusCode == 200) {
          if (response.body
              .contains("Student data not found in current academic year")) {
            setState(() {
              students = []; // Clear the students list
              showNoDataMessage = true; // Set a flag to show the message
            });
          } else {
            List<dynamic> apiResponse = json.decode(response.body);
            setState(() {
              students = List<Map<String, dynamic>>.from(apiResponse);
              showNoDataMessage = false; // Reset the flag
            });
          }

          List<dynamic> apiResponse = json.decode(response.body);
          setState(() {
            students = List<Map<String, dynamic>>.from(apiResponse);
            final today = DateTime.now();

            // Reset birthday list
            birthdayStudentNames = [];
            isBirthdayToday = false;

            for (var student in students) {
              String dobString = student['dob'];
              String studentName = student['student_name'];
              DateTime dob = DateTime.parse(dobString);

              log('Checking DOB for: $studentName, DOB: $dobString');
              if (dob.month == today.month && dob.day == today.day) {
                isBirthdayToday = true;
                birthdayStudentNames.add(studentName);
                log('Today is the birthday of: $studentName');
              }
            }

            // If no students have a birthday today, reset the birthday variables
            if (!isBirthdayToday) {
              birthdayStudentNames = [];
            }
          });
        } else {
          log('Failed to load students with status code: ${response.statusCode}');
        }
      } catch (e) {
        log('Error during HTTP request: $e');
      }
    } else {
      log('URL is empty, cannot make HTTP request.');
    }
  }

  Future<void> getSchoolNews(String url) async {
    final getSchoolNewsurl = Uri.parse(
        '${url}get_news'); // Assuming Config.newLogin is your base URL
    final body = {'short_name': shortName}; // Add required parameters
    log('getSchoolNews => $getSchoolNewsurl');

    try {
      final response = await http.post(getSchoolNewsurl, body: body);
      log('getSchoolNews response => ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          newsData = jsonData;
        });
      } else {
        log('getSchoolNews Error Response: ${response.statusCode}');
      }
    } catch (e) {
      log('getSchoolNews Error: $e');
    }
  }

  Future<void> getEvolvuUpdate(String url) async {
    final getEvolvuUpdatesurl = Uri.parse(
        '${url}get_evolvu_updates'); // Assuming Config.newLogin is your base URL
    final body = {'short_name': shortName};
    try {
      final response = await http.post(getEvolvuUpdatesurl, body: body);
      log('get_evolvu_updates => ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        log('get_evolvu_updates => ${response.body}');

        setState(() {
          EvolvUData = jsonData;
        });
      } else {
        log('Error Response: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  Future<void> get_important_links(String url) async {
    final importantLinksUrl = Uri.parse(
        '${url}get_important_links'); // Assuming Config.newLogin is your base URL
    final body = {
      'short_name': shortName,
      'type_link': 'private'
    }; // Add required parameters
    // log('getSchoolNews => $getSchoolNewsurl');

    try {
      final response = await http.post(importantLinksUrl, body: body);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          importantLinks =
              jsonData.map((data) => data as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        log('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getSchoolInfo(context);
  }

  Future<void> fetchDashboardData(String url) async {
    final url1 = Uri.parse('${url}show_icons_parentdashboard_apk');
    // log('Receipt URL: $shortName');

    try {
      final response = await http.post(
        url1,
        body: {'short_name': shortName},
      );

      if (response.statusCode == 200) {
        log('Stu Card-show_icons_parentdashboard_apk  ${response.body}');

        final Map<String, dynamic> data = jsonDecode(response.body);

        // Extract the required fields
        message1_url = data['message1_url'] ?? '';
        message2_url = data['message2_url'] ?? '';

        receiptUrl = data['receipt_url'] ?? '';
        paymentUrl = data['payment_url'] ?? '';
        smartchat_url = data['smartchat_url'] ?? '';

        String allowedUriChars = "@#&=*+-_.,:!?()/~'%";

        int msghide1 = data['message1'];
        int msghide2 = data['message2'];

        log('msghide1: $msghide1');
        log('msghide2: $msghide2');

        if (msghide1 == 1) {
          PostMsg1();
        }

        if (msghide2 == 1) {
          PostMsg2();
        }

        String uriUsername = customUriEncode(username, allowedUriChars);
        username = username;

        String secretKey = 'aceventura@services';

        String encryptedUsername = encryptUsername(username, secretKey);

        paymentUrlShare =
            "$paymentUrl?reg_id=$reg_id&academic_yr=$academic_yr&user_id=$uriUsername&encryptedUsername=$encryptedUsername&short_name=$shortName";

        log('message1_url : ${data['message1_url']}');
        log('message2_url : ${data['message2_url']}');

        log('Encrypted Username: $paymentUrlShare');
        log('Encrypted Username: $encryptedUsername');
        // Use these values as needed

        log('Receipt URL: $receiptUrl');
        log('Payment URL: $paymentUrl');
        log('smartchat_url : $smartchat_url');

        // You can store these values in variables or use them directly
      } else {
        log('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  Future<void> PostMsg1() async {
    final url = Uri.parse(message1_url);
    final body = {
      'short_name': shortName,
      'reg_id': regId,
      'academic_yr': academicYr
    }; // Add required parameters

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        log('PostMsg1 response: ${response.body}');
        final responseData = jsonDecode(response.body);
        // Handle successful response (if needed)
        final message =
            responseData; // Assuming the message is in the 'message' key

        setState(() {
          // Update the message state variable
          _message = message;
        });
      } else {
        log('Failed to call PostMsg1: ${response.statusCode}');
      }
    } catch (e) {
      log('Error calling PostMsg1: $e');
    }
  }

  Future<void> PostMsg2() async {
    final url = Uri.parse(message2_url);
    final body = {
      'short_name': shortName,
      'reg_id': regId,
      'academic_yr': academicYr
    }; // Add required parameters

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        log('PostMsg1 response: ${response.body}');
        final responseData = jsonDecode(response.body);
        // Handle successful response (if needed)
        final message =
            responseData; // Assuming the message is in the 'message' key

        setState(() {
          // Update the message state variable
          _message2 = message;
        });
      } else {
        log('Failed to call PostMsg1: ${response.statusCode}');
      }
    } catch (e) {
      log('Error calling PostMsg1: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final academicYearProvider = Provider.of<AcademicYearProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        // Pop until reaching the HistoryTab route
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.blue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (students.isEmpty || showNoDataMessage == true)
              Center(
                child: Card(
                  color: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      // Use SizedBox for Marquee
                      height: 25, // Set a fixed height for the Marquee
                      child: Marquee(
                        text: "Student data not found in current academic year",
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 20.0,
                        velocity: 100.0,
                        // Adjust scrolling speed
                        pauseAfterRound: const Duration(seconds: 2),
                        // Adjust pause duration
                        startPadding: 20.0,
                        // Adjust start padding
                        accelerationDuration: const Duration(seconds: 2),
                        // Adjust acceleration duration
                        accelerationCurve: Curves.linear,
                        // Adjust acceleration curve
                        decelerationDuration: const Duration(milliseconds: 900),
                        // Adjust deceleration duration
                        decelerationCurve:
                            Curves.easeOut, // Adjust deceleration curve
                      ),
                    ),
                  ),
                ),
              )
            else
              ListView(
                children: [
                  if (showNoDataMessage == true || academicYrCard != widget.acd)
                    academicCard(),
                  ListView.builder(
                    shrinkWrap: true,
                    // Important to wrap the builder within the ListView
                    physics: NeverScrollableScrollPhysics(),
                    // Prevent nested scrolling
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      return StudentCardItem(
                        firstName: students[index]['first_name'] ?? '',
                        midName: students[index]['mid_name'] ?? '',
                        lastName: students[index]['last_name'] ?? '',
                        rollNo: students[index]['roll_no'] ?? '',
                        className: (students[index]['class_name'] ?? '') +
                            (students[index]['section_name'] ?? ''),
                        cname: (students[index]['class_name'] ?? ''),
                        secname: (students[index]['section_name'] ?? ''),
                        classTeacher: students[index]['class_teacher'] ?? '',
                        gender: students[index]['gender'] ?? '',
                        studentId: students[index]['student_id'] ?? '',
                        classId: students[index]['class_id'] ?? '',
                        secId: students[index]['section_id'] ?? '',
                        shortName: shortName,
                        url: url,
                        academicYr: academicYearProvider.academic_yr,
                        onTap: widget.onTap,
                      );
                    },
                  ),

                  if (isBirthdayToday && birthdayStudentNames.isNotEmpty)
                    BirthDayCard(),
                  // Show the Birthday Card if today is someone's birthday
                  _buildMessageCard(_message),
                  _buildMessageCard2(_message2),
                  // Display the exam card once for all students
                  _buildExamCard(),

                  SizedBox(height: 4),

                  if (newsData.isNotEmpty) _buildNewsletterWidget(),

                  SizedBox(height: 4),
                  if (importantLinks.isNotEmpty) _buildImportantLinksWidget(),

                  SizedBox(height: 4),
                  if (EvolvUData.isNotEmpty) _buildEvolvuUpdatesWidget(),
                ],
              ),
          ],
        ),
        // floatingActionButton:
        //      FloatingActionButton.extended(
        //   onPressed: () {
        //     // In your main app or navigation
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => TransportHomeScreen(
        //           students: students,
        //           academicYear: academicYr,
        //           schoolShortName: shortName,
        //           apiUrl: 'https://your-api-url.com',
        //         ),
        //       ),
        //     );
        //   },
        //   icon: const Icon(Icons.bus_alert, color: Colors.black),
        //   label: const Text("Transport"),
        //   backgroundColor: Colors.white,
        // )
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    log('msgggggg $_message');
    if (message.isEmpty) return Container();

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            // Use SizedBox for Marquee
            height: 25, // Set a fixed height for the Marquee
            child: Marquee(
              text: message,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 20.0,
              velocity: 100.0,
              // Adjust scrolling speed
              pauseAfterRound: const Duration(seconds: 2),
              // Adjust pause duration
              startPadding: 20.0,
              // Adjust start padding
              accelerationDuration: const Duration(seconds: 1),
              // Adjust acceleration duration
              accelerationCurve: Curves.linear,
              // Adjust acceleration curve
              decelerationDuration: const Duration(milliseconds: 800),
              // Adjust deceleration duration
              decelerationCurve: Curves.easeOut, // Adjust deceleration curve
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard2(String message) {
    log('msgggggg2222 $_message2');
    if (message.isEmpty) return Container();

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            // Use SizedBox for Marquee
            height: 25, // Set a fixed height for the Marquee
            child: Marquee(
              text: message,
              // text: 'DEMO : This will use child.controller if its not null, and if it is null, it will create a new',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 20.0,
              velocity: 100.0,
              // Adjust scrolling speed
              pauseAfterRound: const Duration(seconds: 2),
              // Adjust pause duration
              startPadding: 20.0,
              // Adjust start padding
              accelerationDuration: const Duration(seconds: 1),
              // Adjust acceleration duration
              accelerationCurve: Curves.linear,
              // Adjust acceleration curve
              decelerationDuration: const Duration(milliseconds: 800),
              // Adjust deceleration duration
              decelerationCurve: Curves.easeOut, // Adjust deceleration curve
            ),
          ),
        ),
      ),
    );
  }

  /////Evolve Update/////

  Widget _buildEvolvuUpdatesWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 8, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                      child: Text(
                        'Evolvu Updates',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    content: SizedBox(
                      height: 200,
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(EvolvUData.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                _showDetailedEvolvuUpdatesDialog(index);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: _buildEvolvuUpdatePreviewCard(index),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: _buildInteractiveCard(
              Icons.update,
              'EvolvU Updates',
              Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolvuUpdatePreviewCard(int index) {
    final updateItem = EvolvUData[index];
    return SizedBox(
      width: 250,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   DateFormat('dd-MM-yy').format(
              //       DateTime.parse(updateItem['date_posted'] ?? 'No Date')),
              //   style: const TextStyle(
              //     fontSize: 14,
              //     color: Colors.black,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // SizedBox(height: 5),
              Text(
                updateItem['title'] ?? 'No Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10),
              Text(
                updateItem['description'] ?? 'No Description',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedEvolvuUpdatesDialog(int index) {
    final updateItem = EvolvUData[index];
    final dynamicImageList = updateItem['image_list'] as List<dynamic>;
    final List<String> dynamicImagePaths = dynamicImageList.map((image) {
      return "$durl/uploads/evolvu_updates/${updateItem['update_id']}/${image['image_name']}";
    }).toList();

    // Combine static and dynamic image paths
    final List<String> allImagePaths = [
      ...dynamicImagePaths, // Add dynamic images
      // ...imagePaths,        // Add static images
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Table(
                  columnWidths: {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("Title:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            updateItem['title'] ?? 'No Title',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("Description:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            updateItem['description'] ?? 'No Description',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (allImagePaths.isNotEmpty)
                  SizedBox(
                    height: 150, // Fixed height for the image box
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            List.generate(allImagePaths.length, (imageIndex) {
                          return GestureDetector(
                            onTap: () {
                              // Show the full-screen image when tapped
                              _showFullScreenImage(allImagePaths[imageIndex]);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SizedBox(
                                width: 150, // Fixed width for all image boxes
                                height: 150, // Fixed height for all image boxes
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      allImagePaths[imageIndex],
                                      fit: BoxFit.contain,
                                      // Ensures the entire image fits in the box
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(Icons.broken_image,
                                              size: 50, color: Colors.red),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

// Helper Function to Show Full-Screen Image
  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Close the dialog on tap
            },
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain, // Ensure proper scaling
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ///Important Link CODE////
  Widget _buildImportantLinksWidget() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(
                        child: Text(
                          'Important Links',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      content: SizedBox(
                        height: 200,
                        width: double.maxFinite,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: importantLinks.length,
                          itemBuilder: (context, index) {
                            final link = importantLinks[index];
                            return GestureDetector(
                              onTap: () {
                                _showDetailedLinkDialog(link);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: _buildLinkPreviewCard(
                                  title: link['title'] ?? 'No Title',
                                  description:
                                      link['description'] ?? 'No Description',
                                  date: DateFormat('dd-MM-yy').format(
                                      DateTime.parse(
                                          link['create_date'] ?? 'No Date')),
                                  url: link['url'] ?? '',
                                  type: link['type_link'] ?? 'Unknown',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: _buildInteractiveCard(
                Icons.link,
                'Important Links',
                Colors.blue,
              ),
            ),
          );
  }

  Widget _buildLinkPreviewCard({
    required String title,
    required String description,
    required String date,
    required String url,
    required String type,
  }) {
    return SizedBox(
      width: 250,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                'Created on: $date',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedLinkDialog(Map<String, dynamic> link) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            link['title'] ?? 'No Title',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blue,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Table(
                columnWidths: {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  _buildTableRow('Title', link['title'] ?? 'No Title'),
                  _buildTableRow(
                      'Description', link['description'] ?? 'No Description'),
                  _buildTableRow(
                      'Create Date',
                      DateFormat('dd-MM-yy').format(
                          DateTime.parse(link['create_date'] ?? 'No Date'))),
                  _buildTableRow('URL', link['url'] ?? '', isUrl: true),
                  _buildTableRow('Type', link['type_link'] ?? 'Unknown'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  TableRow _buildTableRow(String key, String value, {bool isUrl = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "$key: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: isUrl
              ? GestureDetector(
                  onTap: () async {
                    final Uri uri = Uri.parse(value);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch $value')),
                      );
                    }
                  },
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.blue),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(color: Colors.black54),
                ),
        ),
      ],
    );
  }

  Widget _buildNewsletterWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 8, 10, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Center(
                        child: Text(
                      'Newsletter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),
                    content: SizedBox(
                      height: 200,
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(newsData.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                _showDetailedNewsDialog(index);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: _buildNewsPreviewCard(index),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: _buildInteractiveCard(
              Icons.email,
              'Open Newsletter',
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsPreviewCard(int index) {
    final newsItem = newsData[index];
    return SizedBox(
      // Wrap with SizedBox
      width: 250,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd-MM-yy').format(
                    DateTime.parse(newsItem['date_posted'] ?? 'No Date')),
                // Formatted date
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                newsItem['title'] ?? 'No Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10),
              Text(
                newsItem['description'] ?? 'No Description',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedNewsDialog(int index) {
    final newsItem = newsData[index];
    final url = newsItem['url'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Table(
                columnWidths: {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text("Title:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          newsItem['title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text("Posted Date:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 5),
                        child: Text(
                          DateFormat('dd-MM-yyyy').format(
                            DateTime.parse(
                                newsItem['date_posted'] ?? 'No Date'),
                          ),
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text("Description:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          newsItem['description'] ?? 'No Description',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  if (url != null && url.isNotEmpty)
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text("URL:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GestureDetector(
                            onTap: () async {
                              final url = newsItem['url'];
                              if (url != null && url.isNotEmpty) {
                                final encodedUrl =
                                    Uri.encodeFull(url); // Encode the URL
                                final uri = Uri.parse(encodedUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode
                                        .externalApplication, // Explicitly set LaunchMode
                                  );
                                } else {
                                  // Handle the case where the URL cannot be launched
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Could not launch URL: $url')),
                                  );
                                }
                              } else {
                                // Handle the case where no URL is provided
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('No URL provided')),
                                );
                              }
                            },
                            child: Text(
                              newsItem['url'] ?? 'No URL',
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              // Add Image below the URL
              if (newsItem['image_name'] != null &&
                  newsItem['image_name'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Image.network(
                      "${durl}uploads/news/" +
                          newsItem['news_id'] +
                          "/" +
                          newsItem['image_name'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInteractiveCard(IconData icon, String text, Color color) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 242, 245, 245),
                  Color.fromARGB(255, 248, 250, 252),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 149, 214, 223).withOpacity(0.6),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 30),
                  SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                        fontSize: 22, color: Color.fromARGB(255, 0, 8, 19)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Positioned(
        //   right: 18,
        //   top: 31,
        //   child: Container(
        //     padding: EdgeInsets.all(6),
        //     decoration: BoxDecoration(
        //       color: Colors.red,
        //       shape: BoxShape.circle,
        //     ),
        //     child: Text(
        //       '1',
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontSize: 12,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget academicCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Card(
        color: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            // Use SizedBox for Marquee
            height: 25, // Set a fixed height for the Marquee
            child: Marquee(
              text: 'You Changed the current Academic Year to $academic_yr.',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 20.0,
              velocity: 100.0,
              // Adjust scrolling speed
              pauseAfterRound: const Duration(seconds: 2),
              // Adjust pause duration
              startPadding: 20.0,
              // Adjust start padding
              accelerationDuration: const Duration(seconds: 2),
              // Adjust acceleration duration
              accelerationCurve: Curves.linear,
              // Adjust acceleration curve
              decelerationDuration: const Duration(milliseconds: 900),
              // Adjust deceleration duration
              decelerationCurve: Curves.easeOut, // Adjust deceleration curve
            ),
          ),
        ),
      ),
    );
  }

  Widget BirthDayCard() {
    // Combine all birthday names in the format "Name1 and Name2"
    String combinedNames = birthdayStudentNames.join(" & ");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Show a dialog with an image when the text is clicked
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Happy Birthday $combinedNames'),
                    content: Image.asset('assets/hbd.jpg'),
                    // Image inside the dialog
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Close the dialog when the button is pressed
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              // Pointer cursor for clickable effect
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                // Smooth animation duration
                curve: Curves.easeInOut,
                // Smooth easing curve for animation
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 242, 245, 245),
                      Color.fromARGB(255, 248, 250, 252),
                    ], // Gradient background
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 149, 214, 223)
                          .withOpacity(0.6), // Glow effect
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(
                          0, 8), // Shadow position for elevation effect
                    ),
                  ],
                ),
                width: 400,
                // Fixed width
                height: 70,
                // Fixed height
                // padding: const EdgeInsets.all(20), // Padding for better content layout
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cake_sharp,
                        color: Colors.pinkAccent,
                        size: 45,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        // Wrap Text in a Column
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Align text to the start
                        children: [
                          const Text(
                            'Happy Birthday!!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent,
                            ),
                          ),
                          Text(
                            // Separate Text for combinedNames
                            combinedNames,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard() {
    if (examData.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // if(examData ==  '')
          // Title for the Exam section
          Text(
            'Exams',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 5.h),

          // Display exams grouped by student name, with each exam in a separate card
          Column(
            children: examData.map((exam) {
              String examSubject = exam['s_name'] ?? ''; // Fetch subject name
              bool isStudyLeave =
                  examSubject.isEmpty || exam['study_leave'] == 'Y';

              // Parse the date from the response
              DateTime examDate = DateTime.parse(exam['date']);
              DateTime today = DateTime.now();
              DateTime tomorrow = today.add(Duration(days: 1));

              // Determine if the date is Today, Tomorrow, or another day
              String displayDate;
              if (_isSameDay(examDate, today)) {
                displayDate = 'Today';
              } else if (_isSameDay(examDate, tomorrow)) {
                displayDate = 'Tomorrow';
              } else {
                displayDate = exam[
                    'date']; // Use the original date format if not Today or Tomorrow
              }

              // Wrap the card with InkWell to detect taps
              return InkWell(
                onTap: () {
                  // Navigate to the exam details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamTimeTablePage(
                          shortName: shortName,
                          academic_yr: exam['academic_yr'],
                          classId: exam['class_id'],
                          secId: exam['section_id'],
                          className: exam[
                              'class_name'] // Pass the exam data to the new page
                          ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: _isSameDay(examDate, tomorrow)
                      ? Colors.grey[300]
                      : Colors.white, // Gray for Tomorrow, white otherwise
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 26.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Student's first name
                        Expanded(
                          flex: 1,
                          child: Text(
                            exam['first_name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Exam date
                        Expanded(
                          flex: 0,
                          child: Text(
                            displayDate,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Show 'Study Leave' if subject name is empty, else show subject name
                        Expanded(
                          flex: 1,
                          child: Text(
                            isStudyLeave ? 'Study Leave' : examSubject,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isStudyLeave
                                  ? Colors.redAccent
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

// Helper method to check if two DateTime objects represent the same calendar day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class StudentCardItem extends StatefulWidget {
  final String firstName;
  final String midName;
  final String lastName;
  final String rollNo;
  final String className;
  final String cname;
  final String secname;
  final String classTeacher;
  final String gender;
  final String studentId;
  final String shortName;
  final String url;
  final String academicYr;
  final String classId;
  final String secId;
  final Function(int index) onTap;

  const StudentCardItem({
    super.key,
    required this.firstName,
    required this.midName,
    required this.lastName,
    required this.rollNo,
    required this.className,
    required this.cname,
    required this.secname,
    required this.classTeacher,
    required this.gender,
    required this.studentId,
    required this.shortName,
    required this.url,
    required this.academicYr,
    required this.classId,
    required this.secId,
    required this.onTap,
  });

  @override
  _StudentCardItemState createState() => _StudentCardItemState();
}

class _StudentCardItemState extends State<StudentCardItem> {
  String attendance = "Loading";
  late Future<List<StudentCardItem>> future;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> refresh() async {
    setState(() {
      _fetchAttendance(); // Refresh the homework notes
    });
  }

  Future<void> _fetchAttendance() async {
    http.Response response = await http.post(
      Uri.parse("${widget.url}get_student_attendance_percentage"),
      body: {
        'student_id': widget.studentId,
        'acd_yr': academic_yr,
        'short_name': widget.shortName,
      },
    );

    log('Response percentage: ${response.body}');

    if (response.statusCode == 200) {
      String apiValue = response.body;
      setState(() {
        attendance = apiValue;
      });
    } else {
      setState(() {
        attendance = "N/A";
      });
      log('Failed to load attendance');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var x = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentActivityPage(
              reg_id: reg_id,
              shortName: widget.shortName,
              studentId: widget.studentId,
              academicYr: academic_yr,
              url: widget.url,
              firstName: widget.firstName,
              rollNo: widget.rollNo,
              className: widget.className,
              cname: widget.cname,
              secname: widget.secname,
              classTeacher: widget.classTeacher,
              gender: widget.gender,
              classId: widget.classId,
              secId: widget.secId,
              attendance_perc: attendance,
            ),
          ),
        );
        if (x == null) return;
        widget.onTap(x as int);
        if (x == true) {
          refresh();
        }
      },
      child: Column(
        children: [
          _buildStudentInfoCard(),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),
        child: Card(
          elevation: 4, // Shadow depth for a floating effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(6.0), // Add padding inside the card
            child: Row(
              children: [
                // Student Image Section
                Column(
                  children: [
                    // if (GET_URL ==
                    //     "https://api.aceventura.in/evolvuURL/get_url")
                    //   BlinkingBadge(text: 'LIVE', textColor: Colors.red)
                    // else
                    //   BlinkingBadge(text: 'TEST', textColor: Colors.green),
                    SizedBox(height: 3.h),
                    SizedBox.square(
                      dimension: 60.w,
                      child: Image.asset(
                        widget.gender == 'F'
                            ? 'assets/girl.png'
                            : 'assets/boy.png',
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 4.w), // Add space between image and details

                // Student Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // if('2024-2025' == academic_yr)
                      // Text(
                      //   widget.firstName +
                      //       " " +
                      //       widget.midName +
                      //       " " +
                      //       widget.lastName,
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 14.sp,
                      //     color: Colors.black87,
                      //   ),
                      // ),

                      Text(
                        "${widget.firstName} ${widget.midName} ${widget.lastName}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.assignment_turned_in,
                              color: Colors.green, size: 14.sp),
                          SizedBox(width: 5.w),
                          Text(
                            'Roll No: ${widget.rollNo}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.class_, color: Colors.blue, size: 14.sp),
                          SizedBox(width: 5.w),
                          Text(
                            'Class: ${widget.className}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.red, size: 14.sp),
                          SizedBox(width: 5.w),
                          Text(
                            'Teacher: ${trimTeacherName(widget.classTeacher)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Attendance Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: attendance.isNotEmpty &&
                                double.tryParse(attendance) != null
                            ? CircularAttendanceIndicator2(
                                percentage: double.parse(attendance),
                              )
                            : CircularAttendanceIndicator2(
                                percentage:
                                    0, // Default to 0 if data is not available
                              ),
                      ),
                      SizedBox(height: 4.h),
                      if (attendance.isNotEmpty)
                        Text(
                          '$attendance%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to determine color based on percentage
  Color _getColor() {
    final double percentage = attendance as double;
    if (percentage < 0.35) {
      return Colors.red; // Red for below 35%
    } else if (percentage < 0.65) {
      return Colors.orange; // Orange for below 65%
    } else {
      return Colors.green; // Green for 65% and above
    }
  }

  String trimTeacherName(String name) {
    List<String> parts = name.split(' ');
    List<String> len = name.split('');
    if (parts.length > 2) {
      return '${parts[0]} ${parts[1]}'; // Return the first two parts
    }
    if (len.length > 15) {
      return parts[0]; // Return the first two parts
    }
    return name; // If there's no second space, return the original name
  }
}

class BlinkingBadge extends StatefulWidget {
  final String text;
  final Color textColor;

  const BlinkingBadge({super.key, required this.text, required this.textColor});

  @override
  _BlinkingBadgeState createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<BlinkingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Speed of blinking
      vsync: this,
    )..repeat(reverse: true); // Repeats animation continuously

    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                widget.text,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
