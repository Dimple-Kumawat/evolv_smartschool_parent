import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../AcademicYearProvider.dart';
import 'FeesReceiptWebViewScreen.dart';

class DrawerOnlineFeesPayment extends StatefulWidget {
  final String regId;
  final String paymentUrlShare;
  final String receiptUrl;
  final String shortName;
  final String academicYr;
  final int receipt_button;

  const DrawerOnlineFeesPayment({
    super.key,
    required this.regId,
    required this.paymentUrlShare,
    required this.receiptUrl,
    required this.shortName,
    required this.academicYr,
    required this.receipt_button,
  });

  @override
  State<DrawerOnlineFeesPayment> createState() => _PaymentWebviewState();
}

class _PaymentWebviewState extends State<DrawerOnlineFeesPayment> {
  WebViewController? _controller;
  SharedPreferences? _prefs;
  String? name;
  String? newUrl;
  String? dUrl;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      name = _prefs?.getString('name');
      newUrl = _prefs?.getString('newUrl');
      dUrl = _prefs?.getString('project_url');

      debugPrint('Payment URL: ${widget.paymentUrlShare}');

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.paymentUrlShare));

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of resources if necessary
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academicYearProvider = Provider.of<AcademicYearProvider>(context);
    final isAcademicYearMatch =
        academicYearProvider.academic_yr == widget.academicYr;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70.h,
        title: Text(
          'Fees Payment ${widget.academicYr}',
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
            SizedBox(height: 110.h),
            Expanded(
              child: _controller == null
                  ? const Center(child: CircularProgressIndicator())
                  : isAcademicYearMatch
                      ? WebViewWidget(controller: _controller!)
                      : ReceiptWebViewScreen(
                          receiptUrl:
                              '${widget.receiptUrl}?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          (widget.receiptUrl.isNotEmpty && isAcademicYearMatch)
              ? FloatingActionButton.extended(
                  // onPressed: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => ReceiptWebViewScreen(
                  //         receiptUrl:
                  //             '${widget.receiptUrl}?reg_id=${widget.regId}&academic_yr=${widget.academicYr}&short_name=${widget.shortName}',
                  //       ),
                  //     ),
                  //   );
                  // },
                  onPressed: () {
                    if (receiptUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceiptWebViewScreen(
                            receiptUrl:
                                '$receiptUrl?reg_id=$reg_id&academic_yr=$academic_yr&short_name=$shortName',
                          ),
                        ),
                      );
                    }
                    // else {
                    //   Fluttertoast.showToast(msg: 'Receipt URL not available');
                    // }
                  },
                  icon: const Icon(Icons.receipt, color: Colors.black),
                  label: Text(
                    'Receipt${widget.academicYr}',
                  ),
                  backgroundColor: Colors.blue.shade400,
                )
              : null,
    );
  }
}
