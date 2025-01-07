import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:evolvu/username_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String academic_yr;
  final String shortName;
  final String emailstr;

  ForgotPasswordPage(this.emailstr,
      { required this.shortName, required this.academic_yr});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _userIdController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String url = "";
  String projectUrl = "";
  String shortName1 = "";
  String academic_yr1 = "";

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController(text: widget.emailstr);
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _motherNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  _launchURL() async {
    Uri _url = Uri.parse('https://aceventura.in/');
    if (await launchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $_url';
    }
  }

  Future<String?> _getProjectUrl() async {
    final prefs = await SharedPreferences.getInstance();

    String? schoolInfoJson = prefs.getString('school_info');
    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        projectUrl = parsedData['project_url'];
        shortName1 = parsedData['short_name'];
        print('academic_yr ID: $shortName1');
        url = parsedData['url'];
        return url;
      } catch (e) {
        print('Error parsing school info: $e');
        return null;
      }
    } else {
      print('School info not found in SharedPreferences.');
      return null;
    }
  }

  Future<void> recivePassword() async {
    print(projectUrl);

    final http.Response response = await http.post(
      Uri.parse(projectUrl + 'index.php/LoginApi/receive_new_password'),

      body: {
        'short_name': shortName1,
        'user_id': _userIdController.text.trim(),
      },
    );
    print("receive_new_password" + response.body);

    if (response.statusCode == 200) {
      // Fluttertoast.showToast(msg: "Password reset successfully.");

      final responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('⚠ Password Sent !!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),

              content: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  responseData['message'], style: TextStyle(fontSize: 16),),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK', style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      } else {
        Fluttertoast.showToast(msg: responseData['message']);
      }
    } else {
      print(": resss ${response.body}");

      Fluttertoast.showToast(
          msg: "Failed to reset password.  Please try again.  ");
    }

  }

  Future<void> resetPassword() async {
    print(url + "reset_password");
    print(shortName1);
    print(_motherNameController.text.trim());
    print(_dobController.text.trim());

    final http.Response response = await http.post(
      Uri.parse(url + 'reset_password'),

      body: {
        'short_name': shortName1,
        'user_id': _userIdController.text.trim(),
        'answer_one': _motherNameController.text.trim(),
        'dob': _dobController.text.trim(),
        'role_id': 'P', // Assuming the role_id is 'parent'
      },
    );
    print("www" + response.body);

    if (response.statusCode == 200) {

      final responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        Fluttertoast.showToast(msg: responseData['message']);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Password Reset Successful',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),

              content: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  responseData['message'], style: TextStyle(fontSize: 16),),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK', style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      } else {
        Fluttertoast.showToast(msg: responseData['message']);
      }
    } else {
      print(": resss ${response.body}");

      Fluttertoast.showToast(
          msg: "Failed to reset password.  Please try again.  ");
    }
  }

  bool validate() {
    if (_formKey.currentState?.validate() ?? false) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _getProjectUrl();
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  SizedBox(height: 60.0),
              Text(
                shortName1 == 'SACS'
                    ? 'St. Arnold\'s Central School'
                    : shortName1 == 'HSCS' ? 'Holy Spirit Convent School'
                    : 'Evolvu Parent Application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.academic_yr}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Forgot password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Please enter your user id',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4.0),
              TextFormField(
                controller: _userIdController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter userId',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) {
                    return 'Enter UserId';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Please enter your Mother\'s name',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _motherNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your mother\'s name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) {
                    return "Enter Mother's Name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Your Child\'s Date Of Birth',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Select date of birth',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _dobController.text =
                        DateFormat('dd-MM-yyyy').format(pickedDate);
                  }
                },
                validator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) {
                    return 'Enter Date of Birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (validate()) {
                        resetPassword();
                        // Fluttertoast.showToast(msg: "Validation Passed ");

                      } else {
                        Fluttertoast.showToast(msg: "Validation Failed");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      child: Text(
                          'RESET', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UserNamePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      child: Text(
                          'LOGIN', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 120.0),
              const Text(
                'If you do not remember answers to these questions then please enter your userid and click on this link to receive a new password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(right: 0.0),
                child: TextButton(
                  onPressed: () {
                    if(_userIdController != ""){
                      recivePassword();
                    }
                  },
                  child: Text(
                    'receive a new password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ),
                SizedBox(height: 10.0),
                InkWell(
                  onTap: _launchURL,
                  child: const Text(
                    'Aceventura Services',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}