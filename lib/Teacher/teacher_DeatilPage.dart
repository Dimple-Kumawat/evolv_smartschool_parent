import 'package:flutter/material.dart';


class Info {
  final String className;
  final String subject;
  final String date;
  final String description;

  Info({
    required this.className,
    required this.subject,
    required this.date,
    required this.description,
  });
}

class TeacherDetailPage extends StatelessWidget {
  
  final Info info;

  const TeacherDetailPage({super.key, required this.info});

  @override
  
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
           // spreadRadius: 3,
            blurRadius: 5,
            //offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class             : ${info.className}',
            style: TextStyle(
              fontSize: 16,
             
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Subject          : ${info.subject}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Date               : ${info.date}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Description   : ${info.description}',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
