import 'dart:convert';
import 'dart:developer';
import 'package:evolvu/Teacher/teacher_DeatilCard.dart';
import 'package:evolvu/Teacher/teacher_noteCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TeacherNotePage extends StatefulWidget {
  final String academic_yr;
  final String shortName;
  final String studentId;
  final String classId;
  final String secId;

  const TeacherNotePage({
    super.key,
    required this.studentId,
    required this.academic_yr,
    required this.shortName,
    required this.classId,
    required this.secId,
  });

  @override
  _TeacherNotePageState createState() => _TeacherNotePageState();
}

class _TeacherNotePageState extends State<TeacherNotePage> {
  late Future<List<TeacherNote>> futureNotes;
  String reg_id = "";
  String url = "";

  Future<List<TeacherNote>> fetchTeacherNotes() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');
    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
        reg_id = logUrlsparsed['reg_id'];
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        url = parsedData['url'];
      } catch (e) {
        log('Error parsing school info: $e');
      }
    } else {
      log('School info not found in SharedPreferences.');
    }

    final response = await http.post(
      Uri.parse("${url}get_teachernote_with_multiple_attachment"),
      body: {
        'class_id': widget.classId,
        'section_id': widget.secId,
        'parent_id': reg_id,
        'academic_yr': widget.academic_yr,
        'short_name': widget.shortName,
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      log(data.toString());
      return data.map((item) => TeacherNote.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load teacher notes');
    }
  }

  @override
  void initState() {
    super.initState();
    futureNotes = fetchTeacherNotes();
  }

  Future<void> refreshfetchTeacherNotes() async {
    setState(() {
      futureNotes = fetchTeacherNotes(); // Refresh the homework notes
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
                "Teacher Note",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: FutureBuilder<List<TeacherNote>>(
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
                              SizedBox(
                                  height:
                                      10), // Add spacing between emoji and text
                              Text(
                                'Teacher Notes not Assigned',
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
                              SizedBox(
                                  height:
                                      10), // Add spacing between emoji and text
                              Text(
                                'Teacher Notes not Assigned',
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
                      final notes = snapshot.data!;
                      return ListView.builder(
                        padding: EdgeInsets.only(top: 10.h),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: NoteCard(
                              name: note.name,
                              date: note.date,
                              note: note.description,
                              subject: note.subjectName,
                              classname: note.className,
                              sectionname: note.sectionname,
                              readStatus: note.read_status,
                              showDownloadIcon: note.imageList,
                              onTap: () async {
                                // Navigate to TeacherDetailCard and wait for the result
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TeacherDetailCard(
                                      shortName: widget.shortName,
                                      academic_yr: widget.academic_yr,
                                      name: note.name,
                                      notesId: note.notesId,
                                      date: note.date,
                                      note: note.description,
                                      subject: note.subjectName,
                                      className: note.className,
                                      sectionname: note.sectionname,
                                      imageList: note.imageList,
                                    ),
                                  ),
                                );

                                // Refresh the page if the result is true
                                if (result == true) {
                                  refreshfetchTeacherNotes();
                                }
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
}
