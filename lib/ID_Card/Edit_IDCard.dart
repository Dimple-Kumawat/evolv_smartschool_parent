import 'dart:convert';
import 'dart:io';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'Parent_IDCard.dart';

class EditStudentFormScreen extends StatefulWidget {
  final Student student;
  final Function(Student) onStudentUpdated;
  const EditStudentFormScreen({super.key, required this.student, required this.onStudentUpdated});

  @override
  _EditStudentFormScreenState createState() => _EditStudentFormScreenState();
}

class _EditStudentFormScreenState extends State<EditStudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  // late TextEditingController _fullNameController;
  // late TextEditingController _classDivisionController;
  // late TextEditingController _dobController;
  // late TextEditingController _bloodGroupController;
  String? _selectedBloodGroup;
  late TextEditingController _addressController;

  String imageUrl = "";  // Store the image URL here
  File? file;
  bool _isLoading = false; // To show a progress indicator
  @override
  void initState() {
    super.initState();
    // _fullNameController = TextEditingController(text: widget.student.fullName);
    // _classDivisionController = TextEditingController(text: widget.student.classDivision);
    // _dobController = TextEditingController(text: widget.student.dob);
    // _bloodGroupController = TextEditingController(text: widget.student.bloodGroup);
    _selectedBloodGroup = widget.student.bloodGroup;
    _addressController = TextEditingController(text: widget.student.address);

    // Initialize image URL with the student's existing image
    imageUrl = widget.student.imageUrl;
  }

  @override
  void dispose() {
    // _fullNameController.dispose();
    // _classDivisionController.dispose();
    // _dobController.dispose();
    // _bloodGroupController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    bool needsImage = false;
    if (imageUrl.startsWith("http")) {
      try {
        final response = await http.head(Uri.parse(imageUrl));
        if (response.statusCode == 404) {
          needsImage = true;
          print('Invalid image: 404 Not Found');
          Fluttertoast.showToast(
            msg: "Please Upload Student Profile picture",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }
      } catch (e) {
        needsImage = true;
        print('Invalid image: Error checking URL ($e)');
      }
    }

    print('imageUrl: $imageUrl');
    if(imageUrl.endsWith('/')){
      Fluttertoast.showToast(
        msg: "Please Upload Student Profile picture",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      if (_selectedBloodGroup == null || _selectedBloodGroup!.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please select a blood group",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        print('durl: $durl/index.php/IdcardApi/student_idcard_details');

        final response = await http.post(

          Uri.parse('${durl}index.php/IdcardApi/student_idcard_details'),
          body: {
            'short_name': shortName,
            'student_id': widget.student.studentId,
            'blood_group': _selectedBloodGroup,
            'address': _addressController.text,
            'academic_yr': academic_yr,
          },
        );
        print('durl: $shortName');
        print('academic_yr: $academic_yr');
        print('widget.student.studentId: ${widget.student.studentId}');

        if (response.statusCode == 200) {
          // Handle successful response
          Fluttertoast.showToast(
            msg: "Student ID Card Details Updated Successfully",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          Student updatedStudent = Student(
            studentId: widget.student.studentId,
            fullName: widget.student.fullName,
            classDivision: widget.student.classDivision,
            dob: widget.student.dob,
            bloodGroup: _selectedBloodGroup!,
            address: _addressController.text,
            gender: widget.student.gender,
            imageUrl: imageUrl, // Updated image URL
          );

          // Navigate back to the previous screen
          Navigator.pop(context,updatedStudent);
          // Navigator.pop(context);
        } else {
          // Handle error response
          Fluttertoast.showToast(
            msg: "Failed to Update",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        // Handle network or other errors
        Fluttertoast.showToast(
          msg: "An error occurred: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }


  Future<void> uploadImage(ImageSource source) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: source,
        // Add this line to handle dismissal properly
        preferredCameraDevice: CameraDevice.rear,
      ).catchError((error) {
        // Handle if user cancels the picker
        print("Image picker cancelled: $error");
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
      print("Error in uploadImage: $e");
    }
  }

  Future<File?> cropImage(File pickedFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          statusBarColor: Colors.blue,
          backgroundColor: Colors.white,
          // Add these settings for better discard handling
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        iosUiSettings: const IOSUiSettings(
          // minimumAspectRatio: 1.0,
          // Add these settings for iOS
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
        ),
      );

      if (croppedFile == null) {
        // User pressed back or cancel
        return null;
      }

      return File(croppedFile.path);
    } catch (e) {
      print("Error in cropImage: $e");
      return null;
    }
  }

  Future<String> uploadImageToServer(File croppedImage, String base64Image) async {
    try {
      var response = await http.post(
        Uri.parse("${url}upload_student_profile_image_into_folder"),
        body: {
          'student_id': widget.student.studentId,
          'short_name': shortName,
          'filename': "${widget.student.studentId}.jpg",
          'doc_type_folder': 'student_image',
          'filedata': base64Image,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          imageUrl =
          "${durl}uploads/student_image/${widget.student.studentId}.jpg?timestamp=${DateTime.now().millisecondsSinceEpoch}";
        });

        Fluttertoast.showToast(
          msg: "Profile Picture updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

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
      print("Error uploading image: $e");
      throw Exception('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "Edit Student Details",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Card(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Updated Student Image
                        CircleAvatar(
                          radius: 75.w,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(imageUrl),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () {
                              uploadImage(ImageSource.gallery);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildReadOnlyField("Full Name", widget.student.fullName, Icons.person),

                        // Class-Division (Read-only)
                        _buildReadOnlyField("Class-Division", widget.student.classDivision, Icons.school),

                        // DOB (Read-only)
                        _buildReadOnlyField("Date of Birth", widget.student.dob, Icons.calendar_today),

                        // Blood Group (Editable Dropdown)
                        LabeledDropdownID(
                          label: "Blood Group",
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
                          selectedValue: _selectedBloodGroup,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBloodGroup = newValue; // Update selected blood group
                            });
                          },
                        ),

                        // Address (Editable)
                        _buildTextField("Address", _addressController, Icons.home, maxLines: 2),

                        const SizedBox(height: 20),

                        // Save Changes Button
                        _isLoading
                            ? CircularProgressIndicator() // Show loading indicator
                            : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        readOnly: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}

class LabeledDropdownID extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onChanged;

  const LabeledDropdownID({super.key, 
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedValue,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

