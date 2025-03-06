import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'FeesReceiptWebViewScreen.dart';

class DrawerOnlineFeesPayment extends StatefulWidget {
  // final String paymentUrl;
  final String regId;
  final String paymentUrlShare;
  final String receiptUrl;
  final String shortName;
  final String academicYr;
  final int receipt_button;

  DrawerOnlineFeesPayment({super.key,
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

class _PaymentWebviewState extends State<DrawerOnlineFeesPayment> {
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


    Widget build(BuildContext context) {
      return Scaffold( // Use Scaffold here
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 60.h,
          title: Text(
            'Fees Payment',
            style: TextStyle(fontSize: 20.sp, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReceiptWebViewScreen(
                      receiptUrl: widget.receiptUrl +
                          '?reg_id=${widget.regId}&academic_yr=${widget
                              .academicYr}&short_name=${widget.shortName}',
                    ),
              ),
            );
          },
          icon: const Icon(Icons.receipt,color: Colors.black,),
          label: const Text("Receipt"),
          backgroundColor: Colors.blue.shade400,
        ),
      );
    }
  }