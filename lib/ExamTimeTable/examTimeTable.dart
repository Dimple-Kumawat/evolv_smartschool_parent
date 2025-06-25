import 'dart:developer';

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

  const ExamTimeTablePage(
      {super.key,
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
      Uri.parse('${url}display_exam_timetable'), // Replace with your actual URL
      body: {
        'short_name': widget.shortName, // Replace with actual short name
        'academic_yr': widget.academic_yr, // Replace with actual academic year
        'class_id': widget.classId // Replace with actual class ID
      },
    );

    if (response.body.isNotEmpty) {
      log('display_exam_timetable Response body: ${response.body}');
      log('display_exam_timetable Response body: ${response.statusCode}');
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
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
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
                      // String examDescription = snapshot.data!.first.description;
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Add emoji or animation here
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: Image.asset(
                                  'assets/animations/nodata.gif',
                                  // Replace with your emoji or animation file
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Add spacing between emoji and text
                              Text(
                                'Exam Timetable is not Assigned',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Add emoji or animation here
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: Image.asset(
                                  'assets/animations/nodata.gif',
                                  // Replace with your emoji or animation file
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Add spacing between emoji and text
                              Text(
                                'Exam Timetable is not Assigned',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
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
                                          if (period.subject.isNotEmpty)
                                            Divider(color: Colors.grey),
                                        ],
                                      ))
                                  .toList(),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            child: Visibility(
                              visible: snapshot.data!.first.description
                                  .isNotEmpty, // Condition to check if description is not empty
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Description ',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white38,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: snapshot.data!.first.description
                                          .split('\n')
                                          .map(
                                            (line) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 6.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      line,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white38,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
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
  final String description; // Add description field

  Period({
    required this.subject,
    required this.date,
    required this.name,
    this.isStudyLeave = false,
    required this.description, // Initialize description
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    bool isStudyLeave = json['study_leave'] == 'Y';
    String subject =
        isStudyLeave ? 'Study Leave' : (json['s_name'] ?? 'Unknown Subject');

    return Period(
      subject: subject,
      date: _formatDate(json['date']),
      name: json['name'],
      isStudyLeave: isStudyLeave,
      description: json['description'] ?? '', // Parse description
    );
  }

  static String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }
}

class PeriodRow extends StatelessWidget {
  final Period period;

  const PeriodRow({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: period.subject.isNotEmpty,
      child: Padding(
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
                    maxLines: 5,
                    // Allow text to wrap to the next line if necessary
                    overflow:
                        TextOverflow.visible, // Ensure proper text wrapping
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
      ),
    );
  }
}
