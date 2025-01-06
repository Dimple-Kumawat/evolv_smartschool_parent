import 'package:evolvu/const/const_teacherNoteCard.dart';
import 'package:evolvu/Remark/remark_DetailPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Teacher/Attachment.dart';

class RemarkDetailCard extends StatelessWidget {
  final String shortName;
  final String academic_yr;
  final String remarksubject;
  final List<Attachment> imageList;
  final String description;
  final String remarkId;
  final String remarkDate;

  const RemarkDetailCard({
    Key? key,
    required this.shortName,
    required this.academic_yr,
    required this.remarksubject,
    required this.imageList,
    required this.description,
    required this.remarkId,
    required this.remarkDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 50.h,
        title: Text(
          "$shortName EvolvU Smart Parent App($academic_yr)",
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
              "Remarks Details",
              style: TextStyle(
                fontSize: 20.sp, // Adjusted for better visibility
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 6.h),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: RemarkDetailPage(
                        remarkInfo: RemarkInfo(
                          description: description,
                          attachment: imageList,
                          remarkDate: remarkDate,
                          remarkId: remarkId,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
