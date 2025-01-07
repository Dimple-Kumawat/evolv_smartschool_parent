import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'FeesReceiptWebViewScreen.dart';

class PaymentWebview extends StatefulWidget {
  // final String paymentUrl;
  final String regId;
  final String paymentUrlShare;
  final String receiptUrl;
  final String shortName;
  final String academicYr;
  final int receipt_button;

  PaymentWebview({super.key,
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

class _PaymentWebviewState extends State<PaymentWebview> {
  late WebViewController _controller;
  late SharedPreferences prefs;
  String? paymentUrl;
  String? logoUrl;
  String? name;
  String? newUrl;
  String? dUrl;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // _setupDownloader();
  }

  Future<void> _initializeData() async {
    prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    newUrl = prefs.getString('newUrl');
    dUrl = prefs.getString('project_url');

    // paymentUrl = "http://holyspiritconvent.evolvu.in/test/hscs_test/index.php/worldline/WL_online_payment_req_apk/?reg_id=1039&academic_yr=2024-2025&user_id=8421853656&encryptedUsername=a34dca3f54ec276c214d5a423c537af101cc67b7&short_name=HSCS";


    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrlShare));

    setState(() {});
  }

  // Future<void> _setupDownloader() async {
  //   await FlutterDownloader.initialize(debug: true);
  // }

  // Future<void> _downloadFile(String url) async {
  //   final status = await Permission.storage.request();
  //   if (status.isGranted) {
  //     final dir = await getExternalStorageDirectory();
  //     if (dir != null) {
  //       final savePath = '${dir.path}/Evolvuschool/Parent/Receipts/';
  //       await FlutterDownloader.enqueue(
  //         url: url,
  //         savedDir: savePath,
  //         fileName: Uri.parse(url).pathSegments.last,
  //         showNotification: true,
  //         openFileFromNotification: true,
  //       );
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("File downloaded to $savePath")),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Permission Denied")),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          'Fees Payment',
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
      // body: WebView(
      //   initialUrl: "http://holyspiritconvent.evolvu.in/test/hscs_test/index.php/worldline/WL_online_payment_req_apk/?reg_id=1039&academic_yr=2024-2025&user_id=8421853656&encryptedUsername=a34dca3f54ec276c214d5a423c537af101cc67b7&short_name=HSCS",
      //   javascriptMode: JavaScriptMode.unrestricted,
      //   onWebViewCreated: (WebViewController webViewController) {
      //     _controller = webViewController;
      //   },
      //   navigationDelegate: (NavigationRequest request) {
      //     if (request.url.endsWith('.pdf')) {
      //       _downloadFile(request.url);
      //       return NavigationDecision.prevent;
      //     }
      //     return NavigationDecision.navigate;
      //   },
      // ),
      floatingActionButton: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if(widget.receipt_button == 1)
          FloatingActionButton(
            onPressed: () {
              // Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReceiptWebViewScreen(receiptUrl: widget.receiptUrl +'?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',)),
              );
            },
            child: Padding(
                padding: EdgeInsets.only( bottom:10),
                child: Icon(Icons.arrow_downward)
            ),
          ),
          Positioned(
            bottom: 5,
            child: Text(
              'Receipt',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
