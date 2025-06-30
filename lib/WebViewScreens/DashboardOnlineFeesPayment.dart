import 'dart:async';
import 'dart:developer';
import 'package:evolvu/AcademicYearProvider.dart';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    log('Loading URL: ${widget.paymentUrlShare}');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrlShare));

    setState(() {});
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
                SizedBox(height: 120.h),
                Expanded(
                  child: academicYearProvider.academic_yr == widget.academicYr
                      ? WebViewWidget(controller: _controller)
                      : ReceiptWebViewScreenVali(
                          receiptUrl:
                              '${widget.receiptUrl}?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',
                        ),
                ),
              ],
            ),
          ),

          // ⚠️ Warning message overlayed near the middle-lower area
          Align(
            alignment: Alignment(
                0, 0.9), // X: 0 = center, Y: 0.7 = slightly above bottom
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
