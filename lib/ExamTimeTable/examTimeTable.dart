import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class ExamTimeTablePage extends StatefulWidget {

  final String academic_yr;
  final String shortName;
  final String classId;
  final String secId;
  final String className;

  ExamTimeTablePage(
      {
        required this.academic_yr,
        required this.shortName,
        required this.classId,
        required this.secId,
        required this.className});

  @override
  _ExamTimeTablePageState createState() => _ExamTimeTablePageState();
}

class _ExamTimeTablePageState extends State<ExamTimeTablePage> {
  late Future<List<Period>> futurePeriods;

  @override
  void initState() {
    super.initState();
    futurePeriods = fetchExamTimeTable();
  }

  Future<List<Period>> fetchExamTimeTable() async {
    final response = await http.post(
      Uri.parse(url + 'display_exam_timetable'), // Replace with your actual URL
      body: {
        'short_name': widget.shortName, // Replace with actual short name
        'academic_yr': widget.academic_yr, // Replace with actual academic year
        'class_id': widget.classId // Replace with actual class ID
      },
    );

    if (!response.body.isEmpty) {
      print('display_exam_timetable Response body: ${response.body}');
      print('display_exam_timetable Response body: ${response.statusCode}');
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Period.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load exam timetable');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "Exam TimeTable",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 90),
                const SizedBox(height: 20),
                FutureBuilder<List<Period>>(
                  future: futurePeriods,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 250.0),
                        child: Center(child: Text("Exam Timetable is not available!",style: TextStyle(fontSize: 18),)),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("Exam Timetable is not available"));
                    } else {
                      // Get the exam name from the first Period object
                      String examName = snapshot.data!.first.name;

                      return Column(
                        children: [
                          Text(
                            "TimeTable of $examName (Class ${widget.className})",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Divider(color: Colors.white),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: snapshot.data!
                                  .map((period) => Column(
                                children: [
                                  PeriodRow(period: period),
                                  Divider(color: Colors.grey),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Period {
  final String subject;
  final String date;
  final String name;
  final bool isStudyLeave;

  Period(
      {required this.subject,
        required this.date,
        required this.name,
        this.isStudyLeave = false});

  factory Period.fromJson(Map<String, dynamic> json) {
    // When 'study_leave' is 'Y', force the subject to "Study Leave"
    bool isStudyLeave = json['study_leave'] == 'Y';
    String subject = isStudyLeave ? 'Study Leave' : (json['s_name'] ?? 'Unknown Subject');

    return Period(
      subject: subject,
      date: _formatDate(json['date']),
      name: json['name'],
      isStudyLeave: isStudyLeave,
    );
  }

  static String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }
}
class PeriodRow extends StatelessWidget {
  final Period period;

  const PeriodRow({required this.period});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                period.isStudyLeave ? Icons.book : Icons.school,
                color: period.isStudyLeave ? Colors.red : Colors.black,
              ),
              SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 150, // Set a fixed width for the subject
                ),
                child: Text(
                  period.subject, // Will show "Study Leave" if applicable
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: period.isStudyLeave ? Colors.red : Colors.black,
                  ),
                  maxLines: 5, // Allow text to wrap to the next line if necessary
                  overflow: TextOverflow.visible, // Ensure proper text wrapping
                ),
              ),
            ],
          ),
          Text(
            period.date,
            style: TextStyle(
              fontSize: 14.sp,
              color: period.isStudyLeave ? Colors.red : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
