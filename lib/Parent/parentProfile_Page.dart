import 'dart:convert';

import 'package:evolvu/common/Common_dropDownFiled.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../common/StuEditTextField.dart';
import '../main.dart';
TextEditingController _dobController = TextEditingController();
 bool _isClickable = true; // This variable controls if the radio is clickable or not



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

                    StuTextField(
                      label: 'Father Name',
                      name: 'Father Name',
                      readOnly: true,
                      // isRequired: true,
                      // isRequired: true,
                        initialValue: ParentDetmod?.fatherName ?? '',
                    ),
                     StuEditTextField(
                      labelText: 'Occupation',
                      initialValue: ParentDetmod?.fatherOccupation ?? '',
                      keyboardType: TextInputType.name,
                      onChanged: (value) {
                        setState(() {
                          ParentDetmod?.fatherOccupation = value;
                        });
                      },
                    
                    ),
                    StuEditTextField(
                      labelText: 'Office Address',
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
                      onChanged: (value) {
                        setState(() {
                          ParentDetmod?.parentAdharNo = value;
                        });
                      },
                    
                    ),
                    
                     
                    LabeledDropdown(
                  label:
                  "Blood Group ", // Keep the label static
                  options: ['O', 'A', 'B'],

                 // selectedValue:setGender(ParentDetmod!.parentAdharNo),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        ParentDetmod?.parentAdharNo = newValue;
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
                      labelText: 'Mobile Number',
                      initialValue: ParentDetmod?.fMobile ?? '',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          ParentDetmod?.fMobile = value;
                        });
                      },
                    
                    ),
                   
                   Column(
  children: [
    ListTile(
      //contentPadding: EdgeInsets.symmetric(horizontal: 18.0),
      //leading: true, // Set this to null for better custom control
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 88,),
            child: Radio(
              value: 'Set to receive SMS at this no.',
              groupValue: _selectedOption,
              onChanged: (String? value) {
                setState(() {
                  if (_selectedOption == value) {
                    _selectedOption = null; // Deselect if already selected
                  } else {
                    _selectedOption = value;
                  }
                });
              },
            ),
          ),
              
          Text(
            'Set to receive SMS at this no.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      onTap: () {
        // Allow tapping the ListTile to select/deselect the radio button
        setState(() {
          if (_selectedOption == 'Set to receive SMS at this no.') {
            _selectedOption = null;
          } else {
            _selectedOption = 'Set to receive SMS at this no.';
          }
        });
      },
    ),
    
  ],
),
StuEditTextField(
      labelText: 'Email id',
      initialValue: ParentDetmod?.fEmail ?? '',
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          ParentDetmod?.fEmail = value;
        });
      },
    ),

                   
                   
                   
                     StuEditTextField(
                      labelText: 'Date of Birth',
                      initialValue: ParentDetmod?.fEmail ?? '',
                      keyboardType: TextInputType.datetime,
                      onChanged: (value) {
                        setState(() {
                          ParentDetmod?.fEmail = value;
                        });
                      },
                    
                    ),
                    StuTextField(
                      label: 'Mother Name',
                      name: 'Mother Name',
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
                      onChanged: (value) {
                        setState(() {
                          ParentDetmod?.parentAdharNo = value;
                        });
                      },
                    
                    ),
                    
                     
                    LabeledDropdown(
                  label:
                  "Blood Group ", // Keep the label static
                  options: ['O', 'A', 'B'],

                 // selectedValue:setGender(ParentDetmod!.parentAdharNo),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        ParentDetmod?.parentAdharNo = newValue;
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
                      labelText: 'Mobile Number',
                      initialValue: ParentDetmod?.mMobile ?? '',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          ParentDetmod?.mMobile = value;
                        });
                      },
                    
                    ),
                   
                   Column(
  children: [
    ListTile(
      //contentPadding: EdgeInsets.symmetric(horizontal: 18.0),
      //leading: true, // Set this to null for better custom control
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 88,),
            child: Radio(
              value: 'Set to receive SMS at this no.',
              groupValue: _selectedOption,
              onChanged: (String? value) {
                setState(() {
                  if (_selectedOption == value) {
                    _selectedOption = null; // Deselect if already selected
                  } else {
                    _selectedOption = value;
                  }
                });
              },
            ),
          ),
               //SizedBox(width: 38), // Adjust this value to control the space
          Text(
            'Set to receive SMS at this no.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      onTap: () {
        // Allow tapping the ListTile to select/deselect the radio button
        setState(() {
          if (_selectedOption == 'Set to receive SMS at this no.') {
            _selectedOption = null;
          } else {
            _selectedOption = 'Set to receive SMS at this no.';
          }
        });
      },
    ),
    
  ],
),
StuEditTextField(
      labelText: 'Email id',
      initialValue: ParentDetmod?.fEmail ?? '',
      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          ParentDetmod?.fEmail = value;
        });
      },
    ),

                   
                   
                   
                     StuEditTextField(
                      labelText: 'Date of Birth',
                      initialValue: ParentDetmod?.fEmail ?? '',
                      keyboardType: TextInputType.datetime,
                      onChanged: (value) {
                        setState(() {
                          ParentDetmod?.fEmail = value;
                        });
                      },
                    
                    ),
                    // CustomTextField(
                    //   label: 'Father Name',
                    //   name: 'Father_Name',
                    //   readOnly: true,
                    //   initialValue: ParentDetmod?.fatherName ?? '',
                    // ),
                    
//                     TextFormField(
//                       // controller: fatherOccupationController,
//                       initialValue: ParentDetmod?.fatherOccupation ?? '',

//                       decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Occupation',
//                       ),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.fatherOccupation = newValue;
//                           }
//                         });
//                       },
//                     ),
//                     TextFormField(
//                         initialValue: ParentDetmod?.fOfficeAdd ?? '',
//                       decoration:  InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Office Address',
//                       ),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.fOfficeAdd = newValue;
//                           }
//                         });
//                       },
//                     ),
//                     TextFormField(
//                       initialValue: ParentDetmod?.parentAdharNo ?? '',
//                       decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: ' Father Adhar Card no.',
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.parentAdharNo = newValue;
//                           }
//                         });
//                       },
//                     ),
//                     // Blood Group 
//                     DropdownButtonFormField(
//   decoration: InputDecoration(
//     border: UnderlineInputBorder(),
//     labelText: 'Blood Group',
//     labelStyle: TextStyle(color: Colors.black), // Ensures the label is black
//   ),
//   items: ['O', 'A', 'B']
//       .map((String value) {
//     return DropdownMenuItem(
//       value: value,
//       child: Text(
//         value,
//         style: TextStyle(color: Colors.black), // Ensures dropdown item text is black
//       ),
//     );
//   }).toList(),
//   onChanged: (String? newValue) {
//     // Handle the selected value here
//   },
// ),
                    

//                     TextFormField(
//                       initialValue: ParentDetmod?.fOfficeTel ?? '',
//                       decoration:  InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Telephone',
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.fOfficeTel = newValue;
//                           }
//                         });
//                       },
//                     ),
//                     TextFormField(
//                       initialValue: ParentDetmod?.fMobile ?? '',
//                       decoration:  InputDecoration(
//                         border: UnderlineInputBorder(),
                        
//                         labelText: 'Mobile Number',
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.fMobile = newValue;
//                           }
//                         });
//                       },
//                     ),
                   
// Row(
//   crossAxisAlignment: CrossAxisAlignment.center, // Align vertically to the center
//   children: [
//     Text(
//       'Set to receive SMS at this no:',
//       style: TextStyle(fontSize: 14),
//     ),
//     SizedBox(width: 5), // Reduced spacing between the label and radio
//     GestureDetector(
//       onTap: () {
//         if (_isClickable) {
//           setState(() {
//             if (_selectedOption == 'Set to receive sms at this no') {
//               _selectedOption = null; // Uncheck if it's already selected
//             } else {
//               _selectedOption = 'Set to receive sms at this no'; // Check the radio button
//             }
//           });
//         }
//       },
//       child: Radio<String>(
//         value: 'Set to receive sms at this no',
//         groupValue: _selectedOption,
//         onChanged: _isClickable
//             ? (String? value) {
//                 setState(() {
//                   _selectedOption = value;
//                 });
//               }
//             : null, // Disable onChanged if not clickable
//       ),
//     ),
//   ],
// ),


//                     TextFormField(
//                       initialValue: ParentDetmod?.fEmail ?? '',
//                       decoration:  InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Email id',
//                       ),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.fEmail = newValue;
//                           }
//                         });
//                       },
//                     ),
                     
//                     TextFormField(
//   controller: _dobController, // Add a TextEditingController
//   decoration: const InputDecoration(
//     border: UnderlineInputBorder(),
//     labelText: 'Date of Birth',
//   ),
//   onTap: () async {
//     // Hide the keyboard when the field is tapped
//     FocusScope.of(context).requestFocus(FocusNode());
    
//     // Show the date picker
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );

//     if (pickedDate != null) {
//       // Format the date and update the controller text
//       String formattedDate = "${pickedDate.toLocal()}".split(' ')[0]; // Date in YYYY-MM-DD format
//       setState(() {
//         _dobController.text = formattedDate; // Update the TextFormField with the selected date
//       });

//       // Optionally update the ParentDetmod model as well
//       //ParentDetmod?.fDob = formattedDate;
//     }
//   },
// ),

                    
//                     CustomTextField(
//                       label: 'Mother Name',
//                       name: 'Mother_Name',
//                       readOnly: true,
//                       initialValue: ParentDetmod?.motherName ?? '',
//                     ),


//                     TextFormField(
//                       initialValue: ParentDetmod?.motherOccupation ?? '',
//                       decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Occupation',
//                       ),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.motherOccupation = newValue;
//                           }
//                         });
//                       },
//                     ),
//                     TextFormField(
//                       initialValue: ParentDetmod?.mOfficeAdd ?? '',
//                       decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Office Address',
//                       ),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.mOfficeAdd = newValue;
//                           }
//                         });
//                       },
//                     ),
//                     TextFormField(
//                       initialValue: ParentDetmod?.parentAdharNo ?? '',
//                       decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Mother Adhar Card no.',
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.parentAdharNo = newValue;
//                           }
//                         });
//                       },
//                     ),
//                     // Blood Group 
//                     DropdownButtonFormField(
//   decoration: InputDecoration(
//     border: UnderlineInputBorder(),
//     labelText: 'Blood Group',
//     labelStyle: TextStyle(color: Colors.black), // Ensures the label is black
//   ),
//   items: ['O', 'A', 'B']
//       .map((String value) {
//     return DropdownMenuItem(
//       value: value,
//       child: Text(
//         value,
//         style: TextStyle(color: Colors.black), // Ensures dropdown item text is black
//       ),
//     );
//   }).toList(),
//   onChanged: (String? newValue) {
//     // Handle the selected value here
//   },
// ),
//                     TextFormField(
//                       initialValue: ParentDetmod?.mOfficeTel ?? '',
//                       decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Telephone',
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.mOfficeTel = newValue;
//                           }
//                         });
//                       },
//                     ),
//                     TextFormField(
//                       initialValue: ParentDetmod?.mMobile ?? '',
//                       decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Mobile Number',
//                       ),
//                       keyboardType: TextInputType.number,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.mMobile = newValue;
//                           }
//                         });
//                       },
//                     ),

//                    Row(
//   crossAxisAlignment: CrossAxisAlignment.center, // Align vertically to the center
//   children: [
//     Text(
//       'Set to receive SMS at this no:',
//       style: TextStyle(fontSize: 14),
//     ),
//     SizedBox(width: 5), // Reduced spacing between the label and radio
//     Radio<String>(
//       value: 'Set to receive sms at this no',
//       groupValue: _selectedOption,
//       onChanged: (String? value) {
//         setState(() {
//           if (_selectedOption == value) {
//             // If the same option is selected, uncheck it
//             _selectedOption = null;
//           } else {
//             // Otherwise, check the radio button
//             _selectedOption = value;
//           }
//         });
//       },
//     ),
//   ],
// ),

// TextFormField(
//   initialValue: ParentDetmod?.mEmailid ?? '',
//   decoration: InputDecoration(
//     border: UnderlineInputBorder(),
//     labelText: 'Email id',
//     // Optional: Adjust contentPadding if needed
//     contentPadding: EdgeInsets.symmetric(vertical: 0),
//   ),
//   onChanged: (String? newValue) {
//     setState(() {
//       if (newValue != null) {
//         ParentDetmod?.mEmailid = newValue;
//       }
//     });
//   },
// ),
//  TextFormField(
//                       //initialValue: ParentDetmod?.motherOccupation ?? '',
//                       decoration: const InputDecoration(
//                         border: UnderlineInputBorder(),
//                         labelText: 'Date of Birth',
//                       ),
//                        //keyboardType: TextInputType.number,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           if (newValue != null) {
//                             ParentDetmod?.motherOccupation = newValue;
//                           }
//                         }
//                         );
//                       },
//                     ),

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


