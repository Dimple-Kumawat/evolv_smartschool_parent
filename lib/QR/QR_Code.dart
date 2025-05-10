import 'dart:async';
import 'dart:convert';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class QRCodeScreen extends StatefulWidget {
  final String regId;

  const QRCodeScreen({super.key, required this.regId});

  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool isLoading = true;
  bool showQRCode = false;
  String errorMessage = '';
  String qrData = '';
  Timer? _timer;
  int _remainingTime = 300;

  @override
  void initState() {
    super.initState();
    fetchConfirmationStatus();
  }

  /// Fetch confirmation status from API
  Future<void> fetchConfirmationStatus() async {
    final String apiUrl = "${durl}index.php/IdcardApi/get_confirmation_status";

    try {
      // Prepare the parameters
      final Map<String, String> params = {
        "short_name": shortName,
        "academic_yr": academic_yr,
        "parent_id": widget.regId,
      };

      final response = await http.post(Uri.parse(apiUrl), body: params);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final status = jsonResponse["status"];
        final confirmation = jsonResponse["confirmation"] ?? "";

        if ((status is bool && !status) || (status is String && status == "false") || confirmation == "N") {
          handleQRNotAvailable();
        } else if (confirmation == "Y") {
          generateQR();
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
        isLoading = false;
      });
    }
  }

  /// Generate QR Code with timestamp and start countdown
  void generateQR() {
    String timestamp = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    setState(() {
      qrData = "${widget.regId} $timestamp";
      showQRCode = true;
      isLoading = false;
      _remainingTime = 300; // Reset timer
    });

    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          showQRCode = false;
          errorMessage = "QR Code expired. Please refresh.";
        });
      }
    });
  }

  /// Refresh QR Code
  void refreshQR() {
    setState(() {
      isLoading = true;
      showQRCode = false;
    });
    generateQR();
  }

  /// Handle case when QR is not available
  void handleQRNotAvailable() {
    setState(() {
      showQRCode = false;
      isLoading = false;
      errorMessage = "QR Code not available. Please fill the details of Parent ID Card";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
          actions: [
            if(errorMessage.isEmpty)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: refreshQR, // Refresh button in app bar
            ),
          ],
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
                  : buildErrorWidget(), // Show error with refresh button
            ),
          ],
        ),
      ),
    );
  }

  /// Widget to display the QR code with countdown
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
            data: qrData,
            version: QrVersions.auto,
            size: 200.0,
          ),
          SizedBox(height: 20),
          Text(
            'Scan the QR Code\nValid for ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')} minutes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: refreshQR,
            icon: Icon(Icons.refresh),
            label: Text('Refresh QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget to display an error message with Refresh button
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          if(errorMessage.isEmpty)
          ElevatedButton.icon(
            onPressed: refreshQR,
            icon: Icon(Icons.refresh),
            label: Text('Refresh QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
