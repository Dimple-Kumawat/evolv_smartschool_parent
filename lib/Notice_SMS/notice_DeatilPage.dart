import 'dart:convert';
import 'dart:io';

import 'package:evolvu/common/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:evolvu/common/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:evolvu/common/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:evolvu/common/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:evolvu/common/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils&Config/DownloadHelper.dart';
import '../Teacher/Attachment.dart';

class NoticeInfo {
  final String classname;
  final String date;
  final String subject;
  final String description;
  final String noticeId;
  final List<Attachment> attachment;

  NoticeInfo({
    required this.classname,
    required this.date,
    required this.subject,
    required this.description,
    required this.noticeId,
    required this.attachment,
  });
}

class NoticeDetailPage extends StatefulWidget {
  final NoticeInfo noticeInfo;

  NoticeDetailPage({required this.noticeInfo});

  @override
  _NoticeDetailPageState createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  bool _showAttachments = true;
  String projectUrl = "";

  @override
  void initState() {
    super.initState();
    _getProjectUrl();
  }

  Future<void> _getProjectUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        setState(() {
          projectUrl = parsedData['project_url'];
        });
      } catch (e) {
        print('Error parsing school info: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(widget.noticeInfo.date);
    String formatted_assignedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

    return WillPopScope(
      onWillPop: () async {
        // Pop until reaching the HistoryTab route
        Navigator.pop(context, true);
        return false;
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showAttachments = !_showAttachments;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRow('Class:', widget.noticeInfo.classname),
              SizedBox(height: 4.h),
              buildRow('Date:', formatted_assignedDate),
              SizedBox(height: 4.h),
              buildRow('Subject:', widget.noticeInfo.subject),
              SizedBox(height: 4.h),
              buildRow('Description:', widget.noticeInfo.description),
              SizedBox(height: 4.h),
              if (widget.noticeInfo.attachment.isNotEmpty)
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
                    ...widget.noticeInfo.attachment.map((attachment) {
                      bool isFileNotUploaded =
                          (attachment.fileSize / 1024) == 0.00;
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
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
                          if (projectUrl.isNotEmpty) {
                            try {
                              if (attachment.fileSize == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('File not uploaded properly'),
                                  ),
                                );
                              } else {
                                String downloadUrl = projectUrl +
                                    'uploads/notice/${widget.noticeInfo.date}/${widget.noticeInfo.noticeId}'
                                        '/${attachment.imageName}';
                                downloadFile(
                                    downloadUrl, context, attachment.imageName);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('File downloaded successfully.'),
                                  ),
                                );
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
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.0,
          child: Text(
            label,
            style: Commonstyle.lableBold,
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void downloadFile(String url, BuildContext context, String name) async {
    var directory =
        Directory("/storage/emulated/0/Download/Evolvuschool/Parent/Notice");

    // Ensure the directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    var path = "${directory.path}/$name";
    var file = File(path);

    try {
      var res = await get(Uri.parse(url));
      await file.writeAsBytes(res.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'File downloaded successfully: Download/Evolvuschool/Parent/Notice'),
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
