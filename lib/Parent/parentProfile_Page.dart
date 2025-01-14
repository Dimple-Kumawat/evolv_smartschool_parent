import 'dart:convert';

import 'package:evolvu/Parent/father_birthday.dart';
import 'package:evolvu/common/Common_dropDownFiled.dart';
import 'package:evolvu/common/birthdayTextFiled.dart';
import 'package:evolvu/common/common_textFiled.dart';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:evolvu/common/textFiledStu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/StuEditTextField.dart';
import '../main.dart';
import 'package:http/http.dart' as http;

//TextEditingController _dobController = TextEditingController();
  TextEditingController _fatherDobController = TextEditingController();
   TextEditingController _motherDobController = TextEditingController()  ;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['parent_id'] = this.parentId;
    data['father_name'] = this.fatherName;
    data['father_occupation'] = this.fatherOccupation;
    data['f_office_add'] = this.fOfficeAdd;
    data['f_office_tel'] = this.fOfficeTel;
    data['f_mobile'] = this.fMobile;
    data['f_email'] = this.fEmail;
    data['mother_occupation'] = this.motherOccupation;
    data['m_office_add'] = this.mOfficeAdd;
    data['m_office_tel'] = this.mOfficeTel;
    data['mother_name'] = this.motherName;
    data['m_mobile'] = this.mMobile;
    data['m_emailid'] = this.mEmailid;
    data['parent_adhar_no'] = this.parentAdharNo;
    data['m_adhar_no'] = this.mAdharNo;
    data['f_dob'] = this.fDob;
    data['m_dob'] = this.mDob;
    data['f_blood_group'] = this.fBloodGroup;
    data['m_blood_group'] = this.mBloodGroup;
    data['IsDelete'] = this.isDelete;
    data['father_image_name'] = this.fatherImageName;
    data['mother_image_name'] = this.motherImageName;
    return data;
  }
}

class ParentProfilePage extends StatefulWidget {
  @override
  _ParentProfilePage createState() => _ParentProfilePage();
}

class _ParentProfilePage extends State<ParentProfilePage> {
  String selectedDatee = "";

  String shortName = "";
  String academic_yrstr = "";
  String reg_idstr = "";
  String projectUrl = "";
  // String url = "";
  ParentDet? ParentDetmod;
  bool isLoading = true; // Add a loading state
  String? f_selectedOption; // State variable to keep track of selected option
  String? m_selectedOption; // State variable to keep track of selected option
  bool _radioEnabled =
      true; // State variable to control radio button interactivity
  String?
      selectedSmsRecipientFather; // Tracks the currently selected parent (Father/Mother)
  String?
      selectedSmsRecipient; // Tracks the currently selected parent (Father/Mother)

  Future<void> _getSchoolInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');
    print('logUrls====\\\\\: $logUrls');
    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        print('logUrls====\\\\\11111: $logUrls');

        academic_yrstr = logUrlsparsed['academic_yr'];
        reg_idstr = logUrlsparsed['reg_id'];
      } catch (e) {
        print('Error parsing school info: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
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

        fetchActivePhoneNumber();
      } catch (e) {
        print('Error parsing school info: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
    }

    Response response = await post(
      Uri.parse(url + "get_parent"),
      body: {
        'reg_id': reg_idstr,
        // 'academic_yr': academic_yrstr,
        'short_name': shortName
      },
    );
    print('ParentResponse status code: ${response.statusCode}');
    print('ParentResponse body: ${response.body}');
    if (response.statusCode == 200) {
      print('Response ``11111111111``');

      // Assuming 'response' contains the API response
      List<dynamic> ParentResponse = json.decode(response.body);
      Map<String, dynamic> data = ParentResponse[0];
      setState(() {
        ParentDetmod = ParentDet.fromJson(data);

        isLoading = false; // Data is loaded
      });

      print('ParentDetmod  Name222222: ${ParentDetmod?.mDob}');
    }
  }

  Future<void> updateContactDetails(
      String mobileNumber, String shortname) async {
    final urll =
        Uri.parse(url + 'update_ContactDetails'); // Replace with your API URL
    final response = await http.post(
      urll,
      body: {
        'reg_id': reg_id,
        'phone_no': mobileNumber,
        'short_name': shortname,
      },
    );

    if (response.statusCode == 200) {
      print('Contact details updated successfully: ${response.body}');
      Fluttertoast.showToast(
        msg: "Parent Mobile no. updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      print('Failed to update contact details: ${response.body}');
    }
  }

  String? fMobile; // Father's mobile number
  String? mMobile;

  Future<void> fetchActivePhoneNumber() async {
    try {
      final response = await http.post(
        Uri.parse(url + 'get_active_phone_no'),
        body: {
          'reg_id': reg_id,
          'short_name': shortName,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> result =
            jsonDecode(response.body); // Decode as a list
        if (result.isNotEmpty && result[0] is Map<String, dynamic>) {
          final activePhoneNumber = result[0]['active_phone_no'] as String;
          print('get_active_phone_no response = >' + activePhoneNumber);
          setState(() {
            // Determine which radio button to select
            if (activePhoneNumber == ParentDetmod?.fMobile) {
              selectedSmsRecipient = 'Father';
            } else if (activePhoneNumber == ParentDetmod?.mMobile) {
              selectedSmsRecipient = 'Mother';
            }
          });
        } else {
          print('Invalid response structure.');
        }
      } else {
        print(
            'Failed to fetch active phone number. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error in fetchActivePhoneNumber: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _getSchoolInfo();
   _fatherDobController = TextEditingController(
      text: ParentDetmod?.fDob ?? '', // Father's initial DOB
    );
    _motherDobController = TextEditingController(
      text: ParentDetmod?.mDob ?? '', // Mother's initial DOB
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                          Text(
                            "Parent Profile",
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),

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
                            initialValue: ParentDetmod?.fatherOccupation ?? '',
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
                            label: "Blood Group ", // Keep the label static
                            options: [
                              'AB+',
                              'AB-',
                              'B+',
                              'B-',
                              'A+',
                              'A-',
                              'O+',
                              'O-'
                            ],
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
      initialDate: _fatherDobController.text.isNotEmpty
          ? DateTime.tryParse(_fatherDobController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        // Format the date with leading zeros for day and month
        String formattedDay = selectedDate.day.toString().padLeft(2, '0');
        String formattedMonth = selectedDate.month.toString().padLeft(2, '0');
        String formattedYear = selectedDate.year.toString();

        _fatherDobController.text =
            "$formattedDay-$formattedMonth-$formattedYear";

        // Update ParentDetmod
        ParentDetmod?.fDob = "$formattedYear-$formattedMonth-$formattedDay";
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
                            initialValue: ParentDetmod?.motherOccupation ?? '',
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
                            label: "Blood Group ", // Keep the label static
                            options: [
                              'AB+',
                              'AB-',
                              'B+',
                              'B-',
                              'A+',
                              'A-',
                              'O+',
                              'O-'
                            ],
                            // selectedValue:setGender(ParentDetmod!.parentAdharNo),
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  ParentDetmod?.mBloodGroup = newValue;
                                }
                              });
                            },
                          ),

                          StuEditTextField(
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
  controller: _motherDobController,
  onTap: () async {
    // Open the date picker dialog
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _motherDobController.text.isNotEmpty
          ? DateTime.tryParse(_motherDobController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        // Format the date with leading zeros for day and month
        String formattedDay = selectedDate.day.toString().padLeft(2, '0');
        String formattedMonth = selectedDate.month.toString().padLeft(2, '0');
        String formattedYear = selectedDate.year.toString();

        _motherDobController.text =
            "$formattedDay-$formattedMonth-$formattedYear";

        // Update ParentDetmod
        ParentDetmod?.mDob = "$formattedYear-$formattedMonth-$formattedDay";
      });
    }
  },
),


                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Parent's Mobile Numbers Section
                              Text(
                                'Parent\'s Mobile Numbers',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                              // Common Message
                              Center(
                                child: Text(
                                  'Set to receive SMS at this number',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey[600]),
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
                                          labelText: 'Father\'s Number',
                                          initialValue:
                                              ParentDetmod?.fMobile ?? '',
                                              isRequired: true,
                                          keyboardType: TextInputType.number,
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
                                      if (ParentDetmod?.fMobile?.isNotEmpty ==
                                              true &&
                                          ParentDetmod!.fMobile!.length >= 10) {
                                        await updateContactDetails(
                                            ParentDetmod!.fMobile!, shortName);
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
                                          labelText: 'Mother\'s Number',
                                          initialValue:
                                              ParentDetmod?.mMobile ?? '',
                                              isRequired: true,
                                          keyboardType: TextInputType.number,
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
                                      if (ParentDetmod?.mMobile?.isNotEmpty ==
                                              true &&
                                          ParentDetmod!.mMobile!.length >= 10) {
                                        await updateContactDetails(
                                            ParentDetmod!.mMobile!, shortName);
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
                              Response response = await post(
                                Uri.parse("${url}update_parent"),
                                body: {
                                  'reg_id': reg_idstr,
                                  'father_occupation':
                                      ParentDetmod?.fatherOccupation ?? '',
                                  'f_office_add':
                                      ParentDetmod?.fOfficeAdd ?? '',
                                  'f_office_tel':
                                      ParentDetmod?.fOfficeTel ?? '',
                                  'f_mobile': ParentDetmod?.fMobile ?? '',
                                  'f_email': ParentDetmod?.fEmail ?? '',
                                  'parent_adhar_no':
                                      ParentDetmod?.parentAdharNo ?? '',

                                  'mother_occupation':
                                      ParentDetmod?.motherOccupation ?? '',
                                  'm_office_add': ParentDetmod?.mEmailid ?? '',
                                  'm_office_tel': ParentDetmod?.mOfficeTel,
                                  'm_mobile': ParentDetmod?.mMobile,
                                  // 'academic_yr': academic_yrstr,
                                  'short_name': shortName
                                },
                              );
                              print(
                                  'ParentResponse status code: ${response.statusCode}');
                              print('ParentResponse body: ${response.body}');

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
                                setState(() {
                                  WidgetsFlutterBinding.ensureInitialized();
                                  runApp(MyApp());
                                });
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
    );
  }
}