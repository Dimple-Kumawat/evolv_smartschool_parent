import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircularAttendanceIndicator extends StatelessWidget {
  final double percentage; // Attendance percentage (e.g., 0.87 for 87%)

  CircularAttendanceIndicator({
    required this.percentage,
  });

  // Method to determine color based on percentage
  Color _getColor() {
    if (percentage < 0.35) {
      return Colors.red; // Red for below 35%
    } else if (percentage < 0.69) {
      return Colors.orange; // Orange for below 65%
    } else {
      return Colors.green; // Green for 65% and above
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 55.h,
          width: 55.h,
          child: CircularProgressIndicator(
            value: percentage, // This should be between 0.0 and 1.0
            strokeWidth: 10,
            valueColor: AlwaysStoppedAnimation<Color>(_getColor()), // Color based on percentage
            backgroundColor: Colors.grey[300], // Background color of the progress bar
          ),
        ),
        Text(
          '${(percentage * 100).toStringAsFixed(0)}%', // Convert to percentage (0-100) and show without decimal
          style: TextStyle(
            color: _getColor(),
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class CircularAttendanceIndicator2 extends StatelessWidget {
  final double percentage; // Attendance percentage (e.g., 0.87 for 87%)

  CircularAttendanceIndicator2({
    required this.percentage,
  });

  // Method to determine color based on percentage
  Color _getColor() {
    if (percentage < 35) {
      return Colors.red; // Red for below 35%
    } else if (percentage < 69) {
      return Colors.orange; // Orange for below 65%
    } else {
      return Colors.green; // Green for 65% and above
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      width: 30.h,
      child: CircularProgressIndicator(
        value: percentage / 100, // Assuming attendance is in percentage
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
        strokeWidth: 5.w,
      ),
    );
  }
}
