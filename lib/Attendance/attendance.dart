import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "Attendance Calendar",
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
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
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 110.h),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TableCalendar(
                    focusedDay: DateTime.now(),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Icon(Icons.arrow_back_ios, size: 15.sp),
                      rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 15.sp),
                      titleTextStyle: TextStyle(fontSize: 16.sp),
                    ),
                    calendarFormat: CalendarFormat.month,
                    availableGestures: AvailableGestures.all,
                  ),
                ),
                SizedBox(height: 30.h),
                Text(
                  'Absent Dates:',
                  style: TextStyle(fontSize: 18.sp, color: Colors.white),
                ),
                // Add your list of absent dates here
              ],
            ),
          ),
        ),
      ),



    );
  }
}