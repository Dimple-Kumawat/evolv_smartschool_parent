import 'package:flutter/material.dart';
import 'package:evolvu/common/common_style.dart';

import '../Teacher/Attachment.dart';

class Notice {
  final String noticeId;
  final String unqId;
  final String subject;
  final String noticeDesc;
  final String noticeDate;

  final String startDate;
  final String endDate;
  final String classId;
  final String sectionId;
  final String teacherId;
  final String noticeType;
  final String startTime;
  final String endTime;
  final String academicYr;
  final String publish;
  final String teacherName;
  final String className;
  final String noticeRLogId;
  final String readStatus;
  final List<Attachment> imageList;

  Notice({
    required this.noticeId,
    required this.unqId,
    required this.subject,
    required this.noticeDesc,
    required this.noticeDate,
    required this.startDate,
    required this.endDate,
    required this.classId,
    required this.sectionId,
    required this.teacherId,
    required this.noticeType,
    required this.startTime,
    required this.endTime,
    required this.academicYr,
    required this.publish,
    required this.teacherName,
    required this.className,
    required this.noticeRLogId,
    required this.readStatus,
    required this.imageList,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      noticeId: json['notice_id']?.toString() ?? '',
      unqId: json['unq_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      noticeDesc: json['notice_desc']?.toString() ?? '',
      noticeDate: json['notice_date']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      sectionId: json['section_id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? '',
      noticeType: json['notice_type']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      academicYr: json['academic_yr']?.toString() ?? '',
      publish: json['publish']?.toString() ?? '',
      teacherName: json['teachername']?.toString() ?? '',
      className: json['classname']?.toString() ?? '',
      noticeRLogId: json['notice_r_log_id']?.toString() ?? '',
      readStatus: json['read_status']?.toString() ?? '',
      imageList: (json['image_list'] as List)
          .map((item) => Attachment.fromJson(item))
          .toList(),
    );
  }
  String get formattedNoticeDate {
    // Assuming noticeDate is in yyyy-mm-dd format, convert it to dd-mm-yyyy
    if (noticeDate.isNotEmpty && noticeDate.length >= 10) {
      List<String> parts = noticeDate.split('-');
      if (parts.length >= 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }
    return noticeDate; // Return as is if format is unexpected
  }
}


class NoticeNoteCard extends StatelessWidget {
  final String teacher;
  final String remarksubject;
  final String type;
  final String readStatus;
  final VoidCallback onTap;

  const NoticeNoteCard({
    required this.teacher,
    required this.remarksubject,
    required this.type,
    required this.readStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    Color cardColor = readStatus == '0'
        ? Colors.grey
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/notice.png',
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: Commonstyle.noticeText,
                        ),
                        const SizedBox(height: 5),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Created By: ',
                                style: Commonstyle.lableBold,
                              ),
                              TextSpan(
                                text: teacher,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 2, // Set the maximum number of lines
                          overflow: TextOverflow.ellipsis, // Handle text overflow with ellipsis
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.only(left: 45),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Subject:',
                            style: Commonstyle.lableBold,
                          ),
                          TextSpan(
                            text: ' $remarksubject', // Add a space before the subject
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
