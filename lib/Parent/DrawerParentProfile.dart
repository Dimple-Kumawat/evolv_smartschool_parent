import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:evolvu/common/Common_dropDownFiled.dart';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:evolvu/common/textFiledStu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/StuEditTextField.dart';
import 'package:http/http.dart' as http;

TextEditingController _dobController = TextEditingController();
bool _isClickable =
    true; // This variable controls if the radio is clickable or not

class ParentDet {
  String? parentId;
  String? fatherName;
  String? fatherOccupation;
  String? fOfficeAdd;
  String? fOfficeTel;
  String? fMobile;
  String? fEmail;
  String? motherOccupation;
  String? mOfficeAdd;
  String? mOfficeTel;
  String? motherName;
  String? mMobile;
  String? mEmailid;
  String? parentAdharNo;
  String? mAdharNo;
  String? fDob;
  String? mDob;
  String? fBloodGroup;
  String? mBloodGroup;
  String? isDelete;
  String? fatherImageName;
  String? motherImageName;

  ParentDet(
      {this.parentId,
      this.fatherName,
      this.fatherOccupation,
      this.fOfficeAdd,
      this.fOfficeTel,
      this.fMobile,
      this.fEmail,
      this.motherOccupation,
      this.mOfficeAdd,
      this.mOfficeTel,
      this.motherName,
      this.mMobile,
      this.mEmailid,
      this.parentAdharNo,
      this.mAdharNo,
      this.fDob,
      this.mDob,
      this.fBloodGroup,
      this.mBloodGroup,
      this.isDelete,
      this.fatherImageName,
      this.motherImageName});

  ParentDet.fromJson(Map<String, dynamic> json) {
    parentId = json['parent_id'];
    fatherName = json['father_name'];
    fatherOccupation = json['father_occupation'];
    fOfficeAdd = json['f_office_add'];
    fOfficeTel = json['f_office_tel'];
    fMobile = json['f_mobile'];
    fEmail = json['f_email'];
    motherOccupation = json['mother_occupation'];
    mOfficeAdd = json['m_office_add'];
    mOfficeTel = json['m_office_tel'];
    motherName = json['mother_name'];
    mMobile = json['m_mobile'];
    mEmailid = json['m_emailid'];
    parentAdharNo = json['parent_adhar_no'];
    mAdharNo = json['m_adhar_no'];
    fDob = json['f_dob'];
    mDob = json['m_dob'];
    fBloodGroup = json['f_blood_group'];
    mBloodGroup = json['m_blood_group'];
    isDelete = json['IsDelete'];
    fatherImageName = json['father_image_name'];
    motherImageName = json['mother_image_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['parent_id'] = parentId;
    data['father_name'] = fatherName;
    data['father_occupation'] = fatherOccupation;
    data['f_office_add'] = fOfficeAdd;
    data['f_office_tel'] = fOfficeTel;
    data['f_mobile'] = fMobile;
    data['f_email'] = fEmail;
    data['mother_occupation'] = motherOccupation;
    data['m_office_add'] = mOfficeAdd;
    data['m_office_tel'] = mOfficeTel;
    data['mother_name'] = motherName;
    data['m_mobile'] = mMobile;
    data['m_emailid'] = mEmailid;
    data['parent_adhar_no'] = parentAdharNo;
    data['m_adhar_no'] = mAdharNo;
    data['f_dob'] = fDob;
    data['m_dob'] = mDob;
    data['f_blood_group'] = fBloodGroup;
    data['m_blood_group'] = mBloodGroup;
    data['IsDelete'] = isDelete;
    data['father_image_name'] = fatherImageName;
    data['mother_image_name'] = motherImageName;
    return data;
  }
}

class DrawerParentProfilePage extends StatefulWidget {
  const DrawerParentProfilePage({super.key});

  @override
  _DrawerParentProfilePage createState() => _DrawerParentProfilePage();
}

class _DrawerParentProfilePage extends State<DrawerParentProfilePage> {
  String shortName = "";
  String academic_yrstr = "";
  String reg_idstr = "";
  String projectUrl = "";
  // String url = "";
  ParentDet? ParentDetmod;
  bool isLoading = true; // Add a loading state
  String? f_selectedOption; // State variable to keep track of selected option
  String? m_selectedOption; // State variable to keep track of selected option
  final bool _radioEnabled =
      true; // State variable to control radio button interactivity
  String?
      selectedSmsRecipientFather; // Tracks the currently selected parent (Father/Mother)
  String?
      selectedSmsRecipient; // Tracks the currently selected parent (Father/Mother)

  Future<void> _getSchoolInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');
    log('logUrls====\\\\: $logUrls');
    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        log('logUrls====\\\\11111: $logUrls');

        academic_yrstr = logUrlsparsed['academic_yr'];
        reg_idstr = logUrlsparsed['reg_id'];
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

        String schoolId = parsedData['school_id'];
        String name = parsedData['name'];
        shortName = parsedData['short_name'];
        url = parsedData['url'];
        String teacherApkUrl = parsedData['teacherapk_url'];
        projectUrl = parsedData['project_url'];
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }

    Response response = await post(
      Uri.parse("${url}get_parent"),
      body: {
        'reg_id': reg_idstr,
        // 'academic_yr': academic_yrstr,
        'short_name': shortName
      },
    );
    log('ParentResponse status code: ${response.statusCode}');
    log('ParentResponse body: ${response.body}');
    if (response.statusCode == 200) {
      log('Response ````````11111111111````````');

      // Assuming 'response' contains the API response
      List<dynamic> ParentResponse = json.decode(response.body);
      Map<String, dynamic> data = ParentResponse[0];
      setState(() {
        ParentDetmod = ParentDet.fromJson(data);

        isLoading = false; // Data is loaded
        _initializeDateControllers();
        // _fatherDobController = TextEditingController(
        //   text: ParentDetmod?.fDob ?? '', // Father's initial DOB
        // );
        // _motherDobController = TextEditingController(
        //   text: ParentDetmod?.mDob ?? '', // Mother's initial DOB
        // );
      });

      log('ParentDetmod  Name222222: ${ParentDetmod?.mDob}');
    }
  }

  final TextEditingController _dobController = TextEditingController();
  final bool _isClickable =
      true; // This variable controls if the radio is clickable or not
  TextEditingController _fatherDobController = TextEditingController();
  TextEditingController _motherDobController = TextEditingController();

  void _initializeDateControllers() {
    // Format the initial date for display (dd-MM-yyyy)
    String formattedFatherDob = _formatDateForDisplay(ParentDetmod?.fDob);
    String formattedMotherDob = _formatDateForDisplay(ParentDetmod?.mDob);

    _fatherDobController = TextEditingController(text: formattedFatherDob);
    _motherDobController = TextEditingController(text: formattedMotherDob);
  }

  String _formatDateForDisplay(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }

    try {
      // Parse the date string (assuming it's in yyyy-MM-dd format)
      DateTime date = DateTime.parse(dateString);

      // Format the date for display (dd-MM-yyyy)
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      // Handle parsing errors (e.g., invalid date format)
      log('Error parsing date: $e');
      return ''; // Return an empty string or a default value
    }
  }

  Future<void> updateContactDetails(
      String mobileNumber, String shortname, String val) async {
    final urll =
        Uri.parse('${url}update_ContactDetails'); // Replace with your API URL
    final response = await http.post(
      urll,
      body: {
        'reg_id': reg_id,
        'phone_no': mobileNumber,
        'short_name': shortname,
      },
    );

    if (response.statusCode == 200) {
      log('Contact details updated successfully: ${response.body}');

      if (val == 'Father') {
        Fluttertoast.showToast(
          msg: "Father Mobile no. Selected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Mother Mobile no. Selected",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0,
        );
      }
    } else {
      log('Failed to update contact details: ${response.body}');
    }
  }

  String? fMobile; // Father's mobile number
  String? mMobile;

  Future<void> fetchActivePhoneNumber() async {
    try {
      final response = await http.post(
        Uri.parse('${url}get_active_phone_no'),
        body: {
          'reg_id': reg_id,
          'short_name': shortName,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> result =
            jsonDecode(response.body); // Decode as a list
        log('get_active_phone_no response: ${response.body}');

        if (result.isNotEmpty && result[0] is Map<String, dynamic>) {
          final activePhoneNumber =
              result[0]['active_phone_no']?.toString().trim() ?? '';
          log('Active Phone Number: $activePhoneNumber');

          if (activePhoneNumber.isNotEmpty) {
            setState(() {
              // Compare the active phone number with father's and mother's mobile numbers
              if (activePhoneNumber == ParentDetmod?.fMobile?.trim()) {
                selectedSmsRecipient = 'Father';
              } else if (activePhoneNumber == ParentDetmod?.mMobile?.trim()) {
                selectedSmsRecipient = 'Mother';
              } else {
                log('No matching phone number found.');
                selectedSmsRecipient = null; // Reset if no match is found
              }
            });
          }
        } else {
          log('Invalid response structure.');
        }
      } else {
        log('Failed to fetch active phone number. Status code: ${response.statusCode}');
      }
    } catch (error) {
      log('Error in fetchActivePhoneNumber: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _getSchoolInfo();
  }

  late BuildContext _context; // Declare _context here
  @override
  Widget build(BuildContext context) {
    fetchActivePhoneNumber();

    _context = context; // Set _context within build

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 70.h,
        title: Text(
          "Parent Profile",
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
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 110, 8, 28),
            child: Card(
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(20),
                child: isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator()) // Show a loading indicator
                    : SingleChildScrollView(
                        child: FormBuilder(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              StuTextField(
                                label: 'Father Name',
                                name: 'Father Name',
                                showRedAsterisk: true,
                                readOnly: true,
                                // isRequired: true,
                                // isRequired: true,
                                initialValue: ParentDetmod?.fatherName ?? '',
                              ),
                              StuEditTextField(
                                labelText: 'Occupation',
                                initialValue:
                                    ParentDetmod?.fatherOccupation ?? '',
                                keyboardType: TextInputType.name,
                                isRequired: true,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.fatherOccupation = value;
                                  });
                                },
                              ),
                              StuEditTextField(
                                labelText: 'Office Address',
                                isRequired: true,
                                initialValue: ParentDetmod?.fOfficeAdd ?? '',
                                keyboardType: TextInputType.name,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.fOfficeAdd = value;
                                  });
                                },
                              ),
                              StuEditTextField(
                                labelText: 'Father Adhar Card no.',
                                readOnly: true,
                                initialValue: ParentDetmod?.parentAdharNo ?? '',
                                keyboardType: TextInputType.number,
                                isRequired: true,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.parentAdharNo = value;
                                  });
                                },
                              ),

                              LabeledDropdown(
                                label: "Blood Group", // Keep the label static
                                options: [
                                  'Select',
                                  'AB+',
                                  'AB-',
                                  'B+',
                                  'B-',
                                  'A+',
                                  'A-',
                                  'O+',
                                  'O-'
                                ],
                                selectedValue: ParentDetmod?.fBloodGroup ??
                                    '', // Ensure the selected value is set
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue != null) {
                                      ParentDetmod?.fBloodGroup = newValue;
                                    }
                                  });
                                },
                              ),

                              StuEditTextField(
                                labelText: 'Telephone',
                                initialValue: ParentDetmod?.fOfficeTel ?? '',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.fOfficeTel = value;
                                  });
                                },
                              ),

                              StuEditTextField(
                                readOnly: true,
                                labelText: 'Email id',
                                initialValue: ParentDetmod?.fEmail ?? '',
                                keyboardType: TextInputType.name,
                                isRequired: true,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.fEmail = value;
                                  });
                                },
                              ),

                              BirthdatTextField(
                                labelText: 'Date of Birth',
                                controller: _fatherDobController,
                                onTap: () async {
                                  // Open the date picker dialog
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _fatherDobController
                                            .text.isNotEmpty
                                        ? DateTime.tryParse(
                                                _fatherDobController.text) ??
                                            DateTime.now()
                                        : DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (selectedDate != null) {
                                    setState(() {
                                      // Format the date with leading zeros for day and month
                                      String formattedDay = selectedDate.day
                                          .toString()
                                          .padLeft(2, '0');
                                      String formattedMonth = selectedDate.month
                                          .toString()
                                          .padLeft(2, '0');
                                      String formattedYear =
                                          selectedDate.year.toString();

                                      _fatherDobController.text =
                                          "$formattedDay-$formattedMonth-$formattedYear";

                                      // Update ParentDetmod
                                      ParentDetmod?.fDob =
                                          "$formattedYear-$formattedMonth-$formattedDay";
                                    });
                                  }
                                },
                              ),

                              StuTextField(
                                label: 'Mother Name',
                                name: 'Mother Name',
                                showRedAsterisk: true,

                                readOnly: true,
                                // isRequired: true,
                                // isRequired: true,
                                initialValue: ParentDetmod?.motherName ?? '',
                              ),
                              StuEditTextField(
                                labelText: 'Occupation',
                                initialValue:
                                    ParentDetmod?.motherOccupation ?? '',
                                keyboardType: TextInputType.name,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.motherOccupation = value;
                                  });
                                },
                              ),
                              StuEditTextField(
                                labelText: 'Office Address',
                                initialValue: ParentDetmod?.mOfficeAdd ?? '',
                                keyboardType: TextInputType.name,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.mOfficeAdd = value;
                                  });
                                },
                              ),
                              StuEditTextField(
                                labelText: 'Mother Adhar Card no.',
                                initialValue: ParentDetmod?.mAdharNo ?? '',
                                keyboardType: TextInputType.number,
                                isRequired: true,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.mAdharNo = value;
                                  });
                                },
                              ),

                              LabeledDropdown(
                                label: "Blood Group", // Keep the label static
                                options: [
                                  'Select',
                                  'AB+',
                                  'AB-',
                                  'B+',
                                  'B-',
                                  'A+',
                                  'A-',
                                  'O+',
                                  'O-'
                                ],
                                selectedValue: ParentDetmod?.mBloodGroup ??
                                    '', // Ensure the selected value is set
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue != null) {
                                      ParentDetmod?.mBloodGroup = newValue;
                                    }
                                  });
                                },
                              ),

                              StuEditTextField(
                                readOnly: true,
                                labelText: 'Telephone',
                                initialValue: ParentDetmod?.mOfficeTel ?? '',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.mOfficeTel = value;
                                  });
                                },
                              ),

                              StuEditTextField(
                                labelText: 'Email id',
                                initialValue: ParentDetmod?.mEmailid ?? '',
                                keyboardType: TextInputType.name,
                                isRequired: true,
                                onChanged: (value) {
                                  setState(() {
                                    ParentDetmod?.mEmailid = value;
                                  });
                                },
                              ),

                              BirthdatTextField(
                                labelText: 'Date of Birth',
                                controller: _motherDobController,
                                onTap: () async {
                                  // Open the date picker dialog
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _motherDobController
                                            .text.isNotEmpty
                                        ? DateTime.tryParse(
                                                _motherDobController.text) ??
                                            DateTime.now()
                                        : DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (selectedDate != null) {
                                    setState(() {
                                      // Format the date with leading zeros for day and month
                                      String formattedDay = selectedDate.day
                                          .toString()
                                          .padLeft(2, '0');
                                      String formattedMonth = selectedDate.month
                                          .toString()
                                          .padLeft(2, '0');
                                      String formattedYear =
                                          selectedDate.year.toString();

                                      _motherDobController.text =
                                          "$formattedDay-$formattedMonth-$formattedYear";

                                      // Update ParentDetmod
                                      ParentDetmod?.mDob =
                                          "$formattedYear-$formattedMonth-$formattedDay";
                                    });
                                  }
                                },
                              ),

                              SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Common Message
                                  Center(
                                    child: Text(
                                      'Set to receive SMS at this number',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),

                                  // Father's Mobile Number
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            StuEditTextField(
                                              labelText: 'Father\'s No.',
                                              initialValue:
                                                  ParentDetmod?.fMobile ?? '',
                                              isRequired: true,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  ParentDetmod?.fMobile = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Radio<String>(
                                        value: 'Father',
                                        groupValue: selectedSmsRecipient,
                                        onChanged: (value) async {
                                          setState(() {
                                            selectedSmsRecipient = value!;
                                          });

                                          // Validate and make API call if selected
                                          if (ParentDetmod
                                                      ?.fMobile?.isNotEmpty ==
                                                  true &&
                                              ParentDetmod!.fMobile!.length >=
                                                  10) {
                                            await updateContactDetails(
                                                ParentDetmod!.fMobile!,
                                                shortName,
                                                selectedSmsRecipient!);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Father\'s mobile number is empty or invalid.'),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0),

                                  // Mother's Mobile Number
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            StuEditTextField(
                                              labelText: 'Mother\'s No.',
                                              initialValue:
                                                  ParentDetmod?.mMobile ?? '',
                                              isRequired: true,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                setState(() {
                                                  ParentDetmod?.mMobile = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Radio<String>(
                                        value: 'Mother',
                                        groupValue: selectedSmsRecipient,
                                        onChanged: (value) async {
                                          setState(() {
                                            selectedSmsRecipient = value!;
                                          });

                                          // Validate and make API call if selected
                                          if (ParentDetmod
                                                      ?.mMobile?.isNotEmpty ==
                                                  true &&
                                              ParentDetmod!.mMobile!.length >=
                                                  10) {
                                            await updateContactDetails(
                                                ParentDetmod!.mMobile!,
                                                shortName,
                                                selectedSmsRecipient!);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Mother\'s mobile number is empty or invalid.'),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),

                              SizedBox(
                                height: 20.h,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (selectedSmsRecipient == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please select either Father or Mother mobile number to proceed.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  String selectedNumber =
                                      selectedSmsRecipient == 'Father'
                                          ? ParentDetmod?.fMobile ?? ''
                                          : ParentDetmod?.mMobile ?? '';

                                  if (selectedNumber.length != 10) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please enter a valid 10-digit mobile number.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  String? aadharNumber =
                                      ParentDetmod?.parentAdharNo;

                                  // Check if Aadhar number is empty or not exactly 12 digits
                                  if (aadharNumber == null ||
                                      aadharNumber.length != 12) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Enter a valid 12-digit numeric Father Aadhar number",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return; // Stop execution if validation fails
                                  }
                                  if (ParentDetmod?.mEmailid == '') {
                                    Fluttertoast.showToast(
                                      msg: "Please enter Mother email address",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return; // Stop execution if validation fails
                                  }

                                  if (ParentDetmod?.fEmail == '') {
                                    Fluttertoast.showToast(
                                      msg: "Please enter Father email address",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return; // Stop execution if validation fails
                                  }

                                  if (ParentDetmod?.fOfficeAdd == '') {
                                    Fluttertoast.showToast(
                                      msg: "Please enter Office address",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return; // Stop execution if validation fails
                                  }

                                  if (ParentDetmod?.fatherOccupation == '') {
                                    Fluttertoast.showToast(
                                      msg: "Please enter Father Occupation",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return; // Stop execution if validation fails
                                  }

                                  String? maadharNumber =
                                      ParentDetmod?.mAdharNo;

                                  // Check if Aadhar number is empty or not exactly 12 digits
                                  if (maadharNumber == null ||
                                      maadharNumber.length != 12 ||
                                      !RegExp(r'^[0-9]{12}$')
                                          .hasMatch(maadharNumber)) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Enter a valid 12-digit numeric Mother Aadhar number",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                    return; // Stop execution if validation fails
                                  } else {
                                    Response response = await post(
                                      Uri.parse("${url}update_parent"),
                                      body: {
                                        'reg_id': reg_idstr,
                                        'father_occupation':
                                            ParentDetmod?.fatherOccupation ??
                                                '',

                                        'f_blood_group':
                                            ParentDetmod?.fBloodGroup ?? '',
                                        'm_blood_group':
                                            ParentDetmod?.mBloodGroup ?? '',
                                        'parent_adhar_no':
                                            ParentDetmod?.parentAdharNo ?? '',
                                        'm_adhar_no':
                                            ParentDetmod?.mAdharNo ?? '',

                                        'f_dob': ParentDetmod?.fDob ?? '',
                                        'm_dob': ParentDetmod?.mDob ?? '',

                                        'f_office_add':
                                            ParentDetmod?.fOfficeAdd ?? '',
                                        'f_office_tel':
                                            ParentDetmod?.fOfficeTel ?? '',
                                        'f_mobile': ParentDetmod?.fMobile ?? '',
                                        'f_email': ParentDetmod?.fEmail ?? '',

                                        'mother_occupation':
                                            ParentDetmod?.motherOccupation ??
                                                '',
                                        'm_emailid':
                                            ParentDetmod?.mEmailid ?? '',
                                        'm_office_add':
                                            ParentDetmod?.mOfficeAdd ?? '',
                                        'm_office_tel':
                                            ParentDetmod?.mOfficeTel,
                                        'm_mobile': ParentDetmod?.mMobile,
                                        // 'academic_yr': academic_yrstr,
                                        'short_name': shortName
                                      },
                                    );
                                    log('ParentResponse status code: ${response.statusCode}');
                                    log('ParentResponse body: ${response.body}');

                                    if (response.statusCode == 200) {
                                      Fluttertoast.showToast(
                                        msg: "Profile updated successfully",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => ParentDashBoardPage(
                                                academic_yr: academic_yrstr,
                                                shortName: shortName)),
                                      );
                                      // Navigator.pop(context);
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "Failed to update Profile",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 72, vertical: 12),
                                ),
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.sp),
                                ),
                              ),
                              // Continue adding more fields or other widgets
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                exit(0); // Exit the app with exit code 0 (successful)
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}

class BirthdatTextField extends StatelessWidget {
  final String labelText;
  final String? initialValue;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap; // For fields like date pickers
  final Widget? suffixIcon; // For icons like calendars or dropdowns
  final TextEditingController controller; // Accept controller as parameter

  const BirthdatTextField({
    super.key,
    required this.labelText,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    required this.controller, // Receive controller here
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              labelText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextFormField(
              controller: controller, // Use passed controller here
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                suffixIcon: suffixIcon,
              ),
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
