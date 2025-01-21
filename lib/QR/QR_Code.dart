import 'dart:convert';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatefulWidget {
  final String regId;


  QRCodeScreen({
    required this.regId,
  });

  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool isLoading = true;
  bool showQRCode = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchConfirmationStatus();
  }

  Future<void> fetchConfirmationStatus() async {
    final String apiUrl = durl+"index.php/IdcardApi/get_confirmation_status";

    try {
      // Prepare the parameters
      final Map<String, String> params = {
        "short_name": shortName,
        "academic_yr": academic_yr,
        "parent_id": widget.regId,
      };

      // Make the POST request
      final response = await http.post(Uri.parse(apiUrl), body: params);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = json.decode(response.body);
        print('QRCodeScreen: $jsonResponse');
        // Handle 'status' as a bool or a String
        final status = jsonResponse["status"];
        final confirmation = jsonResponse["confirmation"] ?? "";

        if ((status is bool && !status) || (status is String && status == "false") || confirmation == "N") {
          handleQRNotAvailable();
        } else if (confirmation == "Y") {
          setState(() {
            showQRCode = true;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Unknown confirmation status";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Exception: $e";
        print('QRCodeScreen: $e');

        isLoading = false;
      });
    }
  }

  void handleQRNotAvailable() {
    setState(() {
      showQRCode = false;
      isLoading = false;
      errorMessage = "QR Code not available.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Verify Parents by QR Code'),
          backgroundColor: Colors.pink,
        ),
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.blue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Center(
              child: isLoading
                  ? CircularProgressIndicator() // Loader
                  : showQRCode
                  ? buildQRCodeWidget() // Show QR Code
                  : buildErrorWidget(), // Show error
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQRCodeWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: widget.regId,
            version: QrVersions.auto,
            size: 200.0,
          ),
          SizedBox(height: 20),
          Text(
            'Scan the QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        errorMessage,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
