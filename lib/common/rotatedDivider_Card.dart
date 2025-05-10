import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RotatedDivider extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const RotatedDivider({
    super.key,
    this.width = 2,
    this.height = 70,
    this.color = const Color.fromARGB(255, 175, 167, 167),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -math.pi / 180.0, // Rotates the divider by 1 degree
      child: Container(
        width: width.w,
        height: height.h,
        color: color,
      ),
    );
  }
}
