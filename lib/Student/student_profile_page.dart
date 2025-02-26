import 'package:evolvu/Parent/parentDashBoard_Page.dart';

import 'package:evolvu/common/common_textFiled.dart';
import 'package:evolvu/Student/stu_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentProfilePage extends StatelessWidget {
  final String studentId;
  final String academic_yr;
  final String shortName;
  final String cname;
  final String secname;
  StudentProfilePage({
  required this.studentId,required this.academic_yr,required this.shortName,required this.cname,required this.secname,
  });
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          // flexibleSpace:  Text(

          //           "Student Profile",
          //           style: TextStyle(
          //             fontSize: 18.sp,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.white,
          //           ),
          //         ),
          toolbarHeight: 80.h,
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
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 110.h,
                ),
                Text(
                  "Student Profile ",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                SizedBox(
                  height: 720.h,
                  child:  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: StudentForm(studentId,cname,shortName,secname),
                  ),
                ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.dashboard),
        //       label: 'Dashboard',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.calendar_today),
        //       label: 'Events',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.person),
        //       label: 'Profile',
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
