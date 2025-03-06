import 'dart:convert';
import 'dart:io';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final String regId;

  CalendarPage({super.key, required this.regId});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  List<Event> _selectedEvents = [];
  DateTime? _academicYearStart;
  DateTime? _academicYearEnd;
  List<Event> _monthlyEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchAcademicYearRange();
    _fetchEvents(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitConfirmation(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,

        body: Column(
          children: [
            Card(
              color: Colors.white,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedEvents = _events[_normalizeDate(selectedDay)] ?? [];
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay; // Update the focused month
                  });
                  _fetchEvents(focusedDay); // Fetch events for the new month
                },
                eventLoader: (day) {
                  return _events[_normalizeDate(day)] ?? []; // Ensure correct date mapping
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  final event = _selectedEvents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Color(int.parse(event.color.replaceAll("#", "0xFF"))),
                    child: ListTile(
                      leading: const Icon(Icons.info, color: Colors.black54),
                      title: Text(
                        '${DateFormat('dd-MM-yyyy').format(event.date)}  ${event.title}', // Use event's actual date
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
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

  /// Normalize date to ensure consistency in event mapping.
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _fetchAcademicYearRange() async {
    final url1 = Uri.parse('$url/get_academic_yr_from_to_dates');
    final response = await http.post(url1, body: {
      'short_name': shortName,
      'academic_yr': academic_yr,
    });

    if (response.statusCode == 200) {
      print('Academic Year Response: ${response.body}');
      final data = jsonDecode(response.body)[0];
      setState(() {
        _academicYearStart = DateTime.parse(data['academic_yr_from']);
        _academicYearEnd = DateTime.parse(data['academic_yr_to']);
      });
    }
  }

  Future<void> _fetchEvents(DateTime focusedDay) async {
    final url2 = Uri.parse('$url/get_all_published_events');
    final response = await http.post(url2, body: {
      'short_name': shortName,
      'academic_yr': academic_yr,
      // 'class_id': '119',
      'month': focusedDay.month.toString(),
      'year': focusedDay.year.toString(),
      'reg_id': widget.regId,
    });

    if (response.statusCode == 200) {
      print('Events Response: ${response.body}');
      final data = jsonDecode(response.body);

      setState(() {
        _events.clear();
        _monthlyEvents = [];
        _addEvents(data['Events'], '#6da8d6'); 
        _addEvents(data['Homework'], '#90ee90'); 
        _addEvents(data['Holidays'], '#e57368'); 

        // Update selected events to show all events for the current month
        _selectedEvents = _monthlyEvents;
      });
    }
  }

  void _addEvents(List<dynamic> events, String color) {
    for (final event in events) {
      final date = DateFormat('dd-MM-yyyy').parse(event['start_date']); // Parse event date
      final eventData = Event(
        title: event['title'],
        description: event['event_desc'],
        color: color,
        date: date, // Store actual date
      );

      if (_events[date] == null) {
        _events[date] = [eventData];
      } else {
        _events[date]!.add(eventData);
      }

      _monthlyEvents.add(eventData);
    }
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
                exit(0);
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}
class Event {
  final String title;
  final String description;
  final String color;
  final DateTime date;

  Event({required this.title, required this.description, required this.color, required this.date});
}