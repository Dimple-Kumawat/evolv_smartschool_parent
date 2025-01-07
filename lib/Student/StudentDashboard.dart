import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:evolvu/Homework/homeWork_notePage.dart';
import 'package:evolvu/Remark/remark_notePage.dart';
import 'package:evolvu/login.dart';
import 'package:evolvu/Student/student_profile_page.dart';
import 'package:evolvu/Teacher/teacher_notePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:evolvu/Student/student_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../Attendance/attendance.dart';
import '../Attendance/circleAttendance.dart';
import '../ExamTimeTable/examTimeTable.dart';
import '../ExamTimeTable/timeTable.dart';
import '../Notice_SMS/notice_notePage.dart';
import '../QR/QR_Code.dart';
import '../ResultChart.dart';
import '../WebViewScreens/OnlineFeesPayment.dart';
import '../WebViewScreens/SmartChat_WebView.dart';
import '../common/rotatedDivider_Card.dart';
import '../result.dart';

class CardItem {
  final String? imageUrl;
  final String imagePath;
  final String title;
  final Function(BuildContext context) onTap;
  final bool showBadge; // Optional badge count
  final bool showBadgenotice; // Optional badge count
  final bool showBadgeTnote; // Optional badge count
  final bool showBadgeRemark; // Optional badge count

  CardItem({
    this.imageUrl,
    required this.imagePath,
    required this.title,
    required this.onTap,
    this.showBadge = false,
    this.showBadgenotice = false,
    this.showBadgeTnote = false,
    this.showBadgeRemark = false,
  });
}

class StudentActivityPage extends StatefulWidget {
  final String reg_id;
  final String shortName;
  final String studentId;
  final String academicYr;
  final String url;
  final String firstName;
  final String rollNo;
  final String className;
  final String cname;
  final String secname;
  final String classTeacher;
  final String gender;
  final String classId;
  final String secId;
  final String attendance_perc;

  StudentActivityPage({
    required this.reg_id,
    required this.shortName,
    required this.studentId,
    required this.academicYr,
    required this.url,
    required this.firstName,
    required this.rollNo,
    required this.className,
    required this.cname,
    required this.secname,
    required this.classTeacher,
    required this.gender,
    required this.classId,
    required this.secId,
    required this.attendance_perc,
  });

  @override
  _StudentActivityPageState createState() => _StudentActivityPageState();
}

class _StudentActivityPageState extends State<StudentActivityPage> {

  // late final List<String> absentDates = [ // Add more dates as needed
  // ];

  String shortName = "";
  String academic_yr = "";
  String reg_id = "";
  String url = "";
  String imageUrl = "";
  int unreadCount = 0;
  int noticeunreadCount = 0;
  int TnoteunreadCount = 0;
  int ReamrkunreadCount = 0;

  String receiptUrl = "";
  String Fname = "";
  String username = "";
  late int receiptButton;
  String paymentUrl="";
  String paymentUrlShare="";
  String smartchat_url="";
  int receipt_button=0;
  int online_fees_payment=0;
  int smartchat=0;
  String encryptedUsername="";

  int pageIndex = 0;
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    fetchUnreadHomeworkCount();
    fetchUnreadnotices();
    fetchUnreadTechetNotes();
    fetchUnreadRemark();
    fetchDashboardData();
  }

  Future<List<String>> getAbsentDates(String studentId) async {
    final url = '${widget.url}get_all_absent_dates'; // Replace with your actual endpoint

    // Prepare request parameters
    final params = {
      'student_id': studentId,
      'short_name': shortName
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: params,
      );

      print('Response get_all_absent_dates studentId: $studentId');
      print('Response get_all_absent_dates: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure absent_dates is a list of maps with a string field "absent_date"
        if (data is List && data.isNotEmpty && data[0] is Map<String, dynamic>) {
          final absentDates = data.map<String>((item) => item['absent_date'].toString()).toList();
          return absentDates;
        } else {
          throw Exception('Absent dates not found or invalid format');
        }
      } else {
        throw Exception('Failed to fetch absent dates: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching absent dates: $error');
    }
  }




  Future<void> _getSchoolInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');
    print('logUrls====\\\\\: $logUrls');
    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        print('logUrls====\\\\\11111: $logUrls');

        academic_yr = logUrlsparsed['academic_yr'];
        reg_id = logUrlsparsed['reg_id'];

        print('academic_yr ID: $academic_yr');
        print('reg_id: $reg_id');
      } catch (e) {
        print('Error parsing school info: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

        shortName = parsedData['short_name'];
        url = parsedData['url'];

        print('Short Name: $shortName');
        print('URL: $url');
      } catch (e) {
        print('Error parsing school info: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
    }

    http.Response response = await http.post(
      Uri.parse(url + "get_student"),
      body: {
        'student_id': widget.studentId,
        'academic_yr': academic_yr,
        'short_name': shortName
      },
    );

    print('child status code: ${response.statusCode}');
    print('child Response body====:>  ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> apiResponse = json.decode(response.body);
      if (apiResponse.isNotEmpty) {
        Map<String, dynamic> firstStudent = apiResponse[0];
         Fname = firstStudent['first_name'];
        print('Fname: $Fname');
      } else {
        print('No data found in API response.');
      }
    } else {
      print('Failed to fetch data: Status code ${response.statusCode}');
    }


    http.Response get_student_profile_images_details = await http.post(
      Uri.parse(url + "get_student_profile_images_details"),
      body: {
        'student_id': widget.studentId,
        'short_name': shortName
      },
    );

    // print('get_student_profile_images_details status code: ${get_student_profile_images_details.statusCode}');
    // print('get_student_profile_images_details Response body====:>  ${get_student_profile_images_details.body}');

    if (get_student_profile_images_details.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(get_student_profile_images_details.body);
      imageUrl = responseData['image_url'];
      print('Image URL: $imageUrl');
    if (imageUrl.hashCode == 404) {
      print('Image not found, using default image.');
      imageUrl = ""; // or set a default image URL if available
    } else {
      print('Error fetching image details: ${get_student_profile_images_details.statusCode}');
    }
  }
  }

  Future<void> fetchDashboardData() async {
    final url = Uri.parse(widget.url +'show_icons_parentdashboard_apk');
    // print('Receipt URL: $shortName');

    try {
      final response = await http.post(url,
        body: {'short_name': widget.shortName},
      );

      if (response.statusCode == 200) {
        print('response.body URL: ${response.body}');

        final Map<String, dynamic> data = jsonDecode(response.body);

        // Extract the required fields
        receiptUrl = data['receipt_url'];
        receiptButton = data['receipt_button'];
        receipt_button = data['receipt_button'];
        smartchat = data['smartchat'];
        online_fees_payment = data['online_fees_payment'];
        paymentUrl = data['payment_url'];
        smartchat_url = data['smartchat_url'];
        String ALLOWED_URI_CHARS = "@#&=*+-_.,:!?()/~'%";

        String URi_username = customUriEncode(username, ALLOWED_URI_CHARS);
        username = username;

        String secretKey = 'aceventura@services';

        String encryptedUsername = encryptUsername(username, secretKey);

        paymentUrlShare = paymentUrl + "?reg_id=" + widget.reg_id +
            "&academic_yr=" + widget.academicYr +  "&user_id=" + URi_username + "&encryptedUsername=" + encryptedUsername +"&short_name=" + shortName;

        print('Encrypted Username: $paymentUrlShare');
        print('Encrypted Username: $encryptedUsername');
        // Use these values as needed
        print('username URL: $username');
        print('Receipt URL: $receiptUrl');
        print('Receipt Button: $receiptButton');
        print('Payment URL: $paymentUrl');
        print('smartchat_url : $smartchat_url');

        // You can store these values in variables or use them directly
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> refreshDash() async {
    setState(() {
      fetchDashboardData();
    });
  }

  String customUriEncode(String input, String allowedChars) {
    final StringBuffer encoded = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      final String char = input[i];
      if (allowedChars.contains(char)) {
        encoded.write(char);  // Allow the character as-is
      } else {
        // Percent-encode the character
        final List<int> bytes = utf8.encode(char);
        for (final int byte in bytes) {
          encoded.write('%${byte.toRadixString(16).toUpperCase()}');
        }
      }
    }

    return encoded.toString();
  }
  String encryptUsername(String username, String secretKey) {
    // Combine the username and secretKey
    String combined = username + secretKey;

    // Convert the combined string to bytes
    List<int> bytes = utf8.encode(combined);

    // Perform SHA1 encryption
    Digest sha1Result = sha1.convert(bytes);

    // Return the encrypted value as a hexadecimal string
    return sha1Result.toString();
  }

  Future<int> fetchUnreadHomeworkCount() async {
    print('fetching unread remarks count: $reg_id');

    try {
      final response = await http.post(
        Uri.parse(widget.url + "get_count_of_unread_homeworks"),
        body: {
          'student_id': widget.studentId,
          'parent_id': widget.reg_id,
          'acd_yr': widget.academicYr,
          'short_name': widget.shortName
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        unreadCount = int.tryParse(data[0]['unread_homeworks']) ?? 0;
        print('fetchUnreadHomeworkCount: $unreadCount');

      } else {
        print('Failed to fetch unread remarks count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching unread remarks count: $e');
    }

    return unreadCount;
  }
  Future<int> fetchUnreadnotices() async {

    try {
      final response = await http.post(
        Uri.parse(widget.url + "get_count_of_unread_notices"),
        body: {
          'student_id': widget.studentId,
          'parent_id': widget.reg_id,
          'acd_yr': widget.academicYr,
          'short_name': widget.shortName
        },
      );

      if (response.statusCode == 200) {

        List<dynamic> data = json.decode(response.body);
        noticeunreadCount = int.tryParse(data[0]['unread_notices']) ?? 0;
        print('fetching unread noticeunreadCount count: $noticeunreadCount');

      } else {
        print('Failed to fetch unread noticeunreadCount count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching unread noticeunreadCount count: $e');
    }

    return noticeunreadCount;
  }
  Future<int> fetchUnreadTechetNotes() async {
    try {
      final response = await http.post(
        Uri.parse(widget.url + "get_count_of_unread_notes"),
        body: {
          'student_id': widget.studentId,
          'parent_id': widget.reg_id,
          'acd_yr': widget.academicYr,
          'short_name': widget.shortName
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          TnoteunreadCount = int.tryParse(data[0]['unread_notes']) ?? 0;
        });
        print('fetching unread TnoteunreadCount count: $TnoteunreadCount');
      } else {
        print('Failed to fetch unread TnoteunreadCount count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching unread TnoteunreadCount count: $e');
    }

    return TnoteunreadCount;
  }

  Future<int> fetchUnreadRemark() async {

    try {
      final response = await http.post(
        Uri.parse(widget.url + "get_count_of_unread_remarks"),
        body: {
          'student_id': widget.studentId,
          'parent_id': widget.reg_id,
          'acd_yr': widget.academicYr,
          'short_name': widget.shortName
        },
      );

      if (response.statusCode == 200) {

        List<dynamic> data = json.decode(response.body);
        ReamrkunreadCount = int.tryParse(data[0]['unread_remarks']) ?? 0;
        print('fetching unread ReamrkunreadCount count: $ReamrkunreadCount');

      } else {
        print('Failed to fetch unread ReamrkunreadCount count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching unread ReamrkunreadCount count: $e');
    }

    return ReamrkunreadCount;
  }


  @override
  Widget build(BuildContext context) {
    _context = context;

    refreshDash();
    final List<CardItem> cardItems = [
      CardItem(
        imagePath: widget.gender == 'F' ? 'assets/girl.png' : 'assets/boy.png', // Local fallback image
        title: 'Student Profile',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentProfilePage(studentId: widget.studentId,shortName: shortName,cname: widget.cname,
                secname: widget.secname,academic_yr: academic_yr
                ,),
            ),
          );
        },
      ),
      CardItem(
        imagePath: 'assets/teacher.png',
        title: 'Teacher Note',
        onTap: (context) async {
          // Navigate to the second screen and wait for the result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherNotePage(
                studentId: widget.studentId,
                shortName: shortName,
                academic_yr: academic_yr,
                classId: widget.classId,
                secId: widget.secId,
              ),
            ),
          );

          // Refresh the screen if result is returned or just refresh unconditionally
          if (result != null) {
            await fetchUnreadTechetNotes(); // Re-fetch the unread count
            setState(() {}); // Refresh the screen to update the UI
          }
        },
        showBadgeTnote: true,
      ),

      CardItem(
        imagePath: 'assets/books.png',
        title: 'Homework',
        onTap: (context) async {
          final result = await Navigator.push(
              context,
            MaterialPageRoute(
              builder: (context) => HomeWorkNotePage(studentId: widget.studentId,shortName: shortName,academic_yr: academic_yr
                  ,classId: widget.classId,secId:widget.secId),
            ),
          );
          if (result != null) {
            await fetchUnreadHomeworkCount(); // Re-fetch the unread count
            setState(() {}); // Refresh the screen to update the UI
          }
        },
        showBadge: true,
      ),

      CardItem(
        imagePath: 'assets/studying.png',
        title: 'Remark',
        onTap: (context) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RemarkNotePage(studentId: widget.studentId,shortName: shortName,academic_yr: academic_yr
                  ,classId: widget.classId,secId:widget.secId),
            ),
          );
          if (result != null) {
            await fetchUnreadRemark(); // Re-fetch the unread count
            setState(() {}); // Refresh the screen to update the UI
          }
        },
        showBadgeRemark: true,
      ),
      CardItem(
        imagePath: 'assets/notice.png',
        title: 'Notice/SMS',
        onTap: (context) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoticeNotePage(studentId: widget.studentId,shortName: shortName,academic_yr: academic_yr
                  ,classId: widget.classId,secId:widget.secId),
            ),
          );
          if (result != null) {
            await fetchUnreadnotices(); // Re-fetch the unread count
            setState(() {}); // Refresh the screen to update the UI
          }
        },
        showBadgenotice: true,
      ),
      // CardItem(
      //   imagePath: 'assets/calendar.png',
      //   title: 'Attendance',
      //   onTap: (context) {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => AttendancePage(),
      //       ),
      //     );
      //     },
      //   showBadgenotice: true,
      // ),

      CardItem(
        imagePath: 'assets/calendar.png',
        title: 'Exam/TimeTable',

        onTap: (context) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                scrollable: true,

                content:
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigator.of(context).pushNamed(timeTablePage);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeTablePage(studentId: widget.studentId,shortName: shortName,academic_yr: academic_yr
                                ,classId: widget.classId,secId:widget.secId, className: widget.className),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset( 'assets/calendar.png',),

                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text("TimeTable"),
                          )

                        ],
                      ),
                    ),

                    const SizedBox(height: 15,),
                    GestureDetector(
                      onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExamTimeTablePage(shortName: shortName,academic_yr: academic_yr
                                  ,classId: widget.classId,secId:widget.secId, className: widget.className,),
                            ),
                          );
                      },
                      child: Row(
                        children: [
                          SizedBox(
                              height: 50,
                              child: Image.asset('assets/examt.webp')),

                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text("ExamTimeTable"),
                          )

                        ],
                      ),
                    ),


                  ],
                ),

              );
            },
          );
        },

      ),

      CardItem(
        imagePath: '',
        title: 'Attendance',
        onTap: (BuildContext context) async {
          try {
            // Make API call to get absent dates
            final absentDates = await getAbsentDates(widget.studentId); // Await the result

            // Show dialog with absent dates
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Absent Dates'),
                  content: SizedBox(
                    child: ListView.builder(
                      itemCount: absentDates.length, // Ensure this is an int
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            absentDates[index], // Display absent date
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          } catch (error) {
            // Handle errors here (e.g., show a snackbar or error message)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Absent date List is Empty...')),
            );
          }
        },
      ),

      if(smartchat == 1)
      CardItem(
        imagePath: 'assets/smartchat.png',
        title: 'Smart Chat',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPage(studentId: widget.studentId,shortName: shortName,academicYr: academic_yr
                  ,classId: widget.classId,secId:widget.secId,smartchat_url:smartchat_url),
            ),
          );
        },
      ),

      CardItem(
        imagePath: 'assets/result.png',
        title: 'Result',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(studentId: widget.studentId,shortName: shortName,academicYr: academic_yr
                  ,classId: widget.classId,secId:widget.secId,Fname: Fname,className: widget.className),
            ),
          );
        },
      ),

      CardItem(
        imagePath: 'assets/chart.png',
        title: 'Result Chart',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultChart(studentId: widget.studentId,shortName: shortName,academicYr: academic_yr
                  ,classId: widget.classId,secId:widget.secId,className: widget.className),
            ),
          );
        },
      ),

      if(online_fees_payment == 1)
      CardItem(
        imagePath: 'assets/cashpayment.png',
        title: 'Fees Payment',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebview(
                  regId: widget.reg_id,paymentUrlShare:paymentUrlShare,receiptUrl:receiptUrl,shortName: shortName,academicYr: academic_yr,receipt_button:receipt_button),
            ),
          );
        },
      ),
      // CardItem(
      //   imagePath: 'assets/new_module.png', // Path to the new module image
      //   title: 'New Module',
      //   onTap: (context) {
      //     Navigator.pushNamed(context, '/newModulePage'); // New module page route
      //   },
      // ),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Pop until reaching the HistoryTab route
        Navigator.pop(context, true);
        return false;
      },
      child: FutureBuilder(
        future: _getSchoolInfo(),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.blue,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                "$shortName EvolvU Smart Parent App ($academic_yr)",
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
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
                Positioned(
                  top: 110,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Padding(
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
                                  SizedBox.square(
                                    dimension: 70.w,
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl + '?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Image.asset(
                                        widget.gender == 'M' ? 'assets/boy.png' : 'assets/girl.png',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w), // Add space between image and details

                                  // Student Info Section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.firstName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        Row(
                                          children: [
                                            Icon(Icons.assignment_turned_in, color: Colors.green, size: 14.sp),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Student Activity",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          crossAxisSpacing: 2.0,
                          mainAxisSpacing: 1.2,
                          padding: const EdgeInsets.only(top: 10,left: 20,right: 30),
                          children: List.generate(cardItems.length, (index) {
                            final item = cardItems[index];
                            return Card(
                              color: Colors.white,
                                child: Stack(
                                alignment: Alignment.center,
                                children: [
                                InkWell(
                                  onTap: () => item.onTap(context),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (item.title == 'Attendance')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: widget.attendance_perc.isNotEmpty && double.tryParse(widget.attendance_perc) != null
                                              ? CircularAttendanceIndicator(
                                            percentage: double.parse(widget.attendance_perc) / 100, // Pass percentage as a fraction (0 to 1)
                                          )
                                              : CircularAttendanceIndicator(
                                            percentage: 0, // Default to 0 if data is not available
                                          ),
                                        )
                                        // [{"absent_date":"11-09-2024"}]
                                      else
                                      Image.asset(
                                        item.imagePath,
                                        height: 50,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                  if (item.showBadge) // Conditionally show the badge
                                  if (unreadCount != 0) // Conditionally show the badge
                                    Positioned(
                                      top: 1,
                                      right: 6,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          '$unreadCount',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (item.showBadgenotice)
                                    if (noticeunreadCount != 0)// Conditionally show the badge
                                    Positioned(
                                      top: 1,
                                      right: 6,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          '$noticeunreadCount',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (item.showBadgeTnote)
                                    if (TnoteunreadCount != 0)// Conditionally show the badge
                                    Positioned(
                                      top: 1,
                                      right: 6,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          '$TnoteunreadCount',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ), if (item.showBadgeRemark)
                                    if (ReamrkunreadCount != 0)// Conditionally show the badge
                                    Positioned(
                                      top: 1,
                                      right: 6,
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          '$ReamrkunreadCount',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                                ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            bottomNavigationBar: buildMyNavBar(context),
          );
        },


      ),
    );
  }
  String trimTeacherName(String name) {
    List<String> parts = name.split(' ');
    if (parts.length > 2) {
      return '${parts[0]} ${parts[1]}'; // Return the first two parts
    }
    return name; // If there's no second space, return the original name
  }

Container buildMyNavBar(BuildContext context) {
  return Container(
    margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3)),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(icon: Icons.dashboard, label: 'Dashboard', index: 0),
        _buildNavItem(icon: Icons.calendar_month, label: 'Calendar', index: 1),
        _buildNavItem(icon: Icons.person, label: 'Profile',index: 3), // Center icon for Profile
        _buildNavItem(icon: Icons.qr_code, label: 'QR', index: 4),
      ],
    ),
  );
}

Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    bool isSelected = pageIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 4) {
          // Navigate to the QR Code screen without modifying pageIndex
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRCodeScreen(regId: reg_id)),
          );
        } else {
          Navigator.of(context).pop(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.blue.shade400 : Colors.grey, size: 26),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade400 : Colors.grey,
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}