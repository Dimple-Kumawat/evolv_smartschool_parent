import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';
import 'Attachment.dart';

class TeacherDetailCard extends StatelessWidget {
  final String name;
  final String notesId;
  final String date;
  final String note;
  final String subject;
  final String className;
  final String sectionname;
  final String shortName;
  final String academic_yr;
  final List<Attachment> imageList;

  const TeacherDetailCard({
    super.key,
    required this.name,
    required this.date,
    required this.note,
    required this.subject,
    required this.className,
    required this.sectionname,
    required this.imageList,
    required this.notesId,
    required this.shortName,
    required this.academic_yr,
  });

  Future<String?> _getProjectUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        String projectUrl = parsedData['project_url'];
        return projectUrl;
      } catch (e) {
        print('Error parsing school info: $e');
        return null;
      }
    } else {
      print('School info not found in SharedPreferences.');
      return null;
    }
  }

  Future<void> updateReadStatus() async {
    String url = "";
    String academicYr = "";
    String regId = "";
    String shortName = "";
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');
    print('logUrls====\\\\: $logUrls');
    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        print('logUrls====\\\\11111: $logUrls');

        academicYr = logUrlsparsed['academic_yr'];
        regId = logUrlsparsed['reg_id'];

        print('academic_yr ID: $academicYr');
        print('reg_id: $regId');
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
      Uri.parse("${url}note_read_log_create"),
      body: {
        'notes_id': notesId,
        'parent_id': regId,
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
  Widget buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.0,
          child: Text(
            label,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    updateReadStatus();
    DateTime parsedDate = DateTime.parse(date);
    String formattedAssigneddate = DateFormat('dd-MM-yyyy').format(parsedDate);

    return WillPopScope(
      onWillPop: () async {
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 80.h),
                Text(
                  "Teacher Note Details",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.h),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildRow('Class:', "$className $sectionname"),
                            SizedBox(height: 10.h),
                            buildRow('Subject:', subject),
                            SizedBox(height: 10.h),
                            buildRow('Date:', formattedAssigneddate),
                            SizedBox(height: 10.h),
                            buildRow('Description:', note),
                            SizedBox(height: 20.h),
                            if (imageList.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attachments:',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...imageList.map((attachment) {
                                    bool isFileNotUploaded = (attachment.fileSize / 1024) == 0.00;
                                    return ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                                      leading: Icon(Icons.file_download),
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
                                      onTap: () async {
                                        DateTime now = DateTime.now();
                                        String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                                        String? projectUrl = await _getProjectUrl();
                                        if (projectUrl != null) {
                                          try {
                                            if (attachment.fileSize == 0) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('File not uploaded properly'),
                                                ),
                                              );
                                            } else {
                                              String downloadUrl = '${projectUrl}uploads/daily_notes/$date/$notesId/${attachment.imageName}';
                                              print('Teacher downloadUrl: $downloadUrl');
                                              if (Platform.isAndroid) {
                                                _permissionRequest();
                                                await downloadFile(downloadUrl, context, attachment.imageName);
                                              } else if (Platform.isIOS) {
                                                await _downloadFileIOS(downloadUrl,context, attachment.imageName);
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
                                      },
                                    );
                                  }),
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
          ),
        ),
      ),
    );
  }

  static Future<bool> _permissionRequest() async {
    PermissionStatus result = await Permission.storage.request();
    return result.isGranted;
  }

  downloadFile(String url, BuildContext context, String name) async {

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

    var directory = Directory("/storage/emulated/0/Download/Evolvuschool/Parent/TeacherNote");

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    var path = "${directory.path}/$name";
    var file = File(path);

    // await flutterLocalNotificationsPlugin.show(
    //   0,
    //   'Downloading Receipt',
    //   'Downloading $name...',
    //   platformChannelSpecifics,
    // );

    try {
      var res = await http.get(Uri.parse(url));
      await file.writeAsBytes(res.bodyBytes);

      // Update notification to show download complete
      await flutterLocalNotificationsPlugin.show(
        0,
        'Download Complete',
        'File saved to Download/Evolvuschool/Parent/TeacherNote/$name',
        platformChannelSpecifics,
        payload: path, // Pass the file path as payload
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded successfully: Download/Evolvuschool/Parent/TeacherNote'),
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
          content: Text('Failed to download file'),
        ),
      );
    }
  }

  Future<void> _downloadFileIOS(String url,BuildContext context, String fileName) async {
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
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        await flutterLocalNotificationsPlugin.show(
          0,
          'Download Complete',
          'File saved to $filePath',
          platformChannelSpecifics,
          payload: filePath, // Pass the file path as payload
        );


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File Download Successfully. \n Find it in the Files/On My iPhone/EvolvU Smart School - Parent.'),
          ),
        );
      } else {

      }
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
    }
  }



}
