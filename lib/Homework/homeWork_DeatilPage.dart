import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Teacher/Attachment.dart';

class HomeworkInfo {
  final String className;
  final String subject;
  final String assignedDate;
  final String submissionDate;
  final String homework;
  final String homeworkStatus;
  final String teachersComment;
  final String homeworkId;
  final String studentId;
  final String comment_id;
  final String parentComment;
  final String publishDate;
  final List<Attachment> attachments;

  HomeworkInfo({
    required this.className,
    required this.subject,
    required this.assignedDate,
    required this.submissionDate,
    required this.homework,
    required this.homeworkStatus,
    required this.teachersComment,
    required this.homeworkId,
    required this.studentId,
    required this.comment_id,
    required this.parentComment,
    required this.publishDate,
    required this.attachments,
  });
}

class HomeWorkDetailPage extends StatefulWidget {
  final HomeworkInfo homeworkInfo;

  HomeWorkDetailPage({required this.homeworkInfo});

  @override
  _HomeWorkDetailPageState createState() => _HomeWorkDetailPageState();
}

class _HomeWorkDetailPageState extends State<HomeWorkDetailPage> {
  late TextEditingController _parentCommentController;
  late TextEditingController _teacherCommentController;
  String shortName = "";
  String academic_yr = "";
  String reg_id = "";
  String projectUrl = "";
  String url = "";

  @override
  void initState() {
    super.initState();
    _parentCommentController =
        TextEditingController(text: widget.homeworkInfo.parentComment);
    _teacherCommentController = TextEditingController();
    _getProjectUrl();
  }

  Future<String?> _getProjectUrl() async {
    final prefs = await SharedPreferences.getInstance();
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
    String? schoolInfoJson = prefs.getString('school_info');
    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        projectUrl = parsedData['project_url'];
        shortName = parsedData['short_name'];
        url = parsedData['url'];
        return url;
      } catch (e) {
        print('Error parsing school info: $e');
        return null;
      }
    } else {
      print('School info not found in SharedPreferences.');
      return null;
    }
  }

  Future<void> _updateHomework() async {
    if (widget.homeworkInfo.homeworkId.isEmpty) {
      print('Homework ID is null, not sending request to server.');
      return;
    }
    String? projectUrl = await _getProjectUrl();
    if (projectUrl == null) {
      print('Failed to retrieve project URL.');
      return;
    }
    print('Homework ID is nullprojectUrl, $projectUrl');

    try {
      final http.Response response = await http.post(
        Uri.parse(projectUrl + 'update_homework'),
        body: {
          'short_name': shortName,
          'parent_id': reg_id,
          'student_id': widget.homeworkInfo.studentId,
          'homework_id': widget.homeworkInfo.homeworkId,
          'comment_id': widget.homeworkInfo.comment_id,
          'parent_comment': _parentCommentController.text,
        },
      );

      if (response.statusCode == 200) {
        print('Homework updated successfully.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Homework updated successfully.'),
          ),
        );

        Navigator.pop(context);
      } else {
        print('Failed to update homework. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update homework.'),
          ),
        );
      }
    } catch (e) {
      print('Failed to update homework: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update homework: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(widget.homeworkInfo.assignedDate);
    DateTime parsedDate1 = DateTime.parse(widget.homeworkInfo.submissionDate);
    String formatted_assignedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    String formatted_submissionDate = DateFormat('dd-MM-yyyy').format(parsedDate1);
    return Container(
      height: 720.h,
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            // spreadRadius: 3,
            blurRadius: 5,
            //offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Class: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextSpan(
                    text: widget.homeworkInfo.className,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Subject: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextSpan(
                    text: widget.homeworkInfo.subject,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Assigned Date: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextSpan(
                    text: formatted_assignedDate,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Submission Date: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextSpan(
                    text: formatted_submissionDate,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Homework: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextSpan(
                    text: widget.homeworkInfo.homework,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Homework Status: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextSpan(
                    text: widget.homeworkInfo.homeworkStatus,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Teacher Comment: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  TextSpan(
                    text: widget.homeworkInfo.teachersComment,
                    style: TextStyle(
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Parent\'s Comment:',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.h),
            Container(
              height: 120.h,
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 240, 238, 238),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TextField(
                controller: _parentCommentController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type here...',
                ),
                maxLines: null,
                onChanged: (text) {
                  // Update the state to ensure the text is retained
                  setState(() {});
                },
              ),
            ),
            if (widget.homeworkInfo.attachments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    'Attachments:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...widget.homeworkInfo.attachments.map((attachment) {
                    bool isFileNotUploaded =
                        (attachment.fileSize / 1024) == 0.00;
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                      // Adjust padding
                      leading: Icon(Icons.file_download, size: 25),

                      title: isFileNotUploaded
                          ? Text(
                              attachment.imageName +
                                  '\nFile is not uploaded properly',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.red,
                              ),
                            )
                          //   subtitle: Text(
                          //   'File is not uploaded properly',
                          //   style: TextStyle(
                          //     fontSize: 14.sp,
                          //   ),
                          // )
                          : Text(
                              attachment.imageName,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                      subtitle: Text(
                        '${(attachment.fileSize / 1024).toStringAsFixed(2)} KB',
                        style: TextStyle(fontSize: 14.sp),
                      ),

                      onTap: () async {
                        DateTime now = DateTime.now();
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(now);

                        // String? projectUrl = await _getProjectUrl();
                        if (projectUrl != null) {
                          try {
                            if (attachment.fileSize == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('File not uploaded properly'),
                                ),
                              );
                            } else {
                              String downloadUrl = projectUrl +
                                  'uploads/homework/${widget.homeworkInfo.publishDate}/${widget.homeworkInfo.homeworkId}/${attachment.imageName}';
                              downloadFile(
                                  downloadUrl, context, attachment.imageName);
                              print('Failed downloadUrl $downloadUrl');
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to download file: $e'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to retrieve project URL.'),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ],
              ),
            SizedBox(height: 20.h),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _updateHomework();
                  // Navigator.of(context).pushNamed('/parentDashBoardPage');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 37, vertical: 6),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _parentCommentController.dispose();
    _teacherCommentController.dispose();
    super.dispose();
  }

  void downloadFile(String url, BuildContext context, String name) async {
    var directory =
        Directory("/storage/emulated/0/Download/Evolvuschool/Parent/Homework");

    // Ensure the directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    var path = "${directory.path}/$name";
    var file = File(path);

    try {
      var res = await http.get(Uri.parse(url));
      await file.writeAsBytes(res.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'File downloaded successfully: Download/Evolvuschool/Parent/Homework'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
        ),
      );
    }
  }
}