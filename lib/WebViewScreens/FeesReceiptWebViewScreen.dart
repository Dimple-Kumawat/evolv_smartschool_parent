import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
//import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReceiptWebViewScreen extends StatefulWidget {
  final String receiptUrl;

  ReceiptWebViewScreen({required this.receiptUrl});

  @override
  _ReceiptWebViewScreenState createState() => _ReceiptWebViewScreenState();
}

class _ReceiptWebViewScreenState extends State<ReceiptWebViewScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.receiptUrl))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            if (url.endsWith(".pdf") || url.contains("/download_receipt")) {
              _downloadFile(url);
            }
          },
        ),
      );
  }

  Future<void> _downloadFile(String url) async {
    // Request permission to write to external storage
    var directory = Directory("/storage/emulated/0/Download/Evolvuschool/Parent/receipt");

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    var path = "${directory.path}/receipt.pdf";
    var file = File(path);

    try {
      var res = await http.get(Uri.parse(url));
      await file.writeAsBytes(res.bodyBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File downloaded successfully: Download/Evolvuschool/Parent/receipt'),
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
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
