// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:evolvu/Parent/parentDashBoard_Page.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'BusTraking.dart';

// class TransportHomeScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> students;
//   final String academicYear;
//   final String schoolShortName;
//   final String apiUrl;

//   const TransportHomeScreen({
//     super.key,
//     required this.students,
//     required this.academicYear,
//     required this.schoolShortName,
//     required this.apiUrl,
//   });

//   @override
//   State<TransportHomeScreen> createState() => _TransportHomeScreenState();
// }

// class _TransportHomeScreenState extends State<TransportHomeScreen> {
//   int _currentIndex = 0;
//   double _alertRadius = 3.0; // Default radius in km
//   bool _proximityAlertEnabled = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize with dummy boarding status (replace with real data)

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(

//       appBar: AppBar(
//         backgroundColor: Colors.pink,
//         title: const Text('Transport Management'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshData,
//           ),
//         ],
//       ),
//       body: Container(
//           height: double.infinity,
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.pink, Colors.blue],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: _buildCurrentTab()),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.blue,
//         currentIndex: _currentIndex,
//         selectedItemColor: Colors.amber, // This sets the selected tab color to white
//         unselectedItemColor: Colors.white, // Optional: set unselected tabs color
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.notifications),
//             label: 'Notifications',
//           ),
//         ],
//         onTap: (index) => setState(() => _currentIndex = index),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => BusTrackingScreen(busId: 'SCHOOL-101'),
//             ),
//           );
//         },
//         icon: const Icon(Icons.directions_bus, color: Colors.black),
//         label: const Text("Live Tracking"),
//         backgroundColor: Colors.amber,
//       ),
//     );
//   }

//   Widget _buildCurrentTab() {
//     switch (_currentIndex) {
//       case 0: // Home Tab
//         return _buildTransportDashboard();
//       case 1: // Notifications Tab
//         return _buildNotificationsList();
//       default:
//         return Container();
//     }
//   }

//   Widget _buildTransportDashboard() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // _buildStatusCard('Boarding', _boardingStudents.length),
//           // const SizedBox(height: 16),
//           // _buildStatusCard('Departed', _departedStudents.length),
//           // const SizedBox(height: 24),
//           const Text('Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: widget.students.length,
//             itemBuilder: (context, index) => _buildStudentCard(widget.students[index]),
//           ),
//           const SizedBox(height: 10),
//           _buildProximityAlertSection(),
//           const SizedBox(height: 10),
//           _buildSupportCard(),
//           const SizedBox(height: 10),
//           _buildPrivacyPolicyCard(),
//         ],
//       ),
//     );

//   }

//   Widget _buildSupportCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: _showSupportBottomSheet,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               const Icon(Icons.help_outline, size: 28, color: Colors.blue),
//               const SizedBox(width: 16),
//               const Expanded(
//                 child: Text(
//                   'Support',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Icon(Icons.chevron_right, color: Colors.grey[600]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPrivacyPolicyCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: _showPrivacyPolicyBottomSheet,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               const Icon(Icons.privacy_tip_outlined, size: 28, color: Colors.blue),
//               const SizedBox(width: 16),
//               const Expanded(
//                 child: Text(
//                   'Privacy Policy',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Icon(Icons.chevron_right, color: Colors.grey[600]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showPrivacyPolicyBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ), // This closing parenthesis was missing
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(16),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Privacy Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
//                 const Text(
//                   '1. Information Collection\nWe collect necessary information to provide transportation services...',
//                   style: TextStyle(height: 1.5),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   '2. Data Usage\nYour data is used solely for transportation management purposes...',
//                   style: TextStyle(height: 1.5),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   '3. Data Protection\nWe implement security measures to protect your information...',
//                   style: TextStyle(height: 1.5),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('I Understand'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showSupportBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 16),
//               const Text('For any assistance or queries, please contact:'),
//               const SizedBox(height: 16),
//               ListTile(
//                 leading: const Icon(Icons.email,color: Colors.red,),
//                 title: const Text('Email Us'),
//                 subtitle: const Text('Altusupport@schooltransport.com'),
//                 onTap: () => launchUrl(Uri.parse('mailto:support@schooltransport.com')),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.phone,color: Colors.blueAccent,),
//                 title: const Text('Call Us'),
//                 subtitle: const Text('+91 9766220055'),
//                 onTap: () => launchUrl(Uri.parse('tel:+91 9766220055')),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Close'),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProximityAlertSection() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Icon(Icons.alarm_rounded,color: Colors.red,),
//                  Row(
//                      children: [
//                        Icon(Icons.alarm_rounded,color: Colors.red,),
//                    Text('  Proximity Alert Radius',
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         ],
//                  ),
//                 Switch(
//                   value: _proximityAlertEnabled,
//                   onChanged: (value) => setState(() => _proximityAlertEnabled = value),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 2),
//             const Text('Get notified when the bus is within:',
//                 style: TextStyle(color: Colors.grey)),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: Slider(
//                     value: _alertRadius,
//                     min: 1.0,
//                     max: 10.0,
//                     divisions: 9,
//                     label: '${_alertRadius.toStringAsFixed(1)} km',
//                     onChanged: (value) => setState(() => _alertRadius = value),
//                   ),
//                 ),
//                 Container(
//                   width: 60,
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text('${_alertRadius.toStringAsFixed(1)} km',
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (_proximityAlertEnabled)
//               const Text('Alert is active',
//                   style: TextStyle(color: Colors.green, fontSize: 12)),
//           ],
//         ),
//       ),
//     );
//   }


//   Widget _buildStatusCard(String title, int count) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(title, style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 8),
//             Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentCard(Map<String, dynamic> student) {
//     String studentId = student['student_id'].toString();
//     String imageUrl = "${durl}uploads/student_image/$studentId.jpg";

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: CircleAvatar(
//           child: ClipOval(
//             child: CachedNetworkImage(
//               imageUrl: imageUrl,
//               placeholder: (context, url) => CircularProgressIndicator(),
//               errorWidget: (context, url, error) => Icon(Icons.person),
//               fit: BoxFit.cover,
//               width: 40,
//               height: 40,
//             ),
//           ),
//         ),
//         title: Text('${student['first_name']} ${student['last_name']}'),
//         subtitle: Text('${student['class_name']} ${student['section_name']}'),
//         // onTap: () => _showStudentTransportInfo(student),
//         onTap: () =>  Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => BusTrackingScreen(busId: 'SCHOOL-101'),
//           ),
//         ),
//       ),
//     );
//   }




//   void _showStudentTransportInfo(Map<String, dynamic> student) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Driver Name: ${student['driver_name']}', style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 8),
//               Text('Vehicle No: ${student['vehicle_number']}', style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       final phone = student['driver_phone'];
//                       if (phone != null) {
//                         launchUrl(Uri.parse('tel:$phone'));
//                       }
//                     },
//                     icon: const Icon(Icons.call),
//                     label: const Text('Call Driver'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   ),
//                   const SizedBox(width: 12),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pop(context); // Close the bottom sheet
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => BusTrackingScreen(busId: student['bus_id']),
//                         ),
//                       );
//                     },
//                     icon: const Icon(Icons.directions_bus),
//                     label: const Text('Track Bus'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }


//   Widget _buildNotificationsList() {
//     // Dummy notifications - replace with real data
//     final notifications = [
//       {'id': '1', 'message': 'Bus 101 departed from school', 'time': '10:30 AM', 'read': false},
//       {'id': '2', 'message': 'Bus 102 arriving in 5 mins', 'time': '10:25 AM', 'read': true},
//       {'id': '3', 'message': 'Route change for Bus 103', 'time': 'Yesterday', 'read': true},
//     ];

//     return ListView.builder(
//       itemCount: notifications.length,
//       itemBuilder: (context, index) {
//         final notification = notifications[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           color: notification['read'] == false ? Colors.blue[50] : null,
//           child: ListTile(
//             leading: const Icon(Icons.directions_bus),
//             title: Text(notification['message'] as String),
//             subtitle: Text(notification['time'] as String),
//             onTap: () => _markAsRead(notification['id'] as String),
//           ),
//         );
//       },
//     );

//   }



//   void _markAsRead(String notificationId) {
//     // Implement notification read logic
//   }

//   void _refreshData() {
//     // Implement data refresh logic
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Refreshing data...')),
//     );
//   }
// }

// class TransStudentCardItem extends StatelessWidget {
//   final String firstName;
//   final String midName;
//   final String lastName;
//   final String rollNo;
//   final String className;
//   final String cname;
//   final String secname;
//   final String classTeacher;
//   final String gender;
//   final String studentId;
//   final String classId;
//   final String secId;
//   final String shortName;
//   final String url;
//   final String academicYr;
//   final VoidCallback? onTap;

//   const TransStudentCardItem({
//     super.key,
//     required this.firstName,
//     required this.midName,
//     required this.lastName,
//     required this.rollNo,
//     required this.className,
//     required this.cname,
//     required this.secname,
//     required this.classTeacher,
//     required this.gender,
//     required this.studentId,
//     required this.classId,
//     required this.secId,
//     required this.shortName,
//     required this.url,
//     required this.academicYr,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.blue[100],
//                 child: Text(
//                   rollNo,
//                   style: const TextStyle(color: Colors.black),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '$firstName ${midName.isNotEmpty ? '$midName ' : ''}$lastName',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text('Class: $className'),
//                     Text('Class Teacher: $classTeacher'),
//                   ],
//                 ),
//               ),
//               Icon(
//                 gender.toLowerCase() == 'male' ? Icons.male : Icons.female,
//                 color: gender.toLowerCase() == 'male' ? Colors.blue : Colors.pink,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }