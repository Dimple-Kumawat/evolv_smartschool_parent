import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer';
import 'AcademicYearProvider.dart';

class ChangeAcademicYearScreen extends StatefulWidget {
  final String academic_yr;
  final String shortName;
  const ChangeAcademicYearScreen(
      {super.key, required this.academic_yr, required this.shortName});
  @override
  _ChangeAcademicYearScreenState createState() =>
      _ChangeAcademicYearScreenState();
}

class _ChangeAcademicYearScreenState extends State<ChangeAcademicYearScreen> {
  List<String> academicYearList = [
    "Select Academic Year"
  ]; // Default dropdown item
  String selectedAcademicYear = "Select Academic Year";
  String currentAcademicYear = "";
  bool isLoading = true;
  // String? shortName;
  // String? url;

  @override
  void initState() {
    super.initState();
    // _loadStoredData();
    fetchAcademicYearList();
  }

  /// Load stored `shortName`, `url`, and `currentAcademicYear` from SharedPreferences
  // Future<void> _loadStoredData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     shortName = prefs.getString('short_name') ?? "";
  //     url = prefs.getString('url') ?? "";
  //     currentAcademicYear = prefs.getString('academic_year') ?? "";
  //   });
  //
  //   fetchAcademicYearList();
  // }

  /// Fetch available academic years from the API
  Future<void> fetchAcademicYearList() async {
    // if ( shortName == null) return;
    log('Failed to load academic years $shortName');

    final response = await http.post(
      Uri.parse('${url}get_academic_years_list'),
      body: {'short_name': shortName},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        academicYearList.addAll(
          jsonResponse.map((year) => year['academic_yr'].toString()).toList(),
        );
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      log('Failed to load academic years');
    }
  }

  Future<void> changeAcademicYear(String newAcademicYear) async {
    if (newAcademicYear == "Select Academic Year") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an academic year')),
      );
      return;
    }

    if (newAcademicYear == currentAcademicYear) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Academic year is already selected')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${url}get_academic_year'),
      body: {'short_name': shortName},
    );

    if (response.statusCode == 200) {
      log('Academic Year Changed: ${response.body}');
      log('newAcademicYear $newAcademicYear');

      // ✅ Store new academic year in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('academic_year', newAcademicYear);

      final academicYearProvider =
          Provider.of<AcademicYearProvider>(context, listen: false);
      academicYearProvider.setAcademicYear(newAcademicYear);

      // ✅ Notify the app of the change
      // You can use a callback or a state management solution here
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ParentDashBoardPage(
                academic_yr: newAcademicYear, shortName: shortName)),
        (Route<dynamic> route) => false,
      );
    } else {
      log('Failed to change academic year');
    }
  }

  @override
  Widget build(BuildContext context) {
    final academicYearProvider =
        Provider.of<AcademicYearProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Change Academic Year",
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 300),
          child: Center(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 18.w, vertical: 5.h),
                              child: DropdownButton<String>(
                                value: selectedAcademicYear,
                                isExpanded: true,
                                underline: SizedBox(),
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.blueAccent),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedAcademicYear = newValue!;
                                  });
                                },
                                items: academicYearList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.black),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                    SizedBox(height: 30.h),
                    ElevatedButton(
                      onPressed: () {
                        changeAcademicYear(selectedAcademicYear);
                        academicYearProvider.setAcademicYear("2023-2024");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Change Academic Year',
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                    ),
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
