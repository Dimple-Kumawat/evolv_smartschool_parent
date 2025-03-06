import 'dart:convert';
import 'package:evolvu/Teacher/teacher_DeatilCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:evolvu/Teacher/teacher_DeatilCard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Attachment.dart';

class TeacherNote {
  final String notesId;
  final String date;
  final String description;
  final String name;
  final String subjectName;
  final String className;
  final String sectionname;
  final String publish;
  final String read_status;
  final List<Attachment> imageList;

  TeacherNote({
    required this.notesId,
    required this.date,
    required this.description,
    required this.name,
    required this.subjectName,
    required this.sectionname,
    required this.className,
    required this.publish,
    required this.read_status,
    required this.imageList,

  });

  factory TeacherNote.fromJson(Map<String, dynamic> json) {
    return TeacherNote(
      notesId: json['notes_id'],
      date: json['date'],
      description: json['description'],
      name: json['name'],
      subjectName: json['subject_name'] ?? 'N/A',
      className: json['classname'],
      sectionname: json['sectionname'],
      publish: json['publish'],
      read_status: json['read_status'],
      imageList: (json['image_list'] as List)
          .map((item) => Attachment.fromJson(item))
          .toList(),
    );
  }
}
// class Attachment {
//   final String imageName;
//   final double fileSize;
//
//   Attachment({required this.imageName, required this.fileSize});
//
//   factory Attachment.fromJson(Map<String, dynamic> json) {
//     return Attachment(
//       imageName: json['image_name'],
//       fileSize: json['file_size'],
//     );
//   }
// }
// note_card.dart

class NoteCard extends StatelessWidget {
  final String name;
  final String date;
  final String note;
  final String subject;
  final String classname;
  final String sectionname;
  final String readStatus;
  final VoidCallback onTap;
  final List<Attachment> showDownloadIcon;

  const NoteCard({
    Key? key,
    required this.name,
    required this.date,
    required this.note,
    required this.subject,
    required this.classname,
    required this.sectionname,
    required this.readStatus,
    required this.onTap,
    required this.showDownloadIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime parsedDate = DateTime.parse(date);
    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

    Color cardColor = readStatus == '0' ? Colors.grey : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/teacher.png', // Replace with your logo image
                    height: 55,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Date: $formattedDate',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showDownloadIcon.isNotEmpty) // Show the icon only if attachments exist
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Icon(
                        Icons.download_for_offline,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // const Divider(thickness: 2),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Subject: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    TextSpan(
                      text: subject,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Note: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    TextSpan(
                      text: note,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis, // Truncate text with ellipsis if too long
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}