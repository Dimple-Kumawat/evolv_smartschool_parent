import 'dart:convert';

import 'package:evolvu/Notice_SMS/notice_DeatilPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Import your model

import '../Teacher/Attachment.dart';

class NoticeDetailCard extends StatelessWidget {
  final String teacher;
  final String remarksubject;
  final String type;
  final String date;
  final String academic_yr;
  final String noticeID;
  final String shortName;
  final String classname;
  final String noticeDesc;
  final List<Attachment> attachment;


  const NoticeDetailCard({
    required this.teacher,
    required this.remarksubject,
    required this.type,
    required this.date,
    required this.academic_yr,
    required this.noticeID,
    required this.shortName,
    required this.classname,
    required this.noticeDesc,
    required this.attachment,

  });

  Future<void> updateReadStatus() async {
    String url = "";
    String academic_yr = "";
    String reg_id = "";
    String shortName = "";
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
    DateTime parsedDate = DateTime.parse(DateTime.now().toIso8601String());
    String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    final response = await http.post(
      Uri.parse(url + "notice_read_log_create"),
      body: {
        'notice_id': noticeID,
        'parent_id': reg_id,
        'read_date': formattedDate,
        'short_name': shortName
      },
    );
    if (response.statusCode == 200) {
      // Assuming the server returns a boolean to indicate success
      bool success = json.decode(response.body) as bool;
      if (success) {
        print('Read status updated successfully');
      } else {
        print('Failed to update read status');
      }
    } else {
      print('Failed to update read status');
    }
  }


  @override
  Widget build(BuildContext context) {
    updateReadStatus();

    return WillPopScope(
      onWillPop: () async {
        // Pop until reaching the HistoryTab route
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
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
              SizedBox(height: 80.h),
              Text(
                "Notice/SMS Details",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 6.h),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: NoticeDetailPage(
                        noticeInfo: NoticeInfo(
                            classname:classname,
                            date:date,
                          subject:remarksubject,
                          description:noticeDesc,
                          attachment:attachment,
                          noticeId:noticeID,

                        ),

                        // showAttachments: type == 'notice',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
