// // bus_tracking_screen.dart
// import 'dart:async';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// // bus_tracking_api.dart
// // bus_tracking_api.dart
// import 'dart:math';
// import 'dart:async';

// import 'package:intl/intl.dart';

// class BusTrackingApi {
//   static final Random _random = Random();

//   static Future<Map<String, dynamic>> getBusLocation(String busId) async {
//     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

//     final stops = [
//       {"name": "School", "lat": 19.0760, "lng": 72.8777},
//       {"name": "Viman Nagar", "lat": 19.0790, "lng": 72.8800},
//       {"name": "Kharadi", "lat": 19.0720, "lng": 72.8750},
//       {"name": "Baner", "lat": 19.0740, "lng": 72.8720},
//     ];

//     return {
//       "busId": busId,
//       "latitude": stops[_random.nextInt(stops.length)]["lat"] = (_random.nextDouble() * 0.01 - 0.005),
//       "longitude": stops[_random.nextInt(stops.length)]["lng"] = (_random.nextDouble() * 0.01 - 0.005),
//       "speed": "${_random.nextInt(60)} km/h",
//       "lastUpdated": DateTime.now().toIso8601String(),
//       "route": {
//         "stops": stops,
//         "currentStopIndex": _random.nextInt(stops.length),
//       },
//       "driver": {
//         "name": "Rajesh Kumar",
//         "contact": "+91 98XXXXXX20",
//         "photo": "https://randomuser.me/api/portraits/men/${_random.nextInt(100)}.jpg"
//       },
//       "studentsOnBoard": List.generate(_random.nextInt(10), (i) => {
//         "name": ["Aarav", "Diya", "Vihaan", "Ananya", "Reyansh"][_random.nextInt(5)],
//         "grade": "${_random.nextInt(12)+1}th Grade",
//         "stop": stops[_random.nextInt(stops.length)]["name"]
//       }),
//     };
//   }
// }



// class BusTrackingScreen extends StatefulWidget {
//   final String busId;

//   const BusTrackingScreen({super.key, required this.busId});

//   @override
//   State<BusTrackingScreen> createState() => _BusTrackingScreenState();
// }

// class _BusTrackingScreenState extends State<BusTrackingScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<Color?> _colorAnimation;
//   LatLng? _busLocation;
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   Map<String, dynamic>? _busData;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _fetchBusLocation();
//   }

//   void _initAnimations() {
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     )..repeat(reverse: true);

//     _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
//         CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
//     );

//     _colorAnimation = ColorTween(
//       begin: Colors.red[300],
//       end: Colors.red[600],
//     ).animate(_controller);
//   }

//   Future<void> _fetchBusLocation() async {
//     setState(() => _isLoading = true);
//     try {
//       final data = await BusTrackingApi.getBusLocation(widget.busId);
//       if (mounted) {
//         setState(() {
//           _busData = data;
//           _busLocation = LatLng(data['latitude'], data['longitude']);
//           _updateMarkers();
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
//       }
//     }
//   }

//   void _updateMarkers() {
//     _markers.clear();
//     _polylines.clear();

//     if (_busLocation == null || _busData == null) return;

//     // Add bus marker with animation
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('bus'),
//         position: _busLocation!,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         rotation: _busData!['route']['currentStopIndex'] * 90.0,
//       ),
//     );

//     // Add route stops
//     for (var stop in _busData!['route']['stops']) {
//       _markers.add(
//         Marker(
//           markerId: MarkerId(stop['name']),
//           position: LatLng(stop['lat'], stop['lng']),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//           infoWindow: InfoWindow(title: stop['name']),
//         ),
//       );
//     }

//     // Add route path
//     _polylines.add(
//       Polyline(
//         polylineId: const PolylineId('route'),
//         points: (_busData!['route']['stops'] as List)
//             .map((stop) => LatLng(stop['lat'], stop['lng']))
//             .toList(),
//         color: Colors.blue,
//         width: 3,
//       ),
//     );
//   }

//    LatLng myloc = LatLng(19.88, 75.33);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           backgroundColor: Colors.pink,
//           title: Text('Bus ${widget.busId} Tracking'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchBusLocation,
//           ),
//         ],
//       ),
//       body:
//       // GoogleMap(initialCameraPosition: CameraPosition(target: myloc, zoom: 30)),

//       _isLoading ? _buildLoading() : _buildContent(),
//       // floatingActionButton: FloatingActionButton(
//       //   child: const Icon(Icons.refresh),
//       //   onPressed: _fetchBusLocation,
//       // ),
//     );
//   }

//   void _refreshData() {
//     // Implement data refresh logic
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Refreshing data...')),
//     );
//   }

//   Widget _buildMockMap() {
//     return Container(
//       color: Colors.grey[200],
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.map, size: 100, color: Colors.blue),
//             Text('Map View (Simulated)', style: Theme.of(context).textTheme.titleLarge),
//             Text('Lat: ${_busLocation?.latitude.toStringAsFixed(6)}'),
//             Text('Lng: ${_busLocation?.longitude.toStringAsFixed(6)}'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoading() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 20),
//           Text('Locating school bus...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildContent() {
//     _colorAnimation = ColorTween(
//       // begin: Colors.blue[400],    // Starting color
//       end: Colors.pink,      // Ending color
//     ).animate(_controller);
//     return Column(
//       children: [
//         Expanded(
//           child: GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(19.0760, 72.8777),
//               zoom: 14,
//             ),
//             markers: {
//               Marker(
//                 markerId: const MarkerId('test'),
//                 position: LatLng(19.0760, 72.8777),
//               ),
//             },
//           ),
//         ),
//         AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     _colorAnimation.value!,
//                     _colorAnimation.value!.withOpacity(1),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               margin: const EdgeInsets.only(top: 5),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Bus Header with Pulse Animation
//                   ScaleTransition(
//                     scale: _scaleAnimation,
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 10,
//                               ),
//                             ],
//                           ),
//                           child: const Icon(Icons.directions_bus,
//                               size: 30,
//                               color: Colors.blue),
//                         ),
//                         const SizedBox(width: 15),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('BUS ${widget.busId}',
//                                 style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white)),
//                             Text('LIVE TRACKING',
//                                 style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.white.withOpacity(0.8))),
//                           ],
//                         ),
//                         const Spacer(),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(_busData!['speed'],
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 15),

//                   // Next Stop Card with Slide Animation
//                   SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(0, 0.5),
//                       end: Offset.zero,
//                     ).animate(CurvedAnimation(
//                       parent: _controller,
//                       curve: Curves.easeOut,
//                     )),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.location_pin,
//                               color: Colors.white, size: 28),
//                           const SizedBox(width: 10),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text('NEXT STOP',
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12)),
//                               Text(
//                                   _busData!['route']['stops'][_busData!['route']
//                                   ['currentStopIndex']]['name'],
//                                   style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16)),
//                             ],
//                           ),
//                           const Spacer(),
//                           const Icon(Icons.arrow_forward_ios,
//                               color: Colors.white, size: 16),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   // Students Onboard with Fade Animation
//                   FadeTransition(
//                     opacity: _controller,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             const Icon(Icons.people_outline,
//                                 color: Colors.white, size: 20),
//                             const SizedBox(width: 8),
//                             Text('${_busData!['studentsOnBoard'].length} students',
//                                 style: const TextStyle(color: Colors.white)),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             const Icon(Icons.access_time,
//                                 color: Colors.white, size: 20),
//                             const SizedBox(width: 8),
//                             Text(
//                                 'Updated: ${DateFormat('hh:mm a').format(DateTime.now())}',
//                                 style: const TextStyle(color: Colors.white)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }