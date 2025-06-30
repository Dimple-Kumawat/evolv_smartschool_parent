import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:evolvu/common/Common_dropDownFiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/StuEditTextField.dart';
import '../common/textFiledStu.dart';
import '../common/withHash_dropDown.dart';

class StuInfoModal {
  String? studentId;
  String? academicYr;
  String? parentId;
  String? firstName;
  String? midName;
  String? lastName;
  String? studentName;
  String? dob;
  String? gender;
  String? admissionDate;
  String? studIdNo;
  String? motherTongue;
  String? birthPlace;
  String? admissionClass;
  String? rollNo;
  String? classId;
  String? sectionId;
  dynamic feesPaid;
  String? bloodGroup;
  String? religion;
  String? caste;
  dynamic subcaste;
  String? transportMode;
  String? vehicleNo;
  dynamic busId;
  String? emergencyName;
  String? emergencyContact;
  String? emergencyAdd;
  String? height;
  String? weight;
  String? hasSpecs;
  String? allergies;
  String? nationality;
  String? permantAdd;
  String? city;
  String? state;
  String? pincode;
  String? isDelete;
  String? prevYearStudentId;
  String? isPromoted;
  String? isNew;
  String? isModify;
  String? isActive;
  String? regNo;
  String? house;
  String? stuAadhaarNo;
  String? category;
  String? lastDate;
  String? slcNo;
  String? slcIssueDate;
  String? leavingRemark;
  dynamic deletedDate;
  dynamic deletedBy;
  String? imageName;
  String? guardianName;
  String? guardianAdd;
  String? guardianMobile;
  String? relation;
  String? guardianImageName;
  String? udisePenNo;
  dynamic addedBkDate;
  dynamic addedBy;
  String? className;
  String? sectionName;
  String? teacherId;
  String? classTeacher;

  StuInfoModal(
      {this.studentId,
      this.academicYr,
      this.parentId,
      this.firstName,
      this.midName,
      this.lastName,
      this.studentName,
      this.dob,
      this.gender,
      this.admissionDate,
      this.studIdNo,
      this.motherTongue,
      this.birthPlace,
      this.admissionClass,
      this.rollNo,
      this.classId,
      this.sectionId,
      this.feesPaid,
      this.bloodGroup,
      this.religion,
      this.caste,
      this.subcaste,
      this.transportMode,
      this.vehicleNo,
      this.busId,
      this.emergencyName,
      this.emergencyContact,
      this.emergencyAdd,
      this.height,
      this.weight,
      this.hasSpecs,
      this.allergies,
      this.nationality,
      this.permantAdd,
      this.city,
      this.state,
      this.pincode,
      this.isDelete,
      this.prevYearStudentId,
      this.isPromoted,
      this.isNew,
      this.isModify,
      this.isActive,
      this.regNo,
      this.house,
      this.stuAadhaarNo,
      this.category,
      this.lastDate,
      this.slcNo,
      this.slcIssueDate,
      this.leavingRemark,
      this.deletedDate,
      this.deletedBy,
      this.imageName,
      this.guardianName,
      this.guardianAdd,
      this.guardianMobile,
      this.relation,
      this.guardianImageName,
      this.udisePenNo,
      this.addedBkDate,
      this.addedBy,
      this.className,
      this.sectionName,
      this.teacherId,
      this.classTeacher});

  StuInfoModal.fromJson(Map<String, dynamic> json) {
    studentId = json['student_id'];
    academicYr = json['academic_yr'];
    parentId = json['parent_id'];
    firstName = json['first_name'];
    midName = json['mid_name'];
    lastName = json['last_name'];
    studentName = json['student_name'];
    dob = json['dob'];
    gender = json['gender'];
    admissionDate = json['admission_date'];
    studIdNo = json['stud_id_no'];
    motherTongue = json['mother_tongue'];
    birthPlace = json['birth_place'];
    admissionClass = json['admission_class'];
    rollNo = json['roll_no'];
    classId = json['class_id'];
    sectionId = json['section_id'];
    feesPaid = json['fees_paid'];
    bloodGroup = json['blood_group'];
    religion = json['religion'];
    caste = json['caste'];
    subcaste = json['subcaste'];
    transportMode = json['transport_mode'];
    vehicleNo = json['vehicle_no'];
    busId = json['bus_id'];
    emergencyName = json['emergency_name'];
    emergencyContact = json['emergency_contact'];
    emergencyAdd = json['emergency_add'];
    height = json['height'];
    weight = json['weight'];
    hasSpecs = json['has_specs'];
    allergies = json['allergies'];
    nationality = json['nationality'];
    permantAdd = json['permant_add'];
    city = json['city'];
    state = json['state'];
    pincode = json['pincode'];
    isDelete = json['IsDelete'];
    prevYearStudentId = json['prev_year_student_id'];
    isPromoted = json['isPromoted'];
    isNew = json['isNew'];
    isModify = json['isModify'];
    isActive = json['isActive'];
    regNo = json['reg_no'];
    house = json['house'];
    stuAadhaarNo = json['stu_aadhaar_no'];
    category = json['category'];
    lastDate = json['last_date'];
    slcNo = json['slc_no'];
    slcIssueDate = json['slc_issue_date'];
    leavingRemark = json['leaving_remark'];
    deletedDate = json['deleted_date'];
    deletedBy = json['deleted_by'];
    imageName = json['image_name'];
    guardianName = json['guardian_name'];
    guardianAdd = json['guardian_add'];
    guardianMobile = json['guardian_mobile'];
    relation = json['relation'];
    guardianImageName = json['guardian_image_name'];
    udisePenNo = json['udise_pen_no'];
    addedBkDate = json['added_bk_date'];
    addedBy = json['added_by'];
    className = json['class_name'];
    sectionName = json['section_name'];
    teacherId = json['teacher_id'];
    classTeacher = json['class_teacher'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['student_id'] = studentId;
    data['academic_yr'] = academicYr;
    data['parent_id'] = parentId;
    data['first_name'] = firstName;
    data['mid_name'] = midName;
    data['last_name'] = lastName;
    data['student_name'] = studentName;
    data['dob'] = dob;
    data['gender'] = gender;
    data['admission_date'] = admissionDate;
    data['stud_id_no'] = studIdNo;
    data['mother_tongue'] = motherTongue;
    data['birth_place'] = birthPlace;
    data['admission_class'] = admissionClass;
    data['roll_no'] = rollNo;
    data['class_id'] = classId;
    data['section_id'] = sectionId;
    data['fees_paid'] = feesPaid;
    data['blood_group'] = bloodGroup;
    data['religion'] = religion;
    data['caste'] = caste;
    data['subcaste'] = subcaste;
    data['transport_mode'] = transportMode;
    data['vehicle_no'] = vehicleNo;
    data['bus_id'] = busId;
    data['emergency_name'] = emergencyName;
    data['emergency_contact'] = emergencyContact;
    data['emergency_add'] = emergencyAdd;
    data['height'] = height;
    data['weight'] = weight;
    data['has_specs'] = hasSpecs;
    data['allergies'] = allergies;
    data['nationality'] = nationality;
    data['permant_add'] = permantAdd;
    data['city'] = city;
    data['state'] = state;
    data['pincode'] = pincode;
    data['IsDelete'] = isDelete;
    data['prev_year_student_id'] = prevYearStudentId;
    data['isPromoted'] = isPromoted;
    data['isNew'] = isNew;
    data['isModify'] = isModify;
    data['isActive'] = isActive;
    data['reg_no'] = regNo;
    data['house'] = house;
    data['stu_aadhaar_no'] = stuAadhaarNo;
    data['category'] = category;
    data['last_date'] = lastDate;
    data['slc_no'] = slcNo;
    data['slc_issue_date'] = slcIssueDate;
    data['leaving_remark'] = leavingRemark;
    data['deleted_date'] = deletedDate;
    data['deleted_by'] = deletedBy;
    data['image_name'] = imageName;
    data['guardian_name'] = guardianName;
    data['guardian_add'] = guardianAdd;
    data['guardian_mobile'] = guardianMobile;
    data['relation'] = relation;
    data['guardian_image_name'] = guardianImageName;
    data['udise_pen_no'] = udisePenNo;
    data['added_bk_date'] = addedBkDate;
    data['added_by'] = addedBy;
    data['class_name'] = className;
    data['section_name'] = sectionName;
    data['teacher_id'] = teacherId;
    data['class_teacher'] = classTeacher;
    return data;
  }
}

class StudentForm extends StatefulWidget {
  final String studentId;
  final String cname;
  final String secname;
  final String shortName1;

  const StudentForm(this.studentId, this.cname, this.shortName1, this.secname,
      {super.key});

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  File? file;
  String shortName = "";
  String academic_yrstr = "";
  String reg_idstr = "";
  String projectUrl = "";
  String url = "";
  String imageUrl = "";
  StuInfoModal? childInfo;

  Map<String, dynamic> updatedData = {};

  void _handleChanged(String key, String? value) {
    if (value != null && value.isNotEmpty) {
      updatedData[key] = value;
    } else {
      updatedData.remove(key);
    }
  }

  final List<String> admittedInClass = [
    'Nursery',
    'LKG',
    'UKG',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13'
  ];

  Map<String, String> specsMapping = {
    'Y': 'YES',
    'N': 'NO',
  };

  Map<String, String> genderMapping = {
    'M': 'Male',
    'F': 'Female',
  };
  Map<String, String> TransMapping = {
    '': 'select',
    'Bus': 'Bus',
    'Van': 'Van',
    'Self': 'Self',
  };

  final List<String> displayOptions = [
    'Select',
    'School Bus',
    'Private Van',
    'Self'
  ];

  // final List<String> admittedInClass = ['LKG', 'UKG', 'Private Van', 'Self'];

  // Values sent to the server
  final Map<String, String> valueMapping = {
    'Select': '',
    'School Bus': 'Bus',
    'Private Van': 'Van',
    'Self': 'Self'
  };
  String? selectedTrans = 'Select'; // Set a default valid value
  String? selectedHouseName = '';
  // Update based on your options

  String? selectedHouseId; // Store short name
  List<Map<String, String>> houses = [];

  Map<String, String> houseNameMapping = {
    'D': 'Diamond',
    'E': 'Emerald',
    'R': 'Ruby',
    'S': 'Sapphire',
  };

  String getGender(String? abbreviation) {
    if (abbreviation == null || abbreviation.isEmpty) {
      return '';
    }
    return genderMapping[abbreviation] ?? abbreviation;
  }

  String getTrans(String? abbreviation) {
    if (abbreviation == null || abbreviation.isEmpty) {
      return TransMapping['']!; // Return "Select" if empty or null
    }
    return TransMapping[abbreviation] ?? abbreviation;
  }

  String getSpecs(String? abbreviation) {
    if (abbreviation == null || abbreviation.isEmpty) {
      return '';
    }
    return specsMapping[abbreviation] ?? abbreviation;
  }

  Future<StuInfoModal?> _getSchoolInfo(String studentId) async {
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
        // shortName = logUrlsparsed['short_name'];

        log('academic_yr ID: $academic_yrstr');
        log('reg_id: $reg_idstr');
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
        String defaultPassword = parsedData['default_password'];

        log('Short Name: $shortName');
        log('URL1111: $url');
        log('Teacher APK URL: $teacherApkUrl');
        log('Project URL: $projectUrl');
        log('Default Password: $defaultPassword');
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }

    http.Response response = await http.post(
      Uri.parse("${url}get_student"),
      body: {
        'student_id': studentId,
        'academic_yr': academic_yr,
        'short_name': shortName
      },
    );
    imageUrl = "${projectUrl}uploads/student_image/$studentId.jpg";
    log('Response status code: $imageUrl');
    log('get_student body: ${response.body}');

    if (response.statusCode == 200) {
      log('Response 11111111111');
      // Assuming 'response' contains the API response
      List<dynamic> apiResponse = json.decode(response.body);

      Map<String, dynamic> data = apiResponse[0];
      setState(() {
        isLoading = false;
        // visitors = uniqueVisitors;
      });
      return StuInfoModal.fromJson(data);
    }
    return null;
  }

  Future<void> uploadImage(ImageSource source) async {
    try {
      final XFile? image = await ImagePicker()
          .pickImage(
        source: source,
        // Add this line to handle dismissal properly
        preferredCameraDevice: CameraDevice.rear,
      )
          .catchError((error) {
        // Handle if user cancels the picker
        log("Image picker cancelled: $error");
        return null;
      });

      if (image == null) return;

      File imageFile = File(image.path);
      File? croppedFile = await cropImage(imageFile);

      if (croppedFile == null) {
        // User cancelled cropping
        return;
      }

      String base64Image = base64Encode(await croppedFile.readAsBytes());

      setState(() {
        file = croppedFile;
      });

      String newImageUrl = await uploadImageToServer(croppedFile, base64Image);

      setState(() {
        imageUrl = newImageUrl;
      });
    } catch (e) {
      log("Error in uploadImage: $e");
    }
  }

  Future<File?> cropImage(File pickedFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.blue,
            backgroundColor: Colors.white,
            // Add these settings for better discard handling
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            // minimumAspectRatio: 1.0,
            // Add these settings for iOS
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (croppedFile == null) {
        // User pressed back or cancel
        return null;
      }

      return File(croppedFile.path);
    } catch (e) {
      log("Error in cropImage: $e");
      return null;
    }
  }

  Future<String> uploadImageToServer(
      File croppedImage, String base64Image) async {
    try {
      var response = await http.post(
        Uri.parse("${url}upload_student_profile_image_into_folder"),
        body: {
          'student_id': widget.studentId,
          'short_name': shortName,
          'filename': "${widget.studentId}.jpg",
          'doc_type_folder': 'student_image',
          'filedata': base64Image,
        },
      );

      if (response.statusCode == 200) {
        log("Error uploading image: $shortName");
        // log("Error uploading image: $base64Image");
        log("Error uploading image: $base64Image");

        setState(() {
          imageUrl =
              "${projectUrl}uploads/student_image/${widget.studentId}.jpg?timestamp=${DateTime.now().millisecondsSinceEpoch}";
        });

        // Assuming the server responds with a JSON containing the image URL
        var responseBody = jsonDecode(response.body);
        log("Error uploading image: $responseBody");
        // Navigator.pop(context);

        Fluttertoast.showToast(
          msg: "Profile Picture updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (_) => StudentActivityPage(
        //     reg_id: reg_id,
        //     shortName: shortName,
        //     studentId: widget.studentId,
        //     academicYr: academic_yrstr,
        //     url: url,
        //     firstName:F,
        //     rollNo: widget.rollNo,
        //     className: widget.className,
        //     cname: widget.cname,
        //     secname: widget.secname,
        //     classTeacher: widget.classTeacher,
        //     gender: widget.gender,
        //     classId: widget.classId,
        //     secId: widget.secId,
        //     attendance_perc: attendance,          )),
        // );

        return imageUrl;
      } else {
        Fluttertoast.showToast(
          msg: "Profile Picture Not updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      log("Error uploading image: $e");
      throw Exception('Failed to upload image');
    }
  }

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
    // _getSchoolInfo(widget.studentId);
  }

  Future<void> fetchHouseData() async {
    try {
      log('get_house body:${widget.shortName1}');

      http.Response response = await http.post(
        Uri.parse("$url+get_house"),
        body: {'short_name': shortName},
      );
      log('get_house body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          houses = data.map((house) {
            return {
              'house_id': house['house_id'] as String,
              'house_name': house['house_name'] as String,
            };
          }).toList();

          // Set the initial selected house to the first house in the list, or you can choose another default

          // selectedHouseName = houses.first['house_name'];
          selectedHouseId = houses.first['house_id'];
          log('Failed to load house data ${childInfo?.house}');

          if (childInfo?.house == 'E') {
            selectedHouseName = 'Emerald';
            log('Failed to load house data $selectedHouseName');
          } else if (childInfo?.house == 'D') {
            selectedHouseName = 'Diamond';
          } else if (childInfo?.house == 'S') {
            selectedHouseName = 'Sapphire';
          } else if (childInfo?.house == 'R') {
            selectedHouseName = 'Ruby';
          }

          if (childInfo?.transportMode == 'Bus') {
            selectedTrans = 'School Bus';
            log('Failed to load house data $selectedTrans');
          } else if (childInfo?.transportMode == 'Van') {
            selectedTrans = 'Private Van';
          } else if (childInfo?.transportMode == 'Self') {
            selectedTrans = 'Self';
          }
        });
      } else {
        log('Failed to load house data');
      }
    } catch (e) {
      log('Exception: $e');
    }
  }

  Future<void> _init() async {
    childInfo = await _getSchoolInfo(widget.studentId);

    setState(() {
      fetchHouseData();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : childInfo != null
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 200.h,
                            width: 200.w,
                            child: Stack(
                              children: [
                                Positioned(
                                  height: 150.w,
                                  left: 0,
                                  right: 0,
                                  top: 10.h,
                                  child: CircleAvatar(
                                    radius: 75
                                        .w, // Adjust the radius to make the image circular
                                    backgroundColor:
                                        Colors.grey[200], // Placeholder color
                                    backgroundImage: imageUrl.isNotEmpty
                                        ? NetworkImage(
                                            imageUrl,
                                          )
                                        : AssetImage(
                                            childInfo?.gender == 'M'
                                                ? 'assets/boy.png'
                                                : 'assets/girl.png',
                                          ) as ImageProvider,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 1, 24, 43)
                                          .withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    // child: IconButton(
                                    //   icon: Icon(Icons.add),
                                    //   iconSize: 24,
                                    //   color: Colors.white,
                                    //   onPressed: () {
                                    //     uploadImage(ImageSource.gallery);
                                    //   },
                                    // ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add),
                                      iconSize: 24,
                                      color: Colors.white,
                                      onPressed: null, // Disables the button
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),

                          StuTextField(
                            label: 'First Name',
                            name: 'First Name',
                            readOnly: true,
                            showRedAsterisk: true,
                            // isRequired: true,
                            // isRequired: true,
                            initialValue: childInfo?.firstName,
                          ),

                          StuTextField(
                            label: 'Middle Name',
                            name: 'Middle Name',
                            readOnly: true,
                            initialValue: childInfo?.midName,
                            //  isRequired: true,
                          ),

                          StuTextField(
                            label: 'Last Name',
                            name: 'Last Name',
                            readOnly: true,
                            initialValue: childInfo?.lastName,
                            // isRequired: true,
                          ),

                          StuTextField(
                            label: 'Date Of Birth',
                            name: 'Date Of Birth',
                            showRedAsterisk: true,
                            readOnly: true,
                            initialValue: childInfo?.dob != null
                                ? DateFormat('dd-MM-yyyy')
                                    .format(DateTime.parse(childInfo!.dob!))
                                : '',
                          ),

                          // Date Of Admission Field
                          StuTextField(
                            label: 'Date Of Admission',
                            name: 'Date Of Admission',
                            showRedAsterisk: true,
                            readOnly: true,
                            // isRequired: true,
                            initialValue: childInfo?.admissionDate != null
                                ? DateFormat('dd-MM-yyyy').format(
                                    DateTime.parse(childInfo!.admissionDate!))
                                : '',
                          ),

                          // GRN NO. CustomTextField
                          StuTextField(
                            label: 'GRN NO.',
                            name: 'GRN NO.',
                            readOnly: true,
                            showRedAsterisk: true,
                            //isRequired: true,
                            initialValue: childInfo?.regNo,
                          ),

                          // Student ID NO. Field
                          StuTextField(
                            label: 'Student ID NO.',
                            name: 'Student ID NO.',
                            readOnly: true,
                            // isRequired: true,
                            initialValue: childInfo?.studIdNo,
                          ),

                          StuTextField(
                            label: 'Udise Pen No.',
                            name: 'Udise Pen No.',
                            readOnly: true,
                            // isRequired: true,
                            initialValue: childInfo?.udisePenNo,
                          ),

                          StuEditTextField(
                            labelText: 'Student Aadhaar No.',
                            initialValue: childInfo?.stuAadhaarNo,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            readOnly: true,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.stuAadhaarNo = value;
                              });
                            },
                          ),

                          // Display the full house name
                          // if (childInfo?.house != null)
                          //   Text('House: ${getFullHouseName(childInfo!.house)}'),

                          HashLabeledDropdown(
                            label: "Admitted In Class",
                            readOnly: true,
                            options: [
                              'Nursery',
                              'LKG',
                              'UKG',
                              '1',
                              '2',
                              '3',
                              '4',
                              '5',
                              '6',
                              '7',
                              '8',
                              '9',
                              '10',
                              '11',
                              '12',
                              '13'
                            ],
                            selectedValue: getGender(childInfo!.admissionClass),
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  childInfo?.admissionClass = newValue;
                                }
                              });
                            },
                          ),

                          SizedBox(width: 16.w), // Space between the two fields
                          // Class Field
                          StuTextField(
                            initialValue: widget.cname,
                            label: 'Class',
                            name: 'Class',
                            showRedAsterisk: true,
                            // isRequired: true,
                            readOnly: true,
                          ),
                          StuTextField(
                            initialValue: widget.secname,
                            readOnly: true,
                            label: 'Division',
                            showRedAsterisk: true,
                            //  isRequired: true,
                            name: 'Division',
                          ),

                          StuTextField(
                            readOnly: true,
                            initialValue: childInfo?.rollNo,
                            label: 'Roll No.',
                            name: 'Roll No.',
                            //  isRequired: true,
                          ),

                          HashLabeledDropdown(
                            readOnly: true,
                            label: "Gender",

                            options: ['Male', 'Female'],

                            selectedValue: getGender(childInfo?.gender) ??
                                'Male', // Default to a valid option
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  childInfo?.gender =
                                      newValue == 'Male' ? 'M' : 'F';
                                }
                              });
                            },
                          ),

                          HashLabeledDropdown(
                            readOnly: true,
                            isRequired: false,
                            label: "Blood Group",
                            // Static label
                            options: const [
                              "AB+",
                              "AB-",
                              "B+",
                              "B-",
                              "A+",
                              "A-",
                              "O+",
                              "O-"
                            ],
                            selectedValue: childInfo?.bloodGroup ??
                                '', // Display the selected blood group inside the dropdown
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  childInfo?.bloodGroup =
                                      newValue; // Update the selected value
                                }
                              });
                            },
                          ),

                          HashLabeledDropdown(
                            readOnly: true,
                            isRequired: false,
                            label: 'House', // Static label
                            options: houseNameMapping.values
                                .toList(), // List of house names
                            selectedValue:
                                selectedHouseName, // Display the selected house name inside the dropdown
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  selectedHouseName =
                                      newValue; // Update the selected house name
                                  selectedHouseId = houses.firstWhere((house) =>
                                          house['house_name'] == newValue)[
                                      'house_id']; // Update the house ID based on the selected house name
                                }
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Nationality',
                            initialValue: childInfo?.nationality ?? '',
                            keyboardType: TextInputType.name,
                            readOnly: true,
                            isRequired: true,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.nationality = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Address',
                            initialValue: childInfo?.permantAdd ?? '',
                            keyboardType: TextInputType.name,
                            readOnly: true,
                            isRequired: true,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.permantAdd = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'City',
                            initialValue: childInfo?.city ?? '',
                            keyboardType: TextInputType.name,
                            isRequired: true,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.city = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'State',
                            initialValue: childInfo?.state ?? '',
                            keyboardType: TextInputType.name,
                            isRequired: true,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.state = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Pincode',
                            initialValue: childInfo?.pincode ?? '',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.pincode = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Birth Place',
                            initialValue: childInfo?.birthPlace ?? '',
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.birthPlace = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Mother Tongue',
                            initialValue: childInfo?.motherTongue ?? '',
                            keyboardType: TextInputType.name,
                            isRequired: true,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.motherTongue = value;
                              });
                            },
                          ),

                          // Religion TextField
                          StuTextField(
                            label: 'Religion',
                            name: 'Religion',
                            readOnly: true,
                            showRedAsterisk: true,
                            // isRequired: true,
                            // isRequired: true,
                            initialValue: childInfo?.religion,
                          ),
                          StuTextField(
                            label: 'Caste',
                            name: 'Caste',
                            readOnly: true,
                            // isRequired: true,
                            // isRequired: true,
                            initialValue: childInfo?.caste,
                          ),
                          StuTextField(
                            label: 'Category',
                            name: 'Category',
                            readOnly: true,
                            showRedAsterisk: true,
                            // isRequired: true,
                            //isRequired: true,
                            initialValue: childInfo?.category,
                          ),

                          StuEditTextField(
                            labelText: 'Emergency Name',
                            initialValue: childInfo?.emergencyName ?? '',
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.emergencyName = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Emergency Address',
                            initialValue: childInfo?.emergencyAdd ?? '',
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.emergencyAdd = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Emergency Contact',
                            initialValue: childInfo?.emergencyContact ?? '',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.emergencyContact = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Allergies(If ANY)',
                            initialValue: childInfo?.allergies ?? '',
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.allergies = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Height',
                            initialValue: childInfo?.height ?? '',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.height = value;
                              });
                            },
                          ),

                          StuEditTextField(
                            labelText: 'Weight',
                            initialValue: childInfo?.weight ?? '',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.weight = value;
                              });
                            },
                          ),

                          LabeledDropdown(
                            label: 'Transport Mode',
                            options: displayOptions,
                            selectedValue: selectedTrans ??
                                'Select', // Default to 'Select' if null
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null && newValue != 'Select') {
                                  selectedTrans = newValue;
                                  childInfo?.transportMode =
                                      valueMapping[newValue] ?? '';
                                }
                              });
                            },
                          ),
                          StuEditTextField(
                            labelText: '',
                            initialValue: childInfo?.vehicleNo ?? '',
                            keyboardType: TextInputType.name,
                            onChanged: (value) {
                              setState(() {
                                childInfo?.vehicleNo = value;
                              });
                            },
                          ),

                          LabeledDropdown(
                            label: 'Has Spectacles?', // Static label
                            options: ['YES', 'NO'], // Dropdown options
                            selectedValue: getSpecs(childInfo!
                                .hasSpecs), // The currently selected spectacles status
                            onChanged: (String? newValue) {
                              setState(() {
                                if (newValue != null) {
                                  childInfo?.hasSpecs =
                                      newValue; // Update the spectacles status
                                }
                              });
                            },
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              log('###### body: ${childInfo?.allergies}');

                              String? aadharNumber = childInfo?.stuAadhaarNo;

                              // Check if Aadhar number is empty or not exactly 12 digits
                              if (aadharNumber == null ||
                                  aadharNumber.length != 12 ||
                                  !RegExp(r'^[0-9]{12}$')
                                      .hasMatch(aadharNumber)) {
                                Fluttertoast.showToast(
                                  msg:
                                      "Enter a valid 12-digit numeric Aadhar number",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return; // Stop execution if validation fails
                              }

                              if (childInfo?.nationality == '' ||
                                  childInfo?.nationality == ' ') {
                                Fluttertoast.showToast(
                                  msg: "Please enter nationality",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return; // Stop execution if validation fails
                              }

                              if (childInfo?.permantAdd == '') {
                                Fluttertoast.showToast(
                                  msg: "Please enter Address",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return; // Stop execution if validation fails
                              }

                              if (childInfo?.city == '') {
                                Fluttertoast.showToast(
                                  msg: "Please enter city",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return; // Stop execution if validation fails
                              }

                              if (childInfo?.state == '') {
                                Fluttertoast.showToast(
                                  msg: "Please enter state",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return; // Stop execution if validation fails
                              }
                              if (childInfo?.motherTongue == '') {
                                Fluttertoast.showToast(
                                  msg: "Please enter Mother tongue",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return; // Stop execution if validation fails
                              }

                              // if (childInfo?.religion == '') {
                              //   Fluttertoast.showToast(
                              //     msg: "Please enter religion",
                              //     toastLength: Toast.LENGTH_SHORT,
                              //     gravity: ToastGravity.BOTTOM,
                              //     backgroundColor: Colors.red,
                              //     textColor: Colors.white,
                              //     fontSize: 16.0,
                              //   );
                              //   return; // Stop execution if validation fails
                              // } if (childInfo?.category == '') {
                              //   Fluttertoast.showToast(
                              //     msg: "Please enter category",
                              //     toastLength: Toast.LENGTH_SHORT,
                              //     gravity: ToastGravity.BOTTOM,
                              //     backgroundColor: Colors.red,
                              //     textColor: Colors.white,
                              //     fontSize: 16.0,
                              //   );
                              //   return; // Stop execution if validation fails
                              // }

                              try {
                                Response response = await post(
                                  Uri.parse("${url}update_student"),
                                  body: {
                                    'short_name': shortName ?? '',
                                    'student_id': childInfo?.studentId ?? '',
                                    'gender': childInfo?.gender ?? '',
                                    'blood_group': childInfo?.bloodGroup ?? '',
                                    'stu_aadhaar_no':
                                        childInfo?.stuAadhaarNo ?? '',
                                    'nationality': childInfo?.nationality ?? '',
                                    'permant_add': childInfo?.permantAdd ?? '',
                                    'city': childInfo?.city ?? '',
                                    'state': childInfo?.state ?? '',
                                    'pincode': childInfo?.pincode ?? '',
                                    'caste': childInfo?.caste ?? '',
                                    'religion': childInfo?.religion ?? '',
                                    'category': childInfo?.category ?? '',
                                    'emergency_contact':
                                        childInfo?.emergencyContact ?? '',
                                    'emergency_name':
                                        childInfo?.emergencyName ?? '',
                                    'emergency_add':
                                        childInfo?.emergencyAdd ?? '',
                                    'transport_mode':
                                        childInfo?.transportMode ?? '',
                                    'vehicle_no': childInfo?.vehicleNo ?? '',
                                    'has_specs': childInfo?.hasSpecs ?? '',
                                    'birth_place': childInfo?.birthPlace ?? '',
                                    'mother_tongue':
                                        childInfo?.motherTongue ?? '',
                                    'stud_id_no': childInfo?.studIdNo ?? '',
                                    'admission_class':
                                        childInfo?.admissionClass ?? '',
                                    'allergies': childInfo?.allergies ?? '',
                                    'height': childInfo?.height ?? '',
                                    'weight': childInfo?.weight ?? '',
                                    'house': selectedHouseId ?? '',
                                    'transport_mode':
                                        childInfo?.transportMode ?? '',
                                  },
                                );

                                // log('Response body: $qrCode $academic_yr $formattedTime $formattedDate');
                                log('Response body: ${response.body}');
                                log('childInfo?.stuAadhaarNo33##### body: ${childInfo?.allergies}+${childInfo?.gender}+${childInfo?.transportMode}');

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

                                  // Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ParentDashBoardPage(
                                            academic_yr: academic_yrstr,
                                            shortName: shortName)),
                                  );
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
                              } catch (e) {
                                log('Exception: $e');
                              }

                              // UpdateStudent(context,childInfo?.studentId);
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
                    )
                  : const Center(
                      child: Text(
                        'No visitors found',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
        ),
      ),
    );
    //   },
    // );
  }
}
