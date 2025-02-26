import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReceiptWebViewScreen extends StatefulWidget {
  final String receiptUrl;

  ReceiptWebViewScreen({required this.receiptUrl});

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
            if (request.url.endsWith(".pdf") || request.url.contains("/download_receipt")) {
              if (Platform.isAndroid) {
                 _downloadFile(request.url);
              }else if (Platform.isIOS) {
                _downloadFileIOS(request.url);
              }
              return NavigationDecision.prevent; // Stop WebView from opening the URL
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

    try {
      // Get the external storage directory
      var directory =
      Directory("/storage/emulated/0/Download/Evolvuschool/Parent/receipt");

      // Find the next available file number
      int fileNumber = 1;
      while (await File('${directory.path}/receipt_$fileNumber.pdf').exists()) {
        fileNumber++;
      }

      var fileName = 'receipt_$fileNumber.pdf';
      var path = '${directory.path}/$fileName';
      var file = File(path);

      try {
        var res = await http.get(Uri.parse(url));
        await file.writeAsBytes(res.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'File downloaded successfully: Download/Evolvuschool/Parent/receipt'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file'),
          ),
        );
      }

    } catch (e) {
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
  Future<void> _downloadFileIOS(String url) async {
    setState(() {
      _isDownloading = true; // Show loader
    });

    try {
      // Get the external storage directory
      final directory = await getApplicationDocumentsDirectory();


      // Find the next available file number
      int fileNumber = 1;
      while (await File('${directory.path}/receipt_$fileNumber.pdf').exists()) {
        fileNumber++;
      }

      var fileName = 'receipt_$fileNumber.pdf';
      var path = '${directory.path}/$fileName';
      var file = File(path);

      try {
        var res = await http.get(Uri.parse(url));
        await file.writeAsBytes(res.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Find it in the Files/On My iPhone/EvolvU Smart School - Parent. $fileName'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file'),
          ),
        );
      }

    } catch (e) {
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
        toolbarHeight: 60.h,
        title: Text(
          'Receipt',
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
                SizedBox(height: 100.h),
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