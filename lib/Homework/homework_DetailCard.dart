import 'dart:convert';
import 'dart:developer';

import 'package:evolvu/const/const_teacherNoteCard.dart';
import 'package:evolvu/Homework/homeWork_DeatilPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import your model

import '../Teacher/Attachment.dart';

class HomeWorkDetailCard extends StatelessWidget {
  final String subject;
  final String assignedDate;
  final String submissionDate;
  final String status;
  final String homeworkId;
  final String parentComment;
  final String className;
  final String description;
  final String studentId;
  final String comment_id;
  final String Tcomment;
  final String publishDate;
  final String academic_yr;
  final String shortName;
  final List<Attachment> imageList;

  const HomeWorkDetailCard({
    super.key,
    required this.subject,
    required this.shortName,
    required this.academic_yr,
    required this.assignedDate,
    required this.submissionDate,
    required this.status,
    required this.homeworkId,
    required this.parentComment,
    required this.className,
    required this.description,
    required this.imageList,
    required this.studentId,
    required this.comment_id,
    required this.publishDate,
    required this.Tcomment,
  });

  Future<void> updateReadStatus() async {
    String url = "";
    String academicYr = "";
    String regId = "";
    String shortName = "";
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');
    log('logUrls====\\\\: $logUrls');
    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        log('logUrls====\\\\11111: $logUrls');

        academicYr = logUrlsparsed['academic_yr'];
        regId = logUrlsparsed['reg_id'];

        log('academic_yr ID: $academicYr');
        log('reg_id: $regId');
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

        log('Short Name: $shortName');
        log('URL: $url');
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }
    DateTime parsedDate = DateTime.parse(DateTime.now().toIso8601String());
    String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    final response = await http.post(
      Uri.parse("${url}homework_read_log_create"),
      body: {
        'homework_id': homeworkId,
        'parent_id': regId,
        'read_date': formattedDate,
        'short_name': shortName
      },
    );
    if (response.statusCode == 200) {
      // Assuming the server returns a boolean to indicate success
      bool success = json.decode(response.body) as bool;
      if (success) {
        log('Read status updated successfully');
      } else {
        log('Failed to update read status');
      }
    } else {
      log('Failed to update read status');
    }
  }

  @override
  Widget build(BuildContext context) {
    updateReadStatus();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 50.h,
        title: Text(
          "$shortName EvolvU Smart Parent App($academic_yr)",
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
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
        child: Column(
          children: [
            SizedBox(height: 100.h),
            Text(
              "HomeWork Details",
              style: TextStyle(
                fontSize: 20.sp, // Adjusted for better visibility
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // SizedBox(height: 10.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.h),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Center(
                        child: HomeWorkDetailPage(
                          homeworkInfo: HomeworkInfo(
                            className: className,
                            subject: subject,
                            assignedDate: assignedDate,
                            submissionDate: submissionDate,
                            homework: description,
                            homeworkStatus: status,
                            teachersComment: Tcomment,
                            attachments: imageList,
                            homeworkId: homeworkId,
                            studentId: studentId,
                            comment_id: comment_id,
                            publishDate: publishDate,
                            parentComment: parentComment,
                          ),
                        ),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
