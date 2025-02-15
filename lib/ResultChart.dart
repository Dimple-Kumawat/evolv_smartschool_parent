import 'dart:convert';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class ResultChart extends StatefulWidget {
  final String studentId;
  final String academicYr;
  final String shortName;
  final String classId;
  final String secId;
  final String className;

  ResultChart({
    required this.className,
    required this.studentId,
    required this.academicYr,
    required this.shortName,
    required this.classId,
    required this.secId,
  });

  @override
  _ResultChartState createState() => _ResultChartState();
}

class _ResultChartState extends State<ResultChart> {
  int touchedIndex = -1;
  List<PieChartSectionData> chartSections = [];
  String centerText = "Loading...";
  String centerText_lc = "Loading...";

  List<BarChartGroupData> barGroups = [];
  List<Map<String, dynamic>> barData = [];
  List<Map<String, dynamic>> lineChartData = [];

  @override
  void initState() {
    super.initState();
    fetchChartData();
    fetchBarData();
    fetchLineChart();
  }

  Future<void> fetchLineChart() async {
    final url3 = url + 'student_marks_details_for_line_chart';
    final body = {
      'short_name': widget.shortName,
      'class_id': widget.classId,
      // 'class_id': '24',
      'student_id': widget.studentId,
      // 'student_id': '2396',
      'academic_yr': widget.academicYr,
      // 'academic_yr': '2023-2024',
    };

    try {
      final response = await http.post(Uri.parse(url3), body: body);

      if (response.statusCode == 200) {
        print('fetchLineChart: ${response.statusCode}');
        print('fetchLineChart: ${response.body}');

        final data = json.decode(response.body) as List<dynamic>;

        // Parse the API response and store it
        lineChartData = data.map((item) {
          final details = (item['Details'] as List<dynamic>)
              .map((detail) => json.decode(detail) as Map<String, dynamic>)
              .toList();
          return {'Exam_name': item['Exam_name'], 'Details': details};
        }).toList();

        setState(() {
          // Once data is fetched, trigger rebuild
        });
      } else {
        setState(() {
          centerText_lc = "Result not found";
        });
      }
    } catch (e) {
      setState(() {
        centerText_lc = "Line chart data is empty"; // Error handling
      });
    }
  }

  Future<void> fetchBarData() async {
    final url2 = url + 'student_marks_for_bar_chart';
    final body = {
      'student_id': widget.studentId,
      'short_name': widget.shortName,
    };

    try {
      final response = await http.post(Uri.parse(url2), body: body);
      print('Bar Chart data: ${widget.studentId}');
      print('Bar Chart data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isEmpty) {
          setState(() {
            centerText = "Result not found";
            barGroups = [];
          });
          return;
        }

        final details = data[0]['Details'];

        if (details.isEmpty) {
          setState(() {
            centerText = "Result not found";
            barGroups = [];
          });
          return;
        }

        // Parse the 'Details' list to extract academic years and percentages
        barData = details.map<Map<String, dynamic>>((detail) {
          return json.decode(detail) as Map<String, dynamic>;
        }).toList();

        setState(() {
          barGroups = _getBarGroups(); // Generate the dynamic bar chart data
        });
      } else {
        setState(() {
          centerText = "Result not found";
        });
      }
    } catch (e) {
      setState(() {
        centerText = "Result not found"; // Error handling
      });
      print('Error: $e');
    }
  }

  Future<void> fetchChartData() async {
    final url1 = url + 'student_marks_details_for_pie_chart';
    final body = {
      'class_id': widget.classId,
      'student_id': widget.studentId,
      'short_name': widget.shortName,
      'academic_yr': widget.academicYr,
    };

    try {
      final response = await http.post(Uri.parse(url1), body: body);
      print('Pie load data ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isEmpty) {
          setState(() {
            centerText = "Result not found"; // No data found
            chartSections = [];
          });
          return;
        }

        final pieCenterText = data[0]['pie_center_text'] ?? "Result not found";
        final details = data[0]['Details'];

        if (details.isEmpty) {
          setState(() {
            centerText = "Result not found"; // Empty details
            chartSections = [];
          });
          return;
        }

        List<Map<String, dynamic>> subjectMarks =
            details.map<Map<String, dynamic>>((detail) {
          return json.decode(detail) as Map<String, dynamic>;
        }).toList();

        setState(() {
          centerText = pieCenterText;
          chartSections = getPieChart(subjectMarks);
        });
      } else {
        setState(() {
          centerText = "Result not found"; // API error response
        });
        print('Failed to load data');
      }
    } catch (e) {
      setState(() {
        centerText = "Result not found"; // Error message for exception
      });
      print('Error: $e');
    }
  }

  List<PieChartSectionData> getPieChart(
      List<Map<String, dynamic>> subjectMarks) {
    List<Color> sectionColors = [
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.lightBlueAccent,
      Colors.grey,
    ];

    return List.generate(subjectMarks.length, (index) {
      final subject = subjectMarks[index]['Subject_Name'];
      final marks = double.parse(subjectMarks[index]['Subject_Marks']);
      final color = sectionColors[index % sectionColors.length];

      return PieChartSectionData(
        color: color,
        value: marks,
        title: '$subject\n${marks.toStringAsFixed(1)}%',
        radius: touchedIndex == index ? 100 : 60,
        titleStyle: TextStyle(
            fontSize: 8.sp,
            color: const Color.fromARGB(255, 20, 10, 10),
            fontWeight: FontWeight.bold),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 50.h,
        title: Text(
          "Result Chart",
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
                SizedBox(height: 80.h),
                // SizedBox(height: 10.h),
                _buildResultChart(),
                SizedBox(height: 30.h),
                _buildThirdStackedBarChart(),// Bar chart widget below pie chart
                SizedBox(height: 30.h),
                _buildBarChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThirdStackedBarChart() {
    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: lineChartData.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            centerText_lc,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : Column(
        children: [
          _buildTermTitles(),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: _buildSubjectRows(),
            ),
          ),
        ],
      ),
    );
  }

//need to chnage here dimple

// Dynamically create exam names as column titles with horizontal scrolling
  Widget _buildTermTitles() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          const SizedBox(width: 95), // For the subject name column
          // Wrap exam titles in a horizontal scroll view
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: lineChartData.map((subjectData) {
                  return Container(
                    width: 55, // Fixed width for each exam title
                    alignment: Alignment.center,
                    child: Text(
                      subjectData['Exam_name'],
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }


// Build each row for each subject with scores across exams
  List<Widget> _buildSubjectRows() {
    // Collect unique subjects
    final subjects = lineChartData
        .expand((exam) => exam['Details'])
        .map((detail) => detail['Subject'])
        .toSet()
        .toList();

    return subjects.map((subject) {
      // Collect scores for the subject across all exams as List<String>
      List<String> scores = lineChartData.map((examData) {
        final details = examData['Details'].firstWhere(
              (detail) => detail['Subject'] == subject,
          orElse: () => <String, dynamic>{'Percentage': 'N/A'}, // Use 'N/A' if no score
        );
        return details['Percentage']?.toString() ?? 'N/A'; // Convert to string
      }).toList();

      return _buildSubjectBar(subject, scores);
    }).toList();
  }

// Build a single subject row with scores displayed as bar segments
  Widget _buildSubjectBar(String subjectName, List<String> scores) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              subjectName,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          // Display each exam's score as a segment
          ...List.generate(scores.length, (index) {
            int? previousValidScore = _getPreviousValidScore(scores, index);
            int? currentScore = int.tryParse(scores[index]);

            return currentScore != null
                ? _buildBarSegment(currentScore, previousValidScore)
                : _buildNABarSegment(); // Fallback for "N/A" scores
          }),
        ],
      ),
    );
  }

// Helper function to find the most recent valid score before the current index
  int? _getPreviousValidScore(List<String> scores, int currentIndex) {
    for (int i = currentIndex - 1; i >= 0; i--) {
      int? score = int.tryParse(scores[i]);
      if (score != null) {
        return score;
      }
    }
    return null; // Return null if no valid score is found before the current index
  }

// Helper widget to build each colored bar segment with gradient, shadow, and 3D effect
  Widget _buildBarSegment(int currentScore, int? previousScore) {
    Gradient gradient;
    BoxShadow shadow = BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: Offset(0, 3)); // Default shadow

    if (previousScore == null) {
      // For the first valid term, always blue gradient
      gradient = LinearGradient(
        colors: [Colors.blue.shade700, Colors.blue.shade300],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      // Calculate the percentage difference
      double percentageChange = ((currentScore - previousScore) / previousScore) * 100;

      if (percentageChange > 25) {
        gradient = LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade300], // Dark to light green
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        shadow = BoxShadow(color: Colors.green.withOpacity(0.6), blurRadius: 6, offset: Offset(0, 3)); // Add shadow for improvement
      } else if (percentageChange > 0) {
        gradient = LinearGradient(
          colors: [Colors.green.shade300, Colors.green.shade100], // Lighter green
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        shadow = BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 6, offset: Offset(0, 3));
      } else if (percentageChange < -25) {
        gradient = LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade300], // Red gradient for large decline
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        shadow = BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 6, offset: Offset(0, 3));
      } else {
        gradient = LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade300], // Amber gradient for small decline
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
        shadow = BoxShadow(color: Colors.orange.withOpacity(0.6), blurRadius: 6, offset: Offset(0, 3));
      }
    }

    return Container(
      width: 45,
      height: 25,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [shadow],
      ),
      alignment: Alignment.center,
      child: Text(
        currentScore.toString(),
        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

// Create a placeholder for "N/A" scores with gray color
  Widget _buildNABarSegment() {
    return Container(
      width: 45,
      height: 25,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        "N/A",
        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget _buildResultChart() {
    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: AspectRatio(
        aspectRatio: 0.95,
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                centerSpaceRadius: 85,
                sections: chartSections, // Dynamic data
              ),
            ),
            Center(
              child: Text(
                _formatCenterText(centerText),
                // Call the helper method to format the text
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to split text after 2nd space and insert a new line
  String _formatCenterText(String text) {
    List<String> words = text.split(' '); // Split the text by spaces
    if (words.length > 2) {
      return '${words.sublist(0, 2).join(' ')}\n${words.sublist(2).join(' ')}'; // Rejoin the first two words and the rest
    }
    return text; // If there are fewer than 3 words, return the original text
  }

  Widget _buildBarChart() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              minY: 0, // Set the minimum Y value to 0
              maxY: 100, // Set the maximum Y value to 100 for percentages
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10, // Set the interval for Y-axis titles
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value % 10 == 0) {  // Show values only at every 10% interval
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }
                      return Container(); // Hide labels for other values
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      const style = TextStyle(
                        color: Color(0xff7589a2),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      );
                      if (value.toInt() < barData.length) {
                        String academicYear = barData[value.toInt()]['Academic Year'];

                        // Extract last two digits of the years
                        String shortYear = '${academicYear.substring(2, 4)}-${academicYear.substring(7, 9)}';

                        return Text(shortYear, style: style);
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(),
                touchCallback: (FlTouchEvent event, response) {
                  setState(() {});
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            )
        ),
      ),
    );
  }

  // Dynamically generate bar groups based on API data
  List<BarChartGroupData> _getBarGroups() {
    return List.generate(barData.length, (index) {
      final percentage = double.parse(barData[index]['Percentage']);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: Colors.lightBlueAccent,
            width: 22,
            borderRadius: BorderRadius.zero, // Square-shaped bar
          ),
        ],
      );
    });
  }
}