import 'package:evolvu/common/common_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../Teacher/Attachment.dart';

class Remark {
  final String remarkId;
  final String remarkDesc;
  final String remarkSubject;
  final String remarkType;
  final String remarkDate;
  final String publishDate;
  final String classId;
  final String sectionId;
  final String studentId;
  final String subjectId;
  final String teacherId;
  final String academicYr;
  final String publish;
  final String acknowledge;
  final String isDelete;
  final String teacherName;
  final String remarkRLogId;
  final String readStatus;
  final List<Attachment> imageList;

  Remark({
    required this.remarkId,
    required this.remarkDesc,
    required this.remarkSubject,
    required this.remarkType,
    required this.remarkDate,
    required this.publishDate,
    required this.classId,
    required this.sectionId,
    required this.studentId,
    required this.subjectId,
    required this.teacherId,
    required this.academicYr,
    required this.publish,
    required this.acknowledge,
    required this.isDelete,
    required this.teacherName,
    required this.remarkRLogId,
    required this.readStatus,
    required this.imageList,
  });

  factory Remark.fromJson(Map<String, dynamic> json) {
    return Remark(
      remarkId: json['remark_id']?.toString() ?? '',
      remarkDesc: json['remark_desc']?.toString() ?? '',
      remarkSubject: json['remark_subject']?.toString() ?? '',
      remarkType: json['remark_type']?.toString() ?? '',
      remarkDate: json['remark_date']?.toString() ?? '',
      publishDate: json['publish_date']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      sectionId: json['section_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      subjectId: json['subject_id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? '',
      academicYr: json['academic_yr']?.toString() ?? '',
      publish: json['publish']?.toString() ?? '',
      acknowledge: json['acknowledge']?.toString() ?? '',
      isDelete: json['isDelete']?.toString() ?? '',
      teacherName: json['teachername']?.toString() ?? '',
      remarkRLogId: json['remark_r_log_id']?.toString() ?? '',
      readStatus: json['read_status']?.toString() ?? '',
      imageList: (json['image_list'] as List)
          .map((item) => Attachment.fromJson(item))
          .toList(),
    );
  }
  }

class RemarkNoteCard extends StatelessWidget {
  final String date;
  final String teacher;
  final String remarksubject;
  final String readStatus;
  final VoidCallback onTap;
  final List<Attachment> showDownloadIcon; // New parameter to control visibility

  const RemarkNoteCard({
    Key? key,
    required this.date,
    required this.teacher,
    required this.remarksubject,
    required this.readStatus,
    required this.onTap,
    required this.showDownloadIcon, // Initialize it
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    Color cardColor = readStatus == '0' ? Colors.grey : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/studying.png',
                        height: 50,
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Date: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: formattedDate,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Teacher: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '${trimTeacherName(teacher)}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Remark Subject: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            remarksubject,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 10,
            right: 12,
            child: Icon(
              Icons.remove_red_eye,
              color: Color.fromARGB(255, 175, 49, 40),
            ),
          ),
          if (showDownloadIcon.isNotEmpty) // Conditional rendering of the download icon
            const Positioned(
              top: 75,
              right: 12,
              child: Icon(
                Icons.download_for_offline,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
  String trimTeacherName(String name) {
    List<String> parts = name.split(' ');
    if (parts.length > 2) {
      return '${parts[0]} ${parts[1]}'; // Return the first two parts
    }
    return name; // If there's no second space, return the original name
  }
}