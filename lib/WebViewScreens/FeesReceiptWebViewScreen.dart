import 'dart:io';
import 'package:evolvu/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:collection/collection.dart';

class DestinationScreen extends StatelessWidget {
  final String filePath;

  const DestinationScreen({required this.filePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloaded File'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('File downloaded successfully!'),
            SizedBox(height: 20),
            Text('File Path: $filePath'),
          ],
        ),
      ),
    );
  }
}

class ReceiptWebViewScreen extends StatefulWidget {
  final String receiptUrl;

  const ReceiptWebViewScreen({super.key, required this.receiptUrl});

  @override
  _ReceiptWebViewScreenState createState() => _ReceiptWebViewScreenState();
}

class _ReceiptWebViewScreenState extends State<ReceiptWebViewScreen> {
  late WebViewController _controller;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.receiptUrl))
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

  // import 'package:path_provider/path_provider.dart';
  Future<void> _downloadFile(String url) async {
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

    try {
      // First check if the URL is valid and file exists (HEAD request)
      final headResponse = await http.head(Uri.parse(url));
      if (headResponse.statusCode == 404) {
        throw Exception('File not found (404)');
      }

      // Get the Downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        // For Android, use getExternalStorageDirectory or Downloads folder
        directory = Directory(
            '/storage/emulated/0/Download/Evolvuschool/Parent/receipt');
        if (Platform.version.contains('API level 29') ||
            Platform.version.contains('API level 30')) {
          // For Android 10 and above, use getExternalStoragePublicDirectory if needed
          directory = await getExternalStorageDirectory();
          directory =
              Directory('${directory!.path}/Evolvuschool/Parent/receipt');
        }
      }

      // Create the directory if it doesn't exist
      if (!await directory!.exists()) {
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
      if (response.bodyBytes.length < 4 ||
          !List.from(response.bodyBytes.take(4)).equals('%PDF'.codeUnits)) {
        throw Exception('Invalid PDF file');
      }

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
          content: Text(
              'File downloaded successfully to Downloads/Evolvuschool/Parent/receipt/$fileName'),
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
        _isDownloading = false; // Hide loader
      });
    }
  }

  // Future<void> _downloadFileIOS(String url) async {
  //   setState(() {
  //     _isDownloading = true; // Show loader
  //   });
  //
  //   try {
  //     // Get the external storage directory
  //     final directory = await getApplicationDocumentsDirectory();
  //
  //
  //     // Find the next available file number
  //     int fileNumber = 1;
  //     while (await File('${directory.path}/receipt_$fileNumber.pdf').exists()) {
  //       fileNumber++;
  //     }
  //
  //     var fileName = 'receipt_$fileNumber.pdf';
  //     var path = '${directory.path}/$fileName';
  //     var file = File(path);
  //
  //     try {
  //       var res = await http.get(Uri.parse(url));
  //       await file.writeAsBytes(res.bodyBytes);
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //               'Find it in the Files/On My iPhone/EvolvU Smart School - Parent. $fileName'),
  //         ),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to download file'),
  //         ),
  //       );
  //     }
  //
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to download file'),
  //       ),
  //     );
  //   } finally {
  //     setState(() {
  //       _isDownloading = false; // Hide loader after completion
  //     });
  //   }
  // }

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70.h,
        title: Text(
          ' Fees Receipt',
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
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
                SizedBox(height: 120.h),
                Expanded(
                  child: WebViewWidget(controller: _controller),
                ),
              ],
            ),
          ),

          // Show loader while downloading
          if (_isDownloading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ReceiptWebViewScreenVali extends StatefulWidget {
  final String receiptUrl;

  const ReceiptWebViewScreenVali({super.key, required this.receiptUrl});

  @override
  _ReceiptWebViewScreenValiState createState() =>
      _ReceiptWebViewScreenValiState();
}

class _ReceiptWebViewScreenValiState extends State<ReceiptWebViewScreenVali> {
  late WebViewController _controller;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.receiptUrl))
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

  // import 'package:path_provider/path_provider.dart';

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
      if (response.bodyBytes.length < 4 ||
          !List.from(response.bodyBytes.take(4)).equals('%PDF'.codeUnits)) {
        throw Exception('Invalid PDF file');
      }

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   // toolbarHeight: 60.h,
      //   title: Text(
      //     'Receipt',
      //     style: TextStyle(fontSize: 20.sp, color: Colors.white),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [Colors.pink, Colors.blue],
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //   ),
            // ),
            child: Column(
              children: [
                Text(
                  'Receipt',
                  style: TextStyle(fontSize: 20.sp, color: Colors.white),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: WebViewWidget(controller: _controller),
                ),
              ],
            ),
          ),

          // Show loader while downloading
          if (_isDownloading)
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
