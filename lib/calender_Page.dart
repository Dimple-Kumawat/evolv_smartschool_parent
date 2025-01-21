import 'dart:io';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late BuildContext _context; // Declare _context here

  @override
  Widget build(BuildContext context) {
    _context = context; // Set _context within build

    return WillPopScope(
      onWillPop: () async {
        _showExitConfirmation(_context);
        return false;
      },
      child: Container(
        color: Colors.white,
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: DateTime.now(),
          headerStyle: HeaderStyle(
            formatButtonVisible: false, // Hides the "2 weeks" button
            titleCentered: true, // Optional: Center the month and year title
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                exit(0); // Exit the app with exit code 0 (successful)
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}