import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:evolvu/calender_Page.dart';
import 'package:evolvu/common/drawerAppBar.dart';
import 'package:evolvu/Parent/parentProfile_Page.dart';
import 'package:evolvu/Student/student_card.dart';
import 'package:evolvu/username_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../QR/QR_Code.dart';
import '../Utils&Config/api.dart';
import '../WebViewScreens/DashboardOnlineFeesPayment.dart';
import '../WebViewScreens/DrawerOnlineFeesPayment.dart';
import '../WebViewScreens/FeesReceiptWebViewScreen.dart';
import '../WebViewScreens/OnlineFeesPayment.dart';
import '../aboutUs.dart';
import '../changePasswordPage.dart';
import '../main.dart';
import 'DrawerParentProfile.dart';

class ParentDashBoardPage extends StatefulWidget {
  final String academic_yr;
  final String shortName;
   ParentDashBoardPage({required this.academic_yr,required this.shortName});

  @override
  // ignore: library_private_types_in_public_api
  _ParentDashBoardPageState createState() => _ParentDashBoardPageState();
}

String shortName = "";
String academic_yr = "";
String reg_id = "";
String user_id = "";
String url = "";
String durl = "";

String paymentUrl="";
String paymentUrlShare="";
int receipt_button=0;
String receiptUrl = "";

String smartchat_url="";
String username = "";


Future<void> _getSchoolInfo() async {
  final prefs = await SharedPreferences.getInstance();
  String? schoolInfoJson = prefs.getString('school_info');
  String? logUrls = prefs.getString('logUrls');
  print('logUrls====\\\\\: $schoolInfoJson');
  if (logUrls != null) {
    try {
      Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
      print('logUrls====\\\\\11111: $logUrls');

      user_id = logUrlsparsed['user_id'];
      academic_yr = logUrlsparsed['academic_yr'];
      reg_id = logUrlsparsed['reg_id'];

      print('academic_yr ID: $academic_yr');
      print('reg_id: $reg_id');
    } catch (e) {
      print('Error parsing school info: $e');
    }
  } else {
    print('School info not found in SharedPreferences.');
  }

  if (schoolInfoJson != null) {
    try {
      Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

      shortName = parsedData['short_name'];
      url = parsedData['url'];
      durl = parsedData['project_url'];

      fetchDashboardData(url);

      print('Short Name: $shortName');
      print('URL: $url');
      print('URL: $durl');
    } catch (e) {
      print('Error parsing school info: $e');
    }
  } else {
    print('School info not found in SharedPreferences.');
  }
}

Future<void> fetchDashboardData(String url) async {
  final url1 = Uri.parse(url + 'show_icons_parentdashboard_apk');

  try {
    final response = await http.post(
      url1,
      body: {'short_name': shortName},
    );

    if (response.statusCode == 200) {
      print('response.body URL: 111111');
      print('response.body URL: ${response.body}');
      print('response.body URL: 222222');

      final Map<String, dynamic> data = jsonDecode(response.body);

      // Extract the required fields with null safety
      receipt_button = data['receipt_button'] ?? 0;
      receiptUrl = data['receipt_url'] ?? '';
      paymentUrl = data['payment_url'] ?? '';
      smartchat_url = data['smartchat_url'] ?? '';

      String ALLOWED_URI_CHARS = "@#&=*+-_.,:!?()/~'%";

      PostMsg1();

      String URi_username = customUriEncode(username, ALLOWED_URI_CHARS);
      username = username;

      String secretKey = 'aceventura@services';

      String encryptedUsername = encryptUsername(username, secretKey);

      paymentUrlShare = paymentUrl +
          "?reg_id=" +
          reg_id +
          "&academic_yr=" +
          academic_yr +
          "&user_id=" +
          URi_username +
          "&encryptedUsername=" +
          encryptedUsername +
          "&short_name=" +
          shortName;

      print('message1_url : ${data['message1_url']}');
      print('message2_url : ${data['message2_url']}');

      print('Encrypted Username: $paymentUrlShare');
      print('Encrypted Username: $encryptedUsername');

      print('Receipt URL: $receiptUrl');
      print('Payment URL: $paymentUrl');
      print('smartchat_url : $smartchat_url');
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  String encryptUsername(String username, String secretKey) {
    // Combine the username and secretKey
    String combined = username + secretKey;

    // Convert the combined string to bytes
    List<int> bytes = utf8.encode(combined);

    // Perform SHA1 encryption
    Digest sha1Result = sha1.convert(bytes);

    // Return the encrypted value as a hexadecimal string
    return sha1Result.toString();
  }

  String customUriEncode(String input, String allowedChars) {
    final StringBuffer encoded = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      final String char = input[i];
      if (allowedChars.contains(char)) {
        encoded.write(char);  // Allow the character as-is
      } else {
        // Percent-encode the character
        final List<int> bytes = utf8.encode(char);
        for (final int byte in bytes) {
          encoded.write('%${byte.toRadixString(16).toUpperCase()}');
        }
      }
    }

    return encoded.toString();
  }

Future<void> PostMsg1() async {

}


class _ParentDashBoardPageState extends State<ParentDashBoardPage> {
  int pageIndex = 0;
  late BuildContext _context;
  DateTime? _lastPressedTime;
  @override
  void initState() {
    super.initState();
    _getSchoolInfo();
    getVersion(context);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    final pages = [
      StudentCard(
        onTap: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
      ),
      CalendarPage(regId: '',),

      // Dashboardonlinefeespayment(regId: reg_id, paymentUrlShare: paymentUrlShare, receiptUrl: receiptUrl, shortName: shortName, academicYr: academic_yr, receipt_button: receipt_button,),
      ParentProfilePage(),
    ];

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final bool isDoublePress = _lastPressedTime != null &&
            now.difference(_lastPressedTime!) < Duration(seconds: 2);

        if (isDoublePress) {
          return true; // Exit the app
        } else {
          // Show a toast or snackbar to inform the user to press back again
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          _lastPressedTime = now;
          return false; // Do not exit the app
        }
      },
      child: Scaffold(
          backgroundColor: Colors.blue,
          appBar: AppBar(
            title: Text(
              "${widget.shortName} EvolvU Smart Parent App(${widget.academic_yr})",
              style: TextStyle(fontSize: 14.sp, color: Colors.white),
            ),
            backgroundColor: Colors.pink,
            elevation: 0,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(Icons.menu, color: Colors.pink),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomPopup();
                  },
                );
              },
            ),
          ),
          body: Stack(
            children: [
              Container(
                width: double.infinity, // Ensure it takes full width
                height: double.infinity, // Ensure it takes full height
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink, Colors.blue],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Page content
              pages[pageIndex],
            ],
          ),
          bottomNavigationBar: buildMyNavBar(),
      ),
    );
  }



  Future<void> getVersion(BuildContext _context) async {

    String BaseURl = "";
    final apiService = ApiService();
    try {
      // Call the API and get the cleaned response
      BaseURl = await apiService.fetchUrl();
      print('BaseURl Cleaned URL: $BaseURl');
    } catch (error) {
      // Handle any errors
      print('BaseURl Error: $error');
    }
    print('lastest_version1122 => ${BaseURl + 'flutter_latest_version'}');


    print('latest_version11 => ${BaseURl + 'flutter_latest_version'}');

    final url = Uri.parse(BaseURl + 'flutter_latest_version'); // Assuming BaseURl is your base URL

    try {
      final response = await http.post(url);
      print('latest_version => ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('latest_version => ${response.body}');

        // Check if jsonData is a list and extract the first item if it is
        if (jsonData is List && jsonData.isNotEmpty) {
          final packageInfo = await PackageInfo.fromPlatform();
          print('Current_version => ${packageInfo.version}');

          final androidVersion = jsonData[0]['latest_version'] as String; // Ensure this is a String
          final releaseNotes = jsonData[0]['release_notes'] as String;
          final forcedUpdate = jsonData[0]['forced_update'] as String;

          if (androidVersion != null) {
            print('Current_version => 22222 ${packageInfo.version}');

            final localAndroidVersion = packageInfo.version;

            // Compare versions
            if (_isVersionGreater(androidVersion, localAndroidVersion)) {
              print('Current_version => 3333 ${packageInfo.version}');

              if (forcedUpdate == 'N') {
                print('Current_version => NNNNN ${packageInfo.version}');

                showDialog(
                  context: _context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('V ${packageInfo.version}'),
                      content: Text(releaseNotes),
                      actions: [
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://play.google.com/store/apps/details?id=in.aceventura.evolvuschool'));
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(
                                color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              } else if (forcedUpdate == 'Y') {
                print('Current_version => 44444 ${packageInfo.version}');

                showDialog(
                  context: _context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('V ${packageInfo.version}'),
                      content: Text(releaseNotes),
                      actions: [
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(
                                'https://play.google.com/store/apps/details?id=in.aceventura.evolvuschool'));
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(
                                color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          }
        } else {
          print("Unexpected JSON format");
        }
      } else {
        print('Error Response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

// Helper function to compare version strings
  bool _isVersionGreater(String newVersion, String currentVersion) {
    // Split version strings into parts
    List<int> newParts = newVersion.split('.').map((e) => int.parse(e)).toList();
    List<int> currentParts = currentVersion.split('.').map((e) => int.parse(e)).toList();

    // Compare each part of the version
    for (int i = 0; i < newParts.length; i++) {
      if (i >= currentParts.length) {
        // If current version has fewer parts, new version is greater
        return true;
      }
      if (newParts[i] > currentParts[i]) {
        return true;
      } else if (newParts[i] < currentParts[i]) {
        return false;
      }
    }

    // If all parts are equal, new version is not greater
    return false;
  }


  Widget buildMyNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.dashboard, label: 'Dashboard', index: 0),
          _buildNavItem(icon: Icons.calendar_month, label: 'Events', index: 1),
          _buildCenterNavItem(icon: Icons.currency_rupee_sharp, index: 5), // Center icon
          _buildNavItem(icon: Icons.person, label: 'Profile', index: 2),
          _buildNavItem(icon: Icons.qr_code, label: 'QR', index: 4),
        ],
      ),
    );
  }


  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    bool isSelected = pageIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 4) {
          // Navigate to the QR Code screen without modifying pageIndex
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRCodeScreen(regId: reg_id)),
          );
        } else {
          // Change pageIndex for BottomNavigationBar screens
          setState(() => pageIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.blue.shade400 : Colors.grey, size: 26),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade400 : Colors.grey,
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildCenterNavItem({required IconData icon, required int index}) {
    bool isSelected = pageIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 5) {
          // Navigate to the QR Code screen without modifying pageIndex
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
         Dashboardonlinefeespayment(regId: reg_id, paymentUrlShare: paymentUrlShare, receiptUrl: receiptUrl, shortName: shortName, academicYr: academic_yr, receipt_button: receipt_button,),)

        );
        } else {
          // Change pageIndex for BottomNavigationBar screens
          setState(() => pageIndex = index);
        }
      },
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: Colors.blue.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade400.withOpacity(0.4),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

}

class CardItem {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  CardItem({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });
}

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Logout Confirmation',
          style: TextStyle(fontSize: 22.sp),
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ListBody(
              children: <Widget>[
                Text('Do you want to logout?',
                    style: TextStyle(fontSize: 16.sp,color: Colors.grey)),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
          TextButton(
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
              logout(context); // Call the logout function
            },
          ),
        ],
      );
    },
  );
}

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clear all stored data

  // Optionally show a toast message
  Fluttertoast.showToast(
    msg: 'Logged out successfully!',
    backgroundColor: Colors.black45,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
  );

  // Navigate to the login screen
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => UserNamePage()),
        (Route<dynamic> route) => false,
  );
}


class CustomPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<CardItem> cardItems = [

      CardItem(
        imagePath:'assets/parents.png',
        title: 'My Profile',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DrawerParentProfilePage()),
          );
        },
      ),

      CardItem(
        imagePath: 'assets/logout1.png',
        title: 'LogOut',
        onTap: () {
          showLogoutConfirmationDialog(context);
        },
      ),

      CardItem(
        imagePath: 'assets/cashpayment.png',
        title: 'Fees Payment',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DrawerOnlineFeesPayment(
                  regId: reg_id,paymentUrlShare:paymentUrlShare,receiptUrl:receiptUrl,shortName: shortName,academicYr: academic_yr, receipt_button: receipt_button,),
            ),
          );
        },
      ),
      CardItem(
        imagePath: 'assets/password.png',
        title: 'Change Password',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChangePasswordPage(academicYear:academic_yr,shortName: shortName, userID: user_id, url: url,)),
          );
        },
      ),

      CardItem(
        imagePath: 'assets/ace.png',
        title: 'About Us',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AboutUsPage(academic_yr:academic_yr,shortName: shortName)),
          );
        },
      ),


      // Add the new Share App card here
      CardItem(
        imagePath: 'assets/share.png', // Add an appropriate icon for sharing
        title: 'Share App',
        onTap: () {
          Share.share(
            'Download Evolvu: Smart Schooling App https://play.google.com/store/apps/details?id=in.aceventura.evolvuschool', // Replace with your app link
            subject: 'Parent App!',
          );
        },
      ),
      // Add more CardItems here...
      
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(top: 65, bottom: 0, left: 0, right: 0),
      child: Stack(
        clipBehavior: Clip.none,
        // This allows the Positioned widget to go outside the Stack's bounds
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 245, 241, 241),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: cardItems.map((cardItem) {
                  return InkWell(
                    onTap: cardItem.onTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(cardItem.imagePath, width: 40, height: 40),
                        SizedBox(height: 8),
                        Text(
                          cardItem.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            top: -50, // Adjust this value to place the button above the dialog
            right: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.close, color: Colors.black, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}