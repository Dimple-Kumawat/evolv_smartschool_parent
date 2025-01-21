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

class Dashboardonlinefeespayment extends StatefulWidget {
  // final String paymentUrl;
  final String regId;
  final String paymentUrlShare;
  final String receiptUrl;
  final String shortName;
  final String academicYr;
  final int receipt_button;

  Dashboardonlinefeespayment({super.key,
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
          toolbarHeight: 20.h,
          title: Center(
            child: Text(
              'Fees Payment',
              style: TextStyle(fontSize: 15.sp, color: Colors.white),
            ),
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
              SizedBox(height: 30.h),
              Expanded(
                child: WebViewWidget(controller: _controller),
              ),
            ],
          ),
        ),
        floatingActionButton: widget.receipt_button == 1 // Simplified conditional
            ? Stack(
          alignment: Alignment.bottomRight,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReceiptWebViewScreen(
                      receiptUrl: widget.receiptUrl +
                          '?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',
                    ),
                  ),
                );
              },
              child: const Padding( // Use const for unchanging widgets
                padding: EdgeInsets.only(bottom: 10),
                child: Icon(Icons.arrow_downward),
              ),
            ),
            Positioned(
              bottom: 5,
              right: 0,
              child: const Text( // Use const here as well
                'Receipt',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        )
            : null, // Return null if the condition is false
      );
    }
  }