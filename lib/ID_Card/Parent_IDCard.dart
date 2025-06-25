import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Parent/DrawerParentProfile.dart';
import 'Edit_IDCard.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key});

  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  List<Student> students = [];
  GURInfo? guardian;
  List<ParentInfo> parents = [];

  bool isLoading = true;
  bool showNoDataMessage = false;
  String regId = "";
  String academicYr = "";
  String shortName = "";
  String url = "";
  ParentDet? ParentDetmod;

  late TextEditingController fatherMobileController;
  late TextEditingController motherMobileController;
  late TextEditingController guardianMobileController;
  late TextEditingController guardianNameController;
  late TextEditingController guardianRelationController;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _getSchoolInfo();
    fatherMobileController = TextEditingController();
    motherMobileController = TextEditingController();
    guardianMobileController = TextEditingController();

    guardianNameController = TextEditingController();
    guardianRelationController = TextEditingController();
  }

  File? _fatherImage;
  File? _motherImage;
  File? _guardianImage;

  String _fatherImageBase64 = "";
  String _motherImageBase64 = "";
  String _guardianImageBase64 = "";

  String _fatherFileName = "";
  String _motherFileName = "";
  String _guardianFileName = "";

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File imageFile = File(image.path);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      androidUiSettings: const AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        statusBarColor: Colors.blue,
        backgroundColor: Colors.white,
      ),
      iosUiSettings: const IOSUiSettings(
        cancelButtonTitle: 'Cancel',
        doneButtonTitle: 'Done',
      ),
    );

    if (croppedFile != null) {
      File file = File(croppedFile.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        if (type == "father") {
          _fatherImage = file;
          _fatherImageBase64 = base64Image;
          _fatherFileName = "f_$regId.jpg";
        } else if (type == "mother") {
          _motherImage = file;
          _motherImageBase64 = base64Image;
          _motherFileName = "m_$regId.jpg";
        } else if (type == "guardian") {
          _guardianImage = file;
          _guardianImageBase64 = base64Image;
          _guardianFileName = "g_$regId.jpg";
        }
      });
    }
  }

  Future<void> _getSchoolInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');

    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsParsed = json.decode(logUrls);
        academicYr = logUrlsParsed['academic_yr'];
        regId = logUrlsParsed['reg_id'];
      } catch (e) {
        log('Error parsing log URLs: $e');
      }
    } else {
      log('Log URLs not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        shortName = parsedData['short_name'];
        url = parsedData['url'];
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }

    if (url.isNotEmpty) {
      await _fetchParents(); // Call parents API
      await _fetchStudents(); // Call students API
    } else {
      log('URL is empty, cannot make HTTP request.');
    }
  }

  Future<void> _fetchParents() async {
    try {
      Response response = await http.post(
        Uri.parse("${url}get_parent"),
        body: {'reg_id': regId, 'short_name': shortName},
      );

      log('ParentResponse status code: ${response.statusCode}');
      log('ParentResponse body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> parentResponse = json.decode(response.body);
        if (parentResponse.isNotEmpty) {
          Map<String, dynamic> data = parentResponse[0];

          setState(() {
            parents = [
              ParentInfo(
                id: data['parent_id'] ?? "",
                name: data['father_name'] ?? "Not Available",
                mobile: data['f_mobile'] ?? "N/A",
                relation: "Father",
                imageUrl: data['father_image_name'] != null
                    ? "${durl}uploads/parent_image/" + data['father_image_name']
                    : "https://via.placeholder.com/100",
              ),
              ParentInfo(
                id: data['parent_id'] ?? "",
                name: data['mother_name'] ?? "Not Available",
                mobile: data['m_mobile'] ?? "N/A",
                relation: "Mother",
                imageUrl: data['mother_image_name'] != null
                    ? "${durl}uploads/parent_image/" + data['mother_image_name']
                    : "https://via.placeholder.com/100",
              ),
            ];
          });

          fatherMobileController.text = parents[0].mobile;
          motherMobileController.text = parents[1].mobile;
        }
      } else {
        log('Failed to load parent details with status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error during parent API request: $e');
    }
  }

  Future<void> _fetchStudents() async {
    try {
      http.Response response = await http.post(
        Uri.parse("${url}get_childs"),
        body: {
          'reg_id': regId,
          'academic_yr': academicYr,
          'short_name': shortName,
        },
      );

      log('Response get_childs: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body
            .contains("Student data not found in current academic year")) {
          setState(() {
            students = [];
            guardian = null; // Reset guardian
            showNoDataMessage = true;
            isLoading = false;
          });
        } else {
          List<dynamic> apiResponse = json.decode(response.body);
          setState(() {
            students = apiResponse
                .map((student) => Student.fromJson(student))
                .toList();

            // Extract Guardian Info from first student record (assuming same guardian for all siblings)
            if (apiResponse.isNotEmpty) {
              Map<String, dynamic> guardianData =
                  apiResponse[0]; // Take the first student's guardian info
              guardian = GURInfo(
                id: guardianData['parent_id'] ?? "",
                GURname: guardianData['guardian_name'] ?? "Not Available",
                GURmobile: guardianData['guardian_mobile'] ?? "N/A",
                GURrelation: guardianData['relation'] ?? "Guardian",
                GURimageUrl: guardianData['guardian_image_name'] != null
                    ? "${durl}uploads/parent_image/" +
                        guardianData['guardian_image_name']
                    : "https://via.placeholder.com/100",
              );
            }
            guardianMobileController.text = guardian!.GURmobile;
            guardianNameController.text = guardian!.GURname;
            guardianRelationController.text = guardian!.GURrelation;

            showNoDataMessage = false;
            isLoading = false;
          });
        }
      } else {
        log('Failed to load students with status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error during HTTP request: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateGuardianMobile(String newMobile) async {
    // if (newMobile.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text("Mobile number cannot be empty."),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    try {
      final response = await http.post(
        Uri.parse("${durl}index.php/IdcardApi/idcard_details"),
        body: {
          'academic_yr': academicYr,
          'parent_id': regId,
          'short_name': shortName,
          'confirm': 'Y',
          'f_mobile': parents[0].mobile,
          'm_mobile': parents[1].mobile,
          'guardian_mobile': newMobile,
          'guardian_mobile': guardianMobileController.text,
          'guardian_name': guardianNameController.text,
          'relation': guardianRelationController.text,
          if (_fatherImageBase64.isNotEmpty)
            'f_datafile_str': _fatherImageBase64,
          if (_fatherImageBase64.isNotEmpty) 'f_file_name': _fatherFileName,
          if (_motherImageBase64.isNotEmpty)
            'm_datafile_str': _motherImageBase64,
          if (_motherImageBase64.isNotEmpty) 'm_file_name': _motherFileName,
          if (_guardianImageBase64.isNotEmpty)
            'g_datafile_str': _guardianImageBase64,
          if (_guardianImageBase64.isNotEmpty) 'g_file_name': _guardianFileName,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Guardian Details updated successfully."),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          guardian!.GURmobile = newMobile;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update guardian Details."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateParentMobile(
      String parentId, String newMobile, String relation) async {
    if (newMobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mobile number cannot be empty."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${durl}index.php/IdcardApi/idcard_details"),
        body: {
          'academic_yr': academicYr,
          'parent_id': regId,
          'short_name': shortName,
          'confirm': 'Y',
          'f_mobile': relation == "Father" ? newMobile : parents[0].mobile,
          'm_mobile': relation == "Mother" ? newMobile : parents[1].mobile,
          'guardian_mobile': guardianMobileController.text,
          'guardian_name': guardianNameController.text,
          'relation': guardianRelationController.text,
          if (_fatherImageBase64.isNotEmpty)
            'f_datafile_str': _fatherImageBase64,
          if (_fatherImageBase64.isNotEmpty) 'f_file_name': _fatherFileName,
          if (_motherImageBase64.isNotEmpty)
            'm_datafile_str': _motherImageBase64,
          if (_motherImageBase64.isNotEmpty) 'm_file_name': _motherFileName,
          if (_guardianImageBase64.isNotEmpty)
            'g_datafile_str': _guardianImageBase64,
          if (_guardianImageBase64.isNotEmpty) 'g_file_name': _guardianFileName,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Parent Details updated successfully."),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          if (relation == "Father") {
            parents[0].mobile = newMobile;
          } else if (relation == "Mother") {
            parents[1].mobile = newMobile;
          }
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update Parent Details."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateStudent(Student updatedStudent) {
    setState(() {
      final index =
          students.indexWhere((s) => s.studentId == updatedStudent.studentId);
      if (index != -1) {
        students[index] = updatedStudent; // Update the student in the list
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "ID Card Details",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.white),
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
          padding: const EdgeInsets.only(top: 110.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : showNoDataMessage
                  ? const Center(
                      child: Text("No students found for this academic year."))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Student Cards
                          ...students.map((student) => StudentCardID(
                              student: student,
                              onStudentUpdated: _updateStudent)),

                          Column(
                            children: [
                              if (parents.isNotEmpty) ...[
                                _buildParentSection(parents[0]), // Father
                                _buildParentSection(parents[1]), // Mother
                              ],

                              if (guardian != null)
                                _buildGuardianSection(guardian!),
                              // Guardian
                            ],
                          ),

                          // Parent Cards

                          // Declaration & Submit Button
                          const SizedBox(height: 0),
                          _buildDeclarationCard(),
                          const SizedBox(height: 10),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildParentSection(ParentInfo parent) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: parent.relation == "Father"
                  ? _fatherImage != null
                      ? Image.file(
                          _fatherImage!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : _buildNetworkImage(parent.imageUrl)
                  : _motherImage != null
                      ? Image.file(
                          _motherImage!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : _buildNetworkImage(parent.imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parent.relation,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(parent.name, style: const TextStyle(fontSize: 15)),
                  TextFormField(
                      controller: parent.relation == "Father"
                          ? fatherMobileController
                          : motherMobileController,
                      decoration: InputDecoration(
                        labelText: "Mobile:",
                      ),
                      style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _pickImage(parent.relation.toLowerCase());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => Container(
        width: 70,
        height: 70,
        color: Colors.grey[300],
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      ),
      // Add cache key to force refresh
      cacheKey: '${url}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Widget _buildGuardianSection(GURInfo guardian) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _guardianImage != null
                    ? Image.file(
                        _guardianImage!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                    : _buildNetworkImage(guardian.GURimageUrl)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('Guardian: ${guardian.GURrelation}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  // const SizedBox(height: 4),
                  // Text(guardian.GURname, style: const TextStyle(fontSize: 15)),
                  TextFormField(
                      controller: guardianNameController,
                      decoration: InputDecoration(
                        labelText: "Guardian Name:",
                      ),
                      style: const TextStyle(fontSize: 15)),
                  TextFormField(
                      controller: guardianRelationController,
                      decoration: InputDecoration(
                        labelText: "Guardian Relation:",
                      ),
                      style: const TextStyle(fontSize: 15)),
                  TextFormField(
                      controller: guardianMobileController,
                      decoration: InputDecoration(
                        labelText: "Guardian Mobile:",
                      ),
                      style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _pickImage("guardian");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeclarationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value ?? false;
                });
              },
            ),
            const Expanded(
              child: Text(
                  "I hereby declare that the information provided is true and correct."),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        List<String> studentsNeedingImages = [];
        for (var student in students) {
          // Print detailed logs for each student's image
          log('Student: ${student.fullName}');
          log('Image URL: ${student.imageUrl}');

          bool needsImage = false;

          // Check for placeholder images
          if (student.imageUrl.contains("via.placeholder.com") ||
              student.imageUrl.contains("assets/girl.png") ||
              student.imageUrl.contains("assets/boy.png") ||
              student.imageUrl.endsWith("/")) {
            needsImage = true;
            log('Invalid image: Placeholder or fallback detected');
          }
          // Check for possible 404 URLs
          else if (student.imageUrl.startsWith("http")) {
            try {
              final response = await http.head(Uri.parse(student.imageUrl));
              if (response.statusCode == 404) {
                needsImage = true;
                log('Invalid image: 404 Not Found');
              }
            } catch (e) {
              needsImage = true;
              log('Invalid image: Error checking URL ($e)');
            }
          }

          log('Needs image: $needsImage');
          log('----------------------------------');

          if (needsImage) {
            // Split name and take first two parts
            List<String> nameParts = student.fullName.split(' ');
            String displayName = nameParts.length > 2
                ? '${nameParts[0]} ${nameParts[1]}'
                : student.fullName;
            studentsNeedingImages.add(displayName);
          }
        }

        log('Total students needing images: ${studentsNeedingImages.length}');
        log('Students needing images: ${studentsNeedingImages.join(', ')}');

        if (studentsNeedingImages.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Please upload profile picture for ${studentsNeedingImages.join(', ')}",
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        // if (_fatherImage == null && _motherImage == null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text("Please upload any one parent's profile picture."),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        //   return;
        // }

        log('_fatherImageBase64 ID: $_fatherImageBase64');
        log('_fatherImage ID: $_fatherImage');
        log('_fatherFileName ID: ${parents[0].imageUrl}');
        log('mother imgurl ID: ${parents[1].imageUrl}');
        log('mother imgurl ID: ${motherMobileController.text}');

        // Helper function to check if image URL is valid
        bool isValidImageUrl(String url) {
          return url.isNotEmpty &&
              !url.endsWith('/') &&
              !url.contains("via.placeholder.com");
        }

        if (fatherMobileController.text.isNotEmpty &&
            fatherMobileController.text.length != 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Please enter a valid 10-digit mobile number for the father."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (motherMobileController.text.isNotEmpty &&
            motherMobileController.text.length != 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Please enter a valid 10-digit mobile number for the mother."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Validate that at least one of the parents has both a profile picture and a mobile number
        bool isFatherDataComplete = fatherMobileController.text.isNotEmpty &&
                isValidImageUrl(parents[0].imageUrl) ||
            _fatherImageBase64.isNotEmpty;
        bool isMotherDataComplete = motherMobileController.text.isNotEmpty &&
                isValidImageUrl(parents[1].imageUrl) ||
            _motherImageBase64.isNotEmpty;

        if (!isFatherDataComplete && !isMotherDataComplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Please provide at least one parent's mobile number and profile picture."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        log('_fatherImageBase64 ID: $_fatherImageBase64');
        log('_fatherImage ID: $_fatherImage');
        log('_fatherFileName ID: ${parents[0].imageUrl}');
        log('mother imgurl ID: ${parents[1].imageUrl}');
        // log('_guardianImage: ${guardian.GURimageUrl}');
        log('_guardianImage: $_guardianImage');
        log('mother imgurl ID: ${motherMobileController.text}');

        // Validate that if either parent has a profile picture or a mobile number, both are provided
        // if (fatherMobileController.text.isNotEmpty && !isValidImageUrl(parents[0].imageUrl) || _fatherImageBase64.isNotEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text("Please upload father's profile picture."),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        //   return;
        // }

        if (isValidImageUrl(parents[0].imageUrl) &&
            fatherMobileController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please enter father's mobile number."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // if (motherMobileController.text.isNotEmpty && !isValidImageUrl(parents[1].imageUrl) && _motherImageBase64.isNotEmpty) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text("Please upload mother's profile picture."),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        //   return;
        // }

        if (isValidImageUrl(parents[1].imageUrl) &&
            motherMobileController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please enter mother's mobile number."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // At least one parent must have both image and mobile
        // if (!(fatherHasMobile && fatherHasImage) && !(motherHasMobile && motherHasImage)) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text("At least one parent must have both image and mobile number"),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        //   return;
        // }

        // Check if at least one parent's image is uploaded (either from backend or locally)
        // bool isFatherImageUploaded = parents[0].imageUrl != "https://via.placeholder.com/100" || _fatherImage != null;
        // bool isMotherImageUploaded = parents[1].imageUrl != "https://via.placeholder.com/100" || _motherImage != null;
        //
        // if (parents[0].imageUrl == "https://holyspiritconvent.evolvu.in/test/hscs_test/uploads/parent_image/"
        //     && parents[1].imageUrl == "https://holyspiritconvent.evolvu.in/test/hscs_test/uploads/parent_image/") {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text("Please upload any one parent's profile picture."),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        //   return;
        // }
        //
        // // Validate father's data if image is uploaded (either from backend or locally)
        // if (isFatherImageUploaded) {
        //   if (fatherMobileController.text.isEmpty) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text("Please enter father's mobile number."),
        //         backgroundColor: Colors.red,
        //       ),
        //     );
        //     return;
        //   }
        //
        //   if (fatherMobileController.text.length != 10) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text("Please enter a valid 10-digit mobile number for the father."),
        //         backgroundColor: Colors.red,
        //       ),
        //     );
        //     return;
        //   }
        // }
        //
        // // Validate mother's data if image is uploaded (either from backend or locally)
        // if (parents[1].imageUrl != "https://holyspiritconvent.evolvu.in/test/hscs_test/uploads/parent_image/") {
        //   if (motherMobileController.text.isEmpty) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text("Please enter mother's mobile number."),
        //         backgroundColor: Colors.red,
        //       ),
        //     );
        //     return;
        //   }
        //
        //   if (motherMobileController.text.length != 10) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text("Please enter a valid 10-digit mobile number for the mother."),
        //         backgroundColor: Colors.red,
        //       ),
        //     );
        //     return;
        //   }
        // }

        // Validate guardian's data and image (optional but must be complete if any field is filled)

        bool isGuardianDataPartiallyFilled =
            guardianMobileController.text.isNotEmpty ||
                guardianNameController.text.isNotEmpty ||
                guardianRelationController.text.isNotEmpty ||
                _guardianImageBase64.isNotEmpty ||
                _guardianImage != null;

        if (isGuardianDataPartiallyFilled) {
          // If any guardian field is filled, ensure all required fields are filled
          if (guardianNameController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please enter guardian's name."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (guardianMobileController.text.length != 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "Please enter a valid 10-digit guardian mobile number."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (guardianRelationController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please enter guardian's relation."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (_guardianImage == null && guardian!.GURimageUrl.endsWith('/')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please upload guardian's profile picture."),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        // Validate if the checkbox is checked
        if (!isChecked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Please confirm the declaration by checking the checkbox."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // If all validations pass, update the data
        await _updateParentMobile(
            parents[0].id, fatherMobileController.text, "Father");
        await _updateParentMobile(
            parents[1].id, motherMobileController.text, "Mother");
        await _updateGuardianMobile(guardianMobileController.text);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: const Text("Submit",
          style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}

class ParentInfo {
  final String id;
  final String name;
  String mobile;
  final String relation;
  final String imageUrl;

  ParentInfo({
    required this.id,
    required this.name,
    required this.mobile,
    required this.relation,
    required this.imageUrl,
  });

  factory ParentInfo.fromJson(
      Map<String, dynamic> json, String relation, String url) {
    return ParentInfo(
      id: json['parent_id'] ?? "",
      name: json[relation == "Father" ? 'father_name' : 'mother_name'] ??
          "Not Available",
      mobile: json[relation == "Father" ? 'f_mobile' : 'm_mobile'] ?? "N/A",
      relation: relation,
      imageUrl: json[relation == "Father"
                  ? 'father_image_name'
                  : 'mother_image_name'] !=
              null
          ? "${durl}uploads/parent_image/" +
              json[relation == "Father"
                  ? 'father_image_name'
                  : 'mother_image_name']
          : "https://via.placeholder.com/100",
    );
  }
}

class GURInfo {
  final String id;

  final String GURname;
  String GURmobile;
  final String GURrelation;
  final String GURimageUrl;

  GURInfo({
    required this.id,
    required this.GURname,
    required this.GURmobile,
    required this.GURrelation,
    required this.GURimageUrl,
  });

  factory GURInfo.fromJson(
      Map<String, dynamic> json, String relation, String url) {
    return GURInfo(
      id: json['parent_id'] ?? "",
      GURname: json['guardian_name'] ?? "Not Available",
      GURmobile: json['guardian_mobile'] ?? "N/A",
      GURrelation: json['relation'] ?? "Guardian",
      GURimageUrl: json['guardian_image_name'] != null
          ? "${durl}uploads/parent_image/" + json['guardian_image_name']
          : "https://via.placeholder.com/100",
    );
  }
}

class Student {
  final String studentId;
  final String fullName;
  final String classDivision;
  final String dob;
  final String bloodGroup;
  final String address;
  final String imageUrl;
  final String gender;

  Student({
    required this.studentId,
    required this.fullName,
    required this.classDivision,
    required this.dob,
    required this.bloodGroup,
    required this.address,
    required this.imageUrl,
    required this.gender,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'].toString(),
      fullName: json['student_name'] +
          " " +
          json['mid_name'] +
          " " +
          json['last_name'],
      classDivision: "${json['class_name']} ${json['section_name']}",
      dob: json['dob'],
      bloodGroup: json['blood_group'] ?? "Unknown",
      address: json['permant_add'] ?? "Not Available",
      gender: json['gender'] ?? "",
      imageUrl: json['image_name'] != null
          ? "${durl}uploads/student_image/" + json['image_name']
          : "https://via.placeholder.com/100",
    );
  }
}

class StudentCardID extends StatelessWidget {
  final Student student;
  final Function(Student) onStudentUpdated;

  const StudentCardID(
      {super.key, required this.student, required this.onStudentUpdated});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Image
            SizedBox.square(
              dimension: 70.w,
              child: CachedNetworkImage(
                imageUrl:
                    '${student.imageUrl}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Image.asset(
                  student.gender == 'M' ? 'assets/boy.png' : 'assets/girl.png',
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Student Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Name", student.fullName),
                  _buildDetailRow("Class", student.classDivision),
                  _buildDetailRow("Date of Birth", student.dob),
                  _buildDetailRow("Blood Group", student.bloodGroup),
                  _buildDetailRow("Address", student.address, maxLines: 2),
                ],
              ),
            ),

            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final updatedStudent = await Navigator.push<Student>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditStudentFormScreen(
                        student: student, onStudentUpdated: onStudentUpdated),
                  ),
                );

                if (updatedStudent != null) {
                  // Update the student in the list
                  onStudentUpdated(updatedStudent);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          text: "$label: ",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          children: [
            TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
