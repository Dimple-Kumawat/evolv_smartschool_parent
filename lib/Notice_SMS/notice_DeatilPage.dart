import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:evolvu/common/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Teacher/Attachment.dart';
import '../main.dart';

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

  const NoticeDetailPage({super.key, required this.noticeInfo});

  @override
  _NoticeDetailPageState createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  bool _showAttachments = true;
  String projectUrl = "";
  bool _isDownloading = false;

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
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(widget.noticeInfo.date);
    String formattedAssigneddate = DateFormat('dd-MM-yyyy').format(parsedDate);

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
              buildRow('Date:', formattedAssigneddate),
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
                                '${attachment.imageName}\nFile is not uploaded properly',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.red,
                                ),
                              )
                            : Text(
                                attachment.imageName,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                        subtitle: Text(
                          '${(attachment.fileSize / 1024).toStringAsFixed(2)} KB',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        onTap: () {
                          _handleDownload(attachment);
                        },
                      );
                    }),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDownload(Attachment attachment) async {
    if (projectUrl.isNotEmpty) {
      try {
        if (attachment.fileSize == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File not uploaded properly'),
            ),
          );
        } else {
          String downloadUrl =
              '${projectUrl}uploads/notice/${widget.noticeInfo.noticeId}/${attachment.imageName}';
          log("_downloadFileIOS $downloadUrl");

          if (Platform.isAndroid) {
            await downloadFile(downloadUrl, context, attachment.imageName);
          } else if (Platform.isIOS) {
            await _downloadFileIOS(downloadUrl, context, attachment.imageName);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to download file'),
              ),
            );
          }
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

  downloadFile(String url, BuildContext context, String name) async {
    setState(() {
      _isDownloading = true; // Show loader
    });

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Download Channel',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
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

      // Update notification to show download complete
      await flutterLocalNotificationsPlugin.show(
        0,
        'Download Complete',
        'File saved to Download/Evolvuschool/Parent/Notice/$name',
        platformChannelSpecifics,
        payload: path, // Pass the file path as payload
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'File downloaded successfully: Download/Evolvuschool/Parent/Notice'),
        ),
      );
    } catch (e) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Download Failed',
        'Failed to download file',
        platformChannelSpecifics,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false; // Hide loader after completion
      });
    }
  }

  Future<void> _downloadFileIOS(
      String url, BuildContext fun, String fileName) async {
    // Get the documents directory on iOS
    final directory = await getApplicationDocumentsDirectory();

    // Construct the full path for the downloaded file
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Download Channel',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      log("Starting download...");
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      log("File will be saved at: $filePath");

      final response = await http.get(Uri.parse(url));
      log("HTTP Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        log("Writing file...");

        await flutterLocalNotificationsPlugin.show(
          0,
          'Download Complete',
          'File saved to $filePath',
          platformChannelSpecifics,
          payload: filePath, // Pass the file path as payload
        );

        await File(filePath).writeAsBytes(response.bodyBytes);
        log("File saved successfully.");
        ScaffoldMessenger.of(fun).showSnackBar(
          SnackBar(content: Text('File downloaded successfully.')),
        );
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Download Failed',
        'Failed to download file',
        platformChannelSpecifics,
      );
      log("Error: $e");
      ScaffoldMessenger.of(fun).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }
}
