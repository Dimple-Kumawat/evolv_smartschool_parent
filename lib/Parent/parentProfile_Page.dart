import 'dart:convert';

import 'package:evolvu/common/Common_dropDownFiled.dart';
import 'package:evolvu/common/common_textFiled.dart';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

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
  Null? fDob;
  Null? mDob;
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
  String shortName = "";
  String academic_yrstr = "";
  String reg_idstr = "";
  String projectUrl = "";
  String url = "";
  ParentDet? ParentDetmod;
  bool isLoading = true; // Add a loading state
  String? _selectedOption; // State variable to keep track of selected option
  bool _radioEnabled = true; // State variable to control radio button interactivity


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
      print('Response ```````````11111111111```````````');

      // Assuming 'response' contains the API response
      List<dynamic> ParentResponse = json.decode(response.body);
      Map<String, dynamic> data = ParentResponse[0];
      setState(() {
        ParentDetmod = ParentDet.fromJson(data);

        isLoading = false; // Data is loaded
      });

      print('ParentDetmod  Name222222: ${ParentDetmod?.fatherName}');
    }
  }

  @override
  void initState() {
    super.initState();
    _getSchoolInfo();
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
                ? Center(child: CircularProgressIndicator()) // Show a loading indicator
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
                    CustomTextField(
                      label: 'Father Name',
                      name: 'Father_Name',
                      readOnly: true,
                      initialValue: ParentDetmod?.fatherName ?? '',
                    ),
                    
                    TextFormField(
                      // controller: fatherOccupationController,
                      initialValue: ParentDetmod?.fatherOccupation ?? '',

                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Occupation',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.fatherOccupation = newValue;
                          }
                        });
                      },
                    ),
                    TextFormField(
                        initialValue: ParentDetmod?.fOfficeAdd ?? '',
                      decoration:  InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Office Address',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.fOfficeAdd = newValue;
                          }
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ParentDetmod?.fOfficeTel ?? '',
                      decoration:  InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Telephone',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.fOfficeTel = newValue;
                          }
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ParentDetmod?.fMobile ?? '',
                      decoration:  InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Mobile Number',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.fMobile = newValue;
                          }
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ParentDetmod?.fEmail ?? '',
                      decoration:  InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Email id',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.fEmail = newValue;
                          }
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ParentDetmod?.parentAdharNo ?? '',
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Adhar Card no.',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.parentAdharNo = newValue;
                          }
                        });
                      },
                    ),
                    CustomTextField(
                      label: 'Mother Name',
                      name: 'Mother_Name',
                      readOnly: true,
                      initialValue: ParentDetmod?.motherName ?? '',
                    ),


                    TextFormField(
                      initialValue: ParentDetmod?.motherOccupation ?? '',
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Occupation',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.motherOccupation = newValue;
                          }
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ParentDetmod?.mOfficeAdd ?? '',
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Office Address',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.mOfficeAdd = newValue;
                          }
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ParentDetmod?.mOfficeTel ?? '',
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Telephone',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.mOfficeTel = newValue;
                          }
                        });
                      },
                    ),
                    TextFormField(
                      initialValue: ParentDetmod?.mMobile ?? '',
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Mobile Number',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.mMobile = newValue;
                          }
                        });
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: RadioListTile<String>(
                        title: Text('Set to receive sms at this no',style: TextStyle(
                          fontSize: 14,
                        ),
                        ),
                        value: 'Set to receive sms at this no',
                        groupValue: _selectedOption,
                        onChanged: _radioEnabled
                            ? (String? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        }
                            : null,
                      ),
                    ),

                    TextFormField(
                      initialValue: ParentDetmod?.mEmailid ?? '',
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Email id',
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            ParentDetmod?.mEmailid = newValue;
                          }
                        });
                      },
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Response response = await post(
                          Uri.parse("${url}update_parent"),
                          body: {
                            'reg_id': reg_idstr,
                            'father_occupation': ParentDetmod?.fatherOccupation ?? '',
                            'f_office_add': ParentDetmod?.fOfficeAdd ?? '',
                            'f_office_tel': ParentDetmod?.fOfficeTel ?? '',
                            'f_mobile': ParentDetmod?.fMobile ?? '',
                            'f_email': ParentDetmod?.fEmail ?? '',
                            'parent_adhar_no': ParentDetmod?.parentAdharNo ?? '',

                            'f_mobile': ParentDetmod?.mEmailid ?? '',
                            'mother_occupation': ParentDetmod?.motherOccupation ?? '',
                            'm_office_add': ParentDetmod?.mEmailid ?? '',
                            'm_office_tel': ParentDetmod?.mOfficeTel,
                            'm_mobile': ParentDetmod?.mMobile,
                            // 'academic_yr': academic_yrstr,
                            'short_name': shortName
                          },
                        );
                        print('ParentResponse status code: ${response.statusCode}');
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


