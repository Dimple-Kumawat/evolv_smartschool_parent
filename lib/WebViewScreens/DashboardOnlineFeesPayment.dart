import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:evolvu/AcademicYearProvider.dart';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'FeesReceiptWebViewScreen.dart';

class Dashboardonlinefeespayment extends StatefulWidget {
  // final String paymentUrl;
  final String regId;
  final String paymentUrlShare;
  final String receiptUrl;
  final String shortName;
  final String academicYr;
  final int receipt_button;

  const Dashboardonlinefeespayment({
    super.key,
    required this.regId,
    required this.paymentUrlShare,
    required this.receiptUrl,
    required this.shortName,
    required this.academicYr,
    required this.receipt_button,
  });

  @override
  _PaymentWebviewState createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<Dashboardonlinefeespayment> {
  late WebViewController _controller;
  late SharedPreferences prefs;
  String? paymentUrl;
  String? logoUrl;
  String? name;
  String? newUrl;
  String? dUrl;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // _setupDownloader();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrlShare))
      ..clearCache()
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.endsWith(".pdf") ||
                request.url.contains("/download_receipt")) {
              if (Platform.isAndroid) {
                _downloadFile(request.url);
              } else if (Platform.isIOS) {
                _downloadFileIOS(request.url);
              }
              return NavigationDecision
                  .prevent; // Stop WebView from opening the URL
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  Future<void> _initializeData() async {
    // paymentUrl = "http://holyspiritconvent.evolvu.in/test/hscs_test/index.php/worldline/WL_online_payment_req_apk/?reg_id=1039&academic_yr=2024-2025&user_id=8421853656&encryptedUsername=a34dca3f54ec276c214d5a423c537af101cc67b7&short_name=HSCS";

    log('Loading URL: ${widget.paymentUrlShare}');

    setState(() {});
  }

  Future<void> _downloadFile(String url) async {
    setState(() {
      _isDownloading = true;
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

    try {
      // First check if the URL is valid and file exists (HEAD request)
      final headResponse = await http.head(Uri.parse(url));
      if (headResponse.statusCode == 404) {
        throw Exception('File not found (404)');
      }

      // Create download directory
      final directory =
          Directory("/storage/emulated/0/Download/Evolvuschool/Parent/receipt");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Generate unique filename
      int fileNumber = 1;
      while (await File('${directory.path}/receipt_$fileNumber.pdf').exists()) {
        fileNumber++;
      }
      final fileName = 'receipt_$fileNumber.pdf';
      final path = '${directory.path}/$fileName';
      final file = File(path);

      // Show downloading notification
      await flutterLocalNotificationsPlugin.show(
        0,
        'Downloading Receipt',
        'Downloading $fileName...',
        platformChannelSpecifics,
      );

      // Download the file
      final response = await http.get(Uri.parse(url));

      // Validate the downloaded content
      if (response.statusCode != 200) {
        throw Exception('Failed to download (${response.statusCode})');
      }

      // Check if it's a valid PDF (basic check)
      // if (response.bodyBytes.length < 4 ||
      //     !List.from(response.bodyBytes.take(4)).equals('%PDF'.codeUnits)) {
      //   throw Exception('Invalid PDF file');
      // }

      // Save the file
      await file.writeAsBytes(response.bodyBytes);

      // Verify the saved file
      if (!await file.exists() || await file.length() == 0) {
        throw Exception('File save failed');
      }

      // Show success notification
      await flutterLocalNotificationsPlugin.show(
        0,
        'Download Complete',
        'File saved to Downloads/Evolvuschool/Parent/receipt/$fileName',
        platformChannelSpecifics,
        payload: path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded successfully'),
        ),
      );
    } catch (e) {
      // Show error notification
      await flutterLocalNotificationsPlugin.show(
        0,
        'Download Failed',
        'Failed to download: ${e.toString().replaceAll('Exception: ', '')}',
        platformChannelSpecifics,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Download failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _downloadFileIOS(String url) async {
    setState(() {
      _isDownloading = true; // Show loader
    });

    final directory = await getApplicationDocumentsDirectory();

    int fileNumber = 1;
    while (await File('${directory.path}/receipt_$fileNumber.pdf').exists()) {
      fileNumber++;
    }

    var fileName = 'receipt_$fileNumber.pdf';
    var path = '${directory.path}/$fileName';
    var file = File(path);

    // Show downloading notification
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
      // await flutterLocalNotificationsPlugin.show(
      //   0,
      //   'Downloading Receipt',
      //   'Downloading $fileName...',
      //   platformChannelSpecifics,
      // );

      try {
        var res = await http.get(Uri.parse(url));
        await file.writeAsBytes(res.bodyBytes);

        // Update notification to show download complete
        await flutterLocalNotificationsPlugin.show(
          0,
          'Download Complete',
          'File saved to $path',
          platformChannelSpecifics,
          payload: path, // Pass the file path as payload
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Find it in the Files/On My iPhone/EvolvU Smart School - Parent. $fileName'),
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
    } finally {
      setState(() {
        _isDownloading = false; // Hide loader after completion
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final academicYearProvider = Provider.of<AcademicYearProvider>(context);
    bool isAcademicYearMatch =
        academicYearProvider.academic_yr == widget.academicYr;

    return Scaffold(
      // Use Scaffold here
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70.h,
        title: Text(
          'Fees Payment $academic_yr',
          style: TextStyle(fontSize: 18.sp, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background & WebView
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 115.h),
                if (academicYearProvider.academic_yr == widget.academicYr)

                  // ⚠️ Warning message overlayed near the middle-lower area
                  Align(
                    alignment: Alignment(0,
                        0.9), // X: 0 = center, Y: 0.7 = slightly above bottom
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        //   color: const Color.fromARGB(255, 231, 74, 126),
                        color: Colors.yellow.shade100.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: 20.sp),
                          //  color: Colors.orange, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Don’t refresh or close this page.This page\n'
                            'will refresh once transaction is done',

                            // 'Please wait this page will update\n'
                            // 'once the transaction is complete.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 20.h),
                Expanded(
                  child: academicYearProvider.academic_yr == widget.academicYr
                      ? WebViewWidget(controller: _controller)
                      : Align(
                          alignment: Alignment(0,
                              0.0), // X: 0 = center, Y: 0.7 = slightly above bottom
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.w),
                            padding: EdgeInsets.all(10.h),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade100.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.orange, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Please go to current academic year   \nfor Fees Payment.',

                                  // 'Please wait this page will update\n'
                                  // 'once the transaction is complete.',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  // ReceiptWebViewScreenVali(
                  //   receiptUrl: '${widget.receiptUrl}?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',
                  // ),
                ),
              ],
            ),
          ),
        ],
      ),

      // floatingActionButton: (widget.receiptUrl.isEmpty && isAcademicYearMatch)
      //     ? FloatingActionButton.extended(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (_) {
      //                 return ReceiptWebViewScreen(
      //                   receiptUrl:
      //                       '${widget.receiptUrl}?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',
      //                 );
      //               },
      //             ),
      //           );
      //         },
      //         icon: const Icon(Icons.receipt, color: Colors.black),
      //         label: const Text("Receipt"),
      //         backgroundColor: Colors.blue.shade400,
      //       )
      //     : null, // Hide the button when the condition is false
    );
  }
}
