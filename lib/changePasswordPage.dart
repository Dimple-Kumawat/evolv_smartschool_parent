import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

import 'Parent/parentDashBoard_Page.dart';

class TermsDialog extends StatefulWidget {
  final String terms;

  const TermsDialog({super.key, required this.terms});

  @override
  _TermsDialog createState() => _TermsDialog();
}

class _TermsDialog extends State<TermsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxHeight:
              0.8.sh, // Ensure the dialog doesn't exceed 80% of screen height
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "SMS terms and conditions",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),
            SizedBox(height: 20.h),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  widget.terms,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle Agree
                    save_sms_concern();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Agree",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle Cancel
                    logout(context);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void save_sms_concern() async {
  log('widget.reg:$reg_id');
  try {
    http.Response response = await post(
      Uri.parse("${url}save_sms_consent"),
      body: {
        'parent_id': reg_id,
        "short_name": shortName,
      },
    );

    log('save_sms_consent body: ${response.body}');
    var jsonResponse1 = json.decode(response.body);
    if (response == 'true') {
      // check_sms_consent_status();
    } else {
      log("Failed to fetch SMS consent status");
    }
  } catch (e) {
    log('Exception: $e');
  }
}

class ChangePasswordPage extends StatefulWidget {
  final String academicYear;
  final String shortName;
  final String userID;
  final String url;

  const ChangePasswordPage(
      {super.key,
      required this.academicYear,
      required this.shortName,
      required this.userID,
      required this.url});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _currentPwdController = TextEditingController();
  final TextEditingController _newPwdController = TextEditingController();
  final TextEditingController _renewPwdController = TextEditingController();
  bool isProcessing = false;
  String flag = "";

  Future<void> _changePassword() async {
    if (isProcessing) return; // If already processing, return immediately

    setState(() {
      isProcessing = true; // Disable button while API is processing
    });

    String motherName = _motherNameController.text;
    String currentPwd = _currentPwdController.text;
    String newPwd = _newPwdController.text;
    String renewPwd = _renewPwdController.text;

    if (motherName.isEmpty ||
        currentPwd.isEmpty ||
        newPwd.isEmpty ||
        renewPwd.isEmpty) {
      _showToast("Please fill all fields");
      setState(() => isProcessing = false);
      return;
    }

    if (newPwd.length < 8 || newPwd.length > 20 || !validatePwd(newPwd)) {
      _showToast(
          "New Password must be 8-20 characters long and contain a number and a special character.");
      setState(() => isProcessing = false);
      return;
    }

    if (currentPwd == newPwd) {
      _showToast("Old Password & New Password cannot be the same.");
      setState(() => isProcessing = false);
      return;
    }

    if (newPwd != renewPwd) {
      _showToast("New Password & Re-enter Password must be the same.");
      setState(() => isProcessing = false);
      return;
    }

    try {
      log('widget.userID:${widget.userID}$motherName$currentPwd$newPwd');
      var response = await http.post(
        Uri.parse("${widget.url}change_password"),
        body: {
          "short_name": widget.shortName,
          "user_id": widget.userID, // Replace with actual user_id
          "answerone": motherName,
          "password_old": currentPwd,
          "password_new": newPwd,
          "password_re": renewPwd,
        },
      );

      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'true') {
        _showToast(jsonResponse['message']);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ParentDashBoardPage(
                  academic_yr: academic_yr, shortName: shortName)),
        );
        // Navigator.pushReplacementNamed(context, '/ParentDashboard');
      } else {
        _showToast(jsonResponse['message']);
      }
    } catch (error) {
      _showToast("Error: ${error.toString()}");
    }
    setState(() {
      isProcessing = false; // Enable button after request completes
    });
  }

  bool validatePwd(String password) {
    RegExp regex = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,20}$');
    return regex.hasMatch(password);
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String terms =
      '''AceVentura Services (hereinafter, "We," "Us," "Our") is offering Evolvu School Application program (the "Program"), which you agree to use and participate in subject to these Mobile Messaging Terms and Conditions and Privacy Policy (the "Agreement"). By opting in, you accept and agree to these terms and conditions, including, without limitation, your agreement to resolve any disputes with us through binding, individual-only arbitration, as detailed in the "Dispute Resolution" section below. This Agreement is limited to the Program and is not intended to modify other Terms and Conditions or Privacy Policy that may govern the relationship between you and Us in other contexts.\n\n
  User Option In: The Program allows Users to receive SMS mobile messages by affirmatively opting into the Program, such as through online or application-based enrolment forms. Regardless of the opt-in method you utilized to join or use the Program, you agree that this Agreement applies to your participation in the Program. By participating in the Program, you agree to receive autodialed or prerecorded mobile messages from software application at the phone number associated with your opt-in, and you understand that consent is not required to make any purchase from Us. While you consent to receive messages sent using an autodialer, the foregoing shall not be interpreted to suggest or imply that any or all of Our mobile messages are sent using an software application.\n\n
  User Opt Out: If you do not wish to receive mobile messages or continue participating in the Program or no longer agree to this Agreement, you may remove the application or provide some other phone number to receive the school application messages. You may receive an additional mobile message confirming your decision to opt out. You understand and agree that the foregoing options are the only reasonable methods of opting out. You also understand and agree that any other method of opting out, including, but not limited to, texting words other than those set forth above or verbally requesting one of our employees to remove you from our list, is not a reasonable means of opting out.\n\n
  Duty to Notify and Indemnify: If at any time you intend to stop using the mobile telephone number that has been used to subscribe to the Program, including canceling your service plan or selling or transferring the phone number to another party, you agree that you will complete the User Opt Out process set forth above prior to ending your use of the mobile telephone number. You understand and agree that your agreement to do so is a material part of these terms and conditions. You further agree that, if you discontinue the use of your mobile telephone number without notifying Us of such change, you agree that you will be responsible for all costs (including attorneys' fees) and liabilities incurred by Us, or any party that assists in the delivery of the mobile messages, as a result of claims brought by individual(s) who are later assigned that mobile telephone number. This duty and agreement shall survive any cancellation or termination of your agreement to participate in any of our Programs.\n\n
  YOU AGREE THAT YOU SHALL INDEMNIFY, DEFEND, AND HOLD US HARMLESS FROM ANY CLAIM OR LIABILITY RESULTING FROM YOUR FAILURE TO NOTIFY US OF A CHANGE IN THE INFORMATION YOU HAVE PROVIDED, INCLUDING ANY CLAIM OR LIABILITY UNDER THE INDIAN LAW OR ACT.\n\n
  Program Description: Without limiting the scope of the Program, users that opt into the Program can expect to receive messages concerning the attendance, remarks, notices, events, general information and invite or to register or to subscribe''';

  void check_sms_consent_status() async {
    log('widget.reg:$reg_id');
    try {
      http.Response response = await post(
        Uri.parse("${url}check_sms_consent_status"),
        body: {
          'parent_id': reg_id,
          "short_name": widget.shortName,
        },
      );

      log('Response body: ${response.body}');
      var jsonResponse1 = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          flag = jsonResponse1['flag'].toString();
        });

        if (flag == '0') {
          _showTermsDialog();
        }
      } else {
        log("Failed to fetch SMS consent status");
      }
    } catch (e) {
      log('Exception: $e');
    }
  }

  void save_sms_concern() async {
    log('widget.reg:$reg_id');
    try {
      http.Response response = await post(
        Uri.parse("${url}save_sms_consent"),
        body: {
          'parent_id': reg_id,
          "short_name": widget.shortName,
        },
      );

      log('save_sms_consent body: ${response.body}');
      var jsonResponse1 = json.decode(response.body);
      if (response == 'true') {
        check_sms_consent_status();
      } else {
        log("Failed to fetch SMS consent status");
      }
    } catch (e) {
      log('Exception: $e');
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TermsDialog(terms: terms);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    check_sms_consent_status();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "Change Password",
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 120),
                Container(
                  padding: const EdgeInsets.all(36.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "What is your mother's name? ",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "*",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _motherNameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 10.w),
                          hintText: "What is your mother's maiden name?",
                          hintStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Current password ",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "*",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _currentPwdController,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 10.w),
                          hintText: "Current password",
                          hintStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "New password ",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "*",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _newPwdController,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 10.w),
                          hintText: "New password",
                          hintStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Password can be 8 to 20 characters long must contain a number and a special character like &@#\$%^*",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Re-enter new password ",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "*",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _renewPwdController,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 10.w),
                          hintText: "Re-enter new password",
                          hintStyle: TextStyle(fontSize: 14.sp),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : _changePassword, // Disable button while processing
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isProcessing
                                ? Colors.grey
                                : Colors
                                    .blue, // Grey out button while processing
                            padding: EdgeInsets.symmetric(
                                horizontal: 32.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                          child: isProcessing
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text("Update",
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
