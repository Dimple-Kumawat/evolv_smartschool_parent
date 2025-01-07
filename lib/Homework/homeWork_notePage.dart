import 'dart:convert';
import 'package:evolvu/Homework/homework_DetailCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:evolvu/Homework/homeWork_noteCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeWorkNotePage extends StatefulWidget {
  final String studentId;
  final String academic_yr;
  final String shortName;
  final String classId;
  final String secId;

  HomeWorkNotePage({
    required this.studentId,
    required this.academic_yr,
    required this.shortName,
    required this.classId,
    required this.secId,
  });

  @override
  _HomeWorkNotePage createState() => _HomeWorkNotePage();
}

class _HomeWorkNotePage extends State<HomeWorkNotePage> {
  late Future<List<Homework>> futureNotes;
  String shortName = "";
  String academic_yr = "";
  String reg_id = "";
  String url = "";

  @override
  void initState() {
    super.initState();
    futureNotes = fetchHomework();
  }

  Future<List<Homework>> fetchHomework() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');

    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        academic_yr = logUrlsparsed['academic_yr'];
        reg_id = logUrlsparsed['reg_id'];
      } catch (e) {
        print('Error parsing logUrls: $e');
      }
    } else {
      print('LogUrls not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        shortName = parsedData['short_name'];
        url = parsedData['url'];
      } catch (e) {
        print('Error parsing schoolInfoJson: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
    }

    final response = await http.post(
      Uri.parse(url + 'get_homework'),
      body: {
        'student_id': widget.studentId,
        'class_id': widget.classId,
        'section_id': widget.secId,
        'parent_id': reg_id,
        'academic_yr': academic_yr,
        'short_name': shortName,
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('No homework assigned');
      }

      try {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((homework) => Homework.fromJson(homework)).toList();
      } catch (e) {
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception('Failed to load homework: ${response.statusCode}');
    }
  }

  Future<void> refreshHomeworkNotes() async {
    setState(() {
      futureNotes = fetchHomework(); // Refresh the homework notes
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Pop until reaching the HistoryTab route
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 50.h,
          title: Text(
            "${widget.shortName} EvolvU Smart Parent App(${widget.academic_yr})",
            style: TextStyle(fontSize: 14.sp, color: Colors.white),
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
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Text(
                "Student HomeWork",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: FutureBuilder<List<Homework>>(
                  future: futureNotes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Add emoji or animation here
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: Image.asset(
                                  'assets/animations/nodata.gif', // Replace with your emoji or animation file
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 10), // Add spacing between emoji and text
                              Text(
                                'No Homework Assigned',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Add emoji or animation here
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: Image.asset(
                                  'assets/animations/nodata.gif', // Replace with your emoji or animation file
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 10), // Add spacing between emoji and text
                              Text(
                                'No Homework Assigned',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.only(top: 10.h),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final note = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: HomeWorkNoteCard(
                              subject: note.subjectName,
                              assignedDate: note.startDate,
                              submissionDate: truncateEndDate(note.endDate),
                              status: note.homeworkStatus,
                              readStatus: note.readStatus,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomeWorkDetailCard(
                                      shortName: shortName,
                                      academic_yr: academic_yr,
                                      subject: note.subjectName,
                                      assignedDate: note.startDate,
                                      submissionDate: truncateEndDate(note.endDate),
                                      status: note.homeworkStatus,
                                      homeworkId: note.homeworkId,
                                      parentComment: note.parentComment,
                                      className: note.className,
                                      description: note.description,
                                      imageList: note.imageList,
                                      studentId: note.studentId,
                                      comment_id: note.commentId,
                                      Tcomment: note.comment,
                                      publishDate: note.publishDate,
                                    ),
                                  ),
                                );
                                refreshHomeworkNotes(); // Refresh notes after returning from the detail page
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String truncateEndDate(String endDate) {
    List<String> parts = endDate.split(' ');
    if (parts.length > 1) {
      return parts[0]; // Return the date part only
    }
    return endDate;
  }
}
