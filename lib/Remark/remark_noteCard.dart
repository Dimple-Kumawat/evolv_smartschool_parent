import 'package:flutter/material.dart';
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
      imageList: (json['image_list'] as List?)
          ?.map((item) => Attachment.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class RemarkNoteCard extends StatelessWidget {
  final String date;
  final String teacher;
  final String remarksubject;
  final String readStatus;
  final String acknowledge;
  final VoidCallback onTap;
  final List<Attachment> showDownloadIcon;

  const RemarkNoteCard({
    super.key,
    required this.acknowledge,
    required this.date,
    required this.teacher,
    required this.remarksubject,
    required this.readStatus,
    required this.onTap,
    required this.showDownloadIcon,
  });

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
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/studying.png',
                        height: 50,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRichText('Date: ', formattedDate),
                              const SizedBox(height: 5),
                              _buildRichText('Teacher: ', trimTeacherName(teacher)),
                              const SizedBox(height: 5),
                              _buildRichText('Remark Subject: ', remarksubject, maxLines: 1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 12,
            child: Icon(
              acknowledge == 'N' ? Icons.thumb_up : Icons.remove_red_eye,
              color: acknowledge == 'N' ? Colors.white : Colors.red,
            ),
          ),
          if (showDownloadIcon.isNotEmpty)
            const Positioned(
              top: 85,
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

  Widget _buildRichText(String label, String value, {int maxLines = 1}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
    );
  }

  String trimTeacherName(String name) {
    List<String> parts = name.split(' ');
    return parts.length > 1 ? '${parts[0]} ${parts[1]}' : name;
  }
}