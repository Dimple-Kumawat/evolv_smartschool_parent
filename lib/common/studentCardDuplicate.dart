import 'dart:ui';

import 'package:evolvu/common/common_style.dart';
import 'package:evolvu/common/rotatedDivider_Card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class StudentCard1 extends StatelessWidget {
  final String name;
  final String rollno;
  final String clas;
  final String div;
  final String techer;
  final String techName;
  final String img;
  final String? attendance;
  final VoidCallback? onTap;

 const StudentCard1({
    super.key,
    required this.name,
    required this.rollno,
    required this.clas,
    required this.div,
    required this.techer,
    required this.techName,
    required this.img,
   // this.showAttendanceTet = "0", 
    this.onTap, 
    this.attendance,
    required bool showAttendanceLabel,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 110.h,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 3, 0),
          child: Card(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 55.w,
                      child: Image.asset(img),
                    ),
                    attendance != null?
                       Padding(
                        padding: EdgeInsets.fromLTRB(3, 3, 0, 0),
                        child: Text("Attendance ${attendance?? ""}" , style: TextStyle(fontSize: 10.sp),),
                      ): SizedBox.shrink()
                  ],
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: Commonstyle.boldText,
                      ),
                      Text(
                        rollno,
                        style: Commonstyle.redText,
                      ),
                    ],
                  ),
                ),
                const RotatedDivider(),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        clas,
                        style: Commonstyle.boldText,
                      ),
                      Text(
                        div,
                        style: Commonstyle.redText,
                      ),
                    ],
                  ),
                ),
                const RotatedDivider(),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        techer,
                        style: Commonstyle.boldText,
                      ),
                      Text(
                        techName,
                        style: Commonstyle.redText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
