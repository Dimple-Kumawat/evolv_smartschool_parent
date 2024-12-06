import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Parent/parentDashBoard_Page.dart';

class TimeTablePage extends StatefulWidget {
  final String studentId;
  final String academic_yr;
  final String shortName;
  final String classId;
  final String secId;
  final String className;

  TimeTablePage({
    required this.studentId,
    required this.academic_yr,
    required this.shortName,
    required this.classId,
    required this.secId,
    required this.className,
  });

  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  Map<String, List<Period>> timetable = {};
  Map<String, String> subjectTeachers = {}; // Map to hold subjects and their respective teachers
  int selectedIndex = 0;
  late PageController _pageController;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    DateTime now = DateTime.now();
    selectedIndex = now.weekday - 1;
    if (selectedIndex > 5) selectedIndex = 0;
    _pageController = PageController(initialPage: selectedIndex);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await _fetchSubjects(); // Fetch the subjects and their teachers
    await _fetchTimetable(); // Fetch the timetable and match the teachers
  }

  Future<void> _fetchSubjects() async {
    try {
      final response = await http.post(Uri.parse(url + "get_all_subjects"),
        body: {
          'short_name': widget.shortName,
          'section_id': widget.secId,
          'class_id': widget.classId,
          'academic_yr': widget.academic_yr
        },
      );

      if (response.statusCode == 200) {
        print('Subjects Response: ${response.body}');

        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          subjectTeachers = Map<String, String>.from(data); // Store the subjects and teachers
        });
      } else {
        setState(() {
          errorMessage = "Failed to load subjects: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching subjects: $e";
      });
    }
  }

  Future<void> _fetchTimetable() async {
    try {
      final response = await http.post(Uri.parse(url + "get_timetable"),
        body: {
          'short_name': widget.shortName,
          'section_id': widget.secId,
          'class_id': widget.classId,
          'academic_yr': widget.academic_yr
        },
      );

      if (response.statusCode == 200) {
        print('Timetable Response: ${response.body}');

        List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          setState(() {
            errorMessage = "No timetable data available.";
          });
        } else {
          Map<String, List<Period>> tempTimetable = {
            "Mon": [],
            "Tue": [],
            "Wed": [],
            "Thu": [],
            "Fri": [],
            "Sat": [],
          };

          for (var periodData in data) {
            tempTimetable['Mon']?.add(Period(
              time: "${periodData['time_in'] ?? ''} - ${periodData['time_out'] ?? ''}",
              subject: periodData['monday'] ?? '',
              icon: Icons.book,
              teacher: subjectTeachers[periodData['monday']] ?? 'N/A',
            ));
            tempTimetable['Tue']?.add(Period(
              time: "${periodData['time_in'] ?? ''} - ${periodData['time_out'] ?? ''}",
              subject: periodData['tuesday'] ?? '',
              icon: Icons.book,
              teacher: subjectTeachers[periodData['tuesday']] ?? 'N/A',
            ));
            tempTimetable['Wed']?.add(Period(
              time: "${periodData['time_in'] ?? ''} - ${periodData['time_out'] ?? ''}",
              subject: periodData['wednesday'] ?? '',
              icon: Icons.book,
              teacher: subjectTeachers[periodData['wednesday']] ?? 'N/A',
            ));
            tempTimetable['Thu']?.add(Period(
              time: "${periodData['time_in'] ?? ''} - ${periodData['time_out'] ?? ''}",
              subject: periodData['thursday'] ?? '',
              icon: Icons.book,
              teacher: subjectTeachers[periodData['thursday']] ?? 'N/A',
            ));
            tempTimetable['Fri']?.add(Period(
              time: "${periodData['time_in'] ?? ''} - ${periodData['time_out'] ?? ''}",
              subject: periodData['friday'] ?? '',
              icon: Icons.book,
              teacher: subjectTeachers[periodData['friday']] ?? 'N/A',
            ));
            tempTimetable['Sat']?.add(Period(
              time: "${periodData['sat_in'] ?? ''} - ${periodData['sat_out'] ?? ''}",
              subject: periodData['saturday'] ?? '',
              icon: Icons.book,
              teacher: subjectTeachers[periodData['saturday']] ?? 'N/A',
            ));
          }

          setState(() {
            timetable = tempTimetable;
            errorMessage = ""; // Clear any previous error message
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error: ${response.statusCode}. Please try again later.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching timetable: $e. Please check your connection and try again.";
      });
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
          "Student Timetable",
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Card(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(days.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          _pageController.jumpToPage(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 11),
                          decoration: BoxDecoration(
                            color: selectedIndex == index ? Colors.orange : Color.fromARGB(255, 228, 218, 218),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: selectedIndex == index
                                ? [
                              const BoxShadow(
                                color: Colors.orangeAccent,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ]
                                : [],
                          ),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: selectedIndex == index ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                height: MediaQuery.of(context).size.height - 180.h,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final periods = timetable[day] ?? [];

                    final validPeriods = periods.where((period) => period.subject.isNotEmpty).toList();

                    return SingleChildScrollView(
                      child: Column(
                        children: validPeriods.map((period) => buildPeriodCard(period)).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPeriodCard(Period period) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: 
      ListTile(
        // leading: period.icon != null
        //     ? Icon(period.icon, color: Color.fromARGB(255, 139, 40, 95), size: 30) : null,
        title: Text(
          period.subject,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded( // Wrap the text in Expanded to make it fit within the available space
              child: Text(
                period.time,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
              ),
            ),
            Expanded(
              child: Text(
                ' ${period.teacher}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 139, 40, 95),
                ),
                overflow: TextOverflow.ellipsis, // This ensures the text is truncated with ellipsis if too long
                softWrap: false, // Prevents text from wrapping to the next line
                maxLines: 1, // Ensures the text takes up only one line
              ),
            ),
          ],
        ),
      ),
      
    );
  }

}

class Period {
  final String time;
  final String subject;
  final IconData? icon;
  final String teacher;

  Period({required this.time, required this.subject, this.icon, required this.teacher});
}
