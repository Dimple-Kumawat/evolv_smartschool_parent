import 'dart:async';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AcademicYearProvider.dart';
import 'FeesReceiptWebViewScreen.dart';

class PaymentWebview extends StatefulWidget {
  // final String paymentUrl;
  final String regId;
  final String paymentUrlShare;
  final String receiptUrl;
  final String shortName;
  final String academicYr;
  final int receipt_button;

  const PaymentWebview({super.key,
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
    final academicYearProvider = Provider.of<AcademicYearProvider>(context);
    bool isAcademicYearMatch = academicYearProvider.academic_yr == widget.academicYr;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          'Fees Payment $academic_yr',
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
          if(academicYearProvider.academic_yr == academic_yr)
            Expanded(
              child: WebViewWidget(controller: _controller),
            ) else Expanded(
            child: ReceiptWebViewScreenVali(
              receiptUrl: '${widget.receiptUrl}?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',
            ),
          ),
        ],
      ),
      ),
      floatingActionButton: isAcademicYearMatch
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiptWebViewScreen(
                receiptUrl: '${widget.receiptUrl}?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',
              ),
            ),
          );
        },
        icon: const Icon(Icons.receipt, color: Colors.black),
        label: const Text("Receipt"),
        backgroundColor: Colors.blue.shade400,
      )
          : null, // Hide the button when the condition is false
    );
  }
}
