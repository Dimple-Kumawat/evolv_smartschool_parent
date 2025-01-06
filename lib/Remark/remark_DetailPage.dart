import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Teacher/Attachment.dart';
import '../Utils&Config/DownloadHelper.dart';

class RemarkInfo {
  final String description;
  final String remarkId;
  final String remarkDate;
  final List<Attachment> attachment;

  RemarkInfo({
    required this.description,
    required this.attachment,
    required this.remarkId,
    required this.remarkDate,
  });
}

class RemarkDetailPage extends StatefulWidget {
  final RemarkInfo remarkInfo;

  const RemarkDetailPage({Key? key, required this.remarkInfo})
      : super(key: key);

  @override
  _RemarkDetailPageState createState() => _RemarkDetailPageState();
}

class _RemarkDetailPageState extends State<RemarkDetailPage> {
  late String shortName;
  late String academicYear;
  late String regId;
  late String projectUrl;
  late String url;

  @override
  void initState() {
    super.initState();
    _getProjectUrl();
  }

  Future<void> _getProjectUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String? logUrls = prefs.getString('logUrls');

    if (logUrls != null) {
      try {
        Map<String, dynamic> parsedLogUrls = json.decode(logUrls);
        academicYear = parsedLogUrls['academic_yr'] ?? '';
        regId = parsedLogUrls['reg_id'] ?? '';
      } catch (e) {
        debugPrint('Error parsing logUrls: $e');
      }
    }

    String? schoolInfoJson = prefs.getString('school_info');
    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedSchoolInfo = json.decode(schoolInfoJson);
        projectUrl = parsedSchoolInfo['project_url'] ?? '';
        shortName = parsedSchoolInfo['short_name'] ?? '';
        url = parsedSchoolInfo['url'] ?? '';
      } catch (e) {
        debugPrint('Error parsing school_info: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Container(
        height: 720.h,
        margin: const EdgeInsets.all(1.0),
        padding: const EdgeInsets.all(16.0),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDescription(),
              const SizedBox(height: 16.0),
              if (widget.remarkInfo.attachment.isNotEmpty) _buildAttachments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            widget.remarkInfo.description,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachments() {
    return Column(
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
        ...widget.remarkInfo.attachment.map((attachment) {
          bool isFileNotUploaded = attachment.fileSize <= 0;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.file_download, size: 25),
            title: isFileNotUploaded
                ? Text(
                    '${attachment.imageName}\nFile is not uploaded properly',
                    style: TextStyle(fontSize: 14.sp, color: Colors.red),
                  )
                : Text(attachment.imageName, style: TextStyle(fontSize: 14.sp)),
            subtitle: Text(
              '${(attachment.fileSize / 1024).toStringAsFixed(2)} KB',
              style: TextStyle(fontSize: 14.sp),
            ),
            onTap: () => _handleDownload(attachment),
          );
        }).toList(),
      ],
    );
  }
Future<bool> _checkAndRequestPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return status.isGranted;
  }
  return true; // iOS permissions are typically handled differently
}

  Future<void> _handleDownload(Attachment attachment) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    if (projectUrl.isNotEmpty) {
      try {
        if (attachment.fileSize == 0) {
          _showSnackBar('File not uploaded properly');
        } else {
          String downloadUrl =
              '$projectUrl/uploads/remark/${widget.remarkInfo.remarkDate}/${widget.remarkInfo.remarkId}/${attachment.imageName}';
          if (Platform.isAndroid) {
            await downloadFile(downloadUrl, context, attachment.imageName);
          } else if (Platform.isIOS) {
            await _downloadFileIOS(downloadUrl, attachment.imageName);
          } else {
            _showSnackBar('Unsupported platform');
          }
          _showSnackBar('File downloaded successfully.');
        }
      } catch (e) {
        _showSnackBar('Failed to download file: $e');
      }
    } else {
      _showSnackBar('Failed to retrieve project URL.');
    }
  }

  downloadFile(String url, BuildContext context, String name) async {
    var directory =
        Directory("/storage/emulated/0/Download/Remarks");

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
              'File downloaded successfully: Download/Remarks'),
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

Future<void> _downloadFileIOS(String url, String fileName) async {
  try {
    // Get the application's Documents directory
   final directory = await getApplicationSupportDirectory();

    // Create a custom subdirectory within the Documents folder
    final customDirectory = Directory('${directory.path}/Remarks');
    if (!await customDirectory.exists()) {
      await customDirectory.create(recursive: true);
    }

    // Construct the full path for the downloaded file
    final filePath = '${customDirectory.path}/$fileName';
    final file = File(filePath);

    // Fetch the file data from the URL
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Write the file to the custom directory
      await file.writeAsBytes(response.bodyBytes);
      _showSnackBar('File downloaded successfully. Find it in Remarks folder.');
    } else {
      _showSnackBar('Failed to download file: ${response.statusCode}');
    }
  } catch (e) {
    _showSnackBar('Failed to download file: $e');
  }
}




  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
class FileHandler {
  static Future<String> getDirectoryPath(String subFolder) async {
    final directory = Platform.isIOS
        ? await getApplicationSupportDirectory()
        : await getExternalStorageDirectory();
    final customDirectory = Directory('${directory!.path}/$subFolder');
    if (!await customDirectory.exists()) {
      await customDirectory.create(recursive: true);
    }
    return customDirectory.path;
  }

  static Future<void> downloadFile(String url, String filePath) async {
    final file = File(filePath);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }
}

