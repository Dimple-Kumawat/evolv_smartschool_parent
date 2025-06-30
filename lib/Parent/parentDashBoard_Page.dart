import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:evolvu/Parent/parentProfile_Page.dart';
import 'package:evolvu/Student/student_card.dart';
import 'package:evolvu/WebViewScreens/FeesReceiptWebViewScreen.dart';
import 'package:evolvu/calender_Page.dart';
import 'package:evolvu/username_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AcademicYearProvider.dart';
import '../ChangeAcademicYear.dart';
import '../QR/QR_Code.dart';
import '../WebViewScreens/DashboardOnlineFeesPayment.dart';
import '../aboutUs.dart';
import '../changePasswordPage.dart';
import '../main.dart';
import 'DrawerParentProfile.dart';
import '../ID_Card/Parent_IDCard.dart';

class ParentDashBoardPage extends StatefulWidget {
  final String academic_yr;
  final String shortName;
  const ParentDashBoardPage(
      {super.key, required this.academic_yr, required this.shortName});

  @override
  _ParentDashBoardPageState createState() => _ParentDashBoardPageState();
}

String shortName = "";
String academic_yr = "";
String reg_id = "";
String user_id = "";
String url = "";
String durl = "";

String paymentUrl = "";
String paymentUrlShare = "";
int receipt_button = 0;
String receiptUrl = "";

String smartchat_url = "";
String username = "";

Future<void> _getSchoolInfo(BuildContext context) async {
  final academicYearProvider =
      Provider.of<AcademicYearProvider>(context, listen: false);

  final prefs = await SharedPreferences.getInstance();
  String? schoolInfoJson = prefs.getString('school_info');
  String? logUrls = prefs.getString('logUrls');
  log('logUrls1111 $schoolInfoJson');
  if (logUrls != null) {
    try {
      Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
      log('logUrls====\\\\11111: $logUrls');

      user_id = logUrlsparsed['user_id'];
      academicYearProvider.setAcademicYear(logUrlsparsed['academic_yr']);
      academic_yr = academicYearProvider.academic_yr;
      reg_id = logUrlsparsed['reg_id'];

      if (academic_yr.isEmpty) {
        academic_yr = logUrlsparsed['academic_yr'];
      }
      log('academic_yr ID: $academic_yr');
      log('reg_id $reg_id');
    } catch (e) {
      log('Error parsing school info: $e');
    }
  } else {
    log('School info not found in SharedPreferences.');
  }

  if (schoolInfoJson != null) {
    try {
      Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

      shortName = parsedData['short_name'];
      url = parsedData['url'];
      durl = parsedData['project_url'];

      fetchDashboardData(url);

      log('Short Name: $shortName');
      log('URL: $url');
      log('URL: $durl');
    } catch (e) {
      log('Error parsing school info: $e');
    }
  } else {
    log('School info not found in SharedPreferences.');
  }
}

Future<void> fetchDashboardData(String url) async {
  final url1 = Uri.parse('${url}show_icons_parentdashboard_apk');

  try {
    final response = await http.post(
      url1,
      body: {'short_name': shortName},
    );

    if (response.statusCode == 200) {
      log('response.body URL: 111111');
      log('response.body URL: ${response.body}');
      log('response.body URL: 222222');

      final Map<String, dynamic> data = jsonDecode(response.body);

      receipt_button = data['receipt_button'] ?? 0;
      receiptUrl = data['receipt_url'] ?? '';
      paymentUrl = data['payment_url'] ?? '';
      smartchat_url = data['smartchat_url'] ?? '';

      String allowedUriChars = "@#&=*+-_.,:!?()/~'%";

      PostMsg1();

      String uriUsername = customUriEncode(username, allowedUriChars);
      username = username;

      String secretKey = 'aceventura@services';

      String encryptedUsername = encryptUsername(username, secretKey);

      paymentUrlShare =
          "$paymentUrl?reg_id=$reg_id&academic_yr=$academic_yr&user_id=$uriUsername&encryptedUsername=$encryptedUsername&short_name=$shortName";

      log('message1_url : ${data['message1_url']}');
      log('message2_url : ${data['message2_url']}');

      log('Encrypted Username: $paymentUrlShare');
      log('Encrypted Username: $encryptedUsername');

      log('Receipt URL: $receiptUrl');
      log('Payment URL: $paymentUrl');
      log('smartchat_url : $smartchat_url');
    } else {
      log('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    log('Error: $e');
  }
}

String encryptUsername(String username, String secretKey) {
  String combined = username + secretKey;
  List<int> bytes = utf8.encode(combined);
  Digest sha1Result = sha1.convert(bytes);
  return sha1Result.toString();
}

String customUriEncode(String input, String allowedChars) {
  final StringBuffer encoded = StringBuffer();

  for (int i = 0; i < input.length; i++) {
    final String char = input[i];
    if (allowedChars.contains(char)) {
      encoded.write(char);
    } else {
      final List<int> bytes = utf8.encode(char);
      for (final int byte in bytes) {
        encoded.write('%${byte.toRadixString(16).toUpperCase()}');
      }
    }
  }

  return encoded.toString();
}

Future<void> PostMsg1() async {}

class _ParentDashBoardPageState extends State<ParentDashBoardPage> {
  int pageIndex = 0;
  late BuildContext _context;
  DateTime? _lastPressedTime;

  @override
  void initState() {
    super.initState();
    _getSchoolInfo(context);
    getVersion(context);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    final pages = [
      StudentCard(
        acd: widget.academic_yr,
        onTap: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
      ),
      CalendarPage(regId: reg_id),
      ParentProfilePage(),
    ];

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final bool isDoublePress = _lastPressedTime != null &&
            now.difference(_lastPressedTime!) < const Duration(seconds: 2);

        if (isDoublePress) {
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          _lastPressedTime = now;
          return false;
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
                  return const CustomPopup();
                },
              );
            },
          ),
        ),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.blue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            pages[pageIndex],
          ],
        ),
        bottomNavigationBar: buildMyNavBar(),
      ),
    );
  }

  Future<void> getVersion(BuildContext context) async {
    String BaseURl = "";
    final apiService = ApiService();
    try {
      BaseURl = await apiService.fetchUrl();
      log('BaseURl Cleaned URL: $BaseURl');
    } catch (error) {
      log('BaseURl Error: $error');
    }
    log('lastest_version1122 => ${'${BaseURl}flutter_latest_version'}');

    final url = Uri.parse('${BaseURl}flutter_latest_version');

    try {
      final response = await http.post(url);
      log('latest_version => ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        log('latest_version => ${response.body}');

        if (jsonData is List && jsonData.isNotEmpty) {
          final packageInfo = await PackageInfo.fromPlatform();
          log('Current_version => ${packageInfo.version}');

          final androidVersion = jsonData[0]['latest_version'] as String;
          final releaseNotes = jsonData[0]['release_notes'] as String;
          final forcedUpdate = jsonData[0]['forced_update'] as String;

          log('Current_version => 22222 ${packageInfo.version}');

          final localAndroidVersion = packageInfo.version;

          if (_isVersionGreater(androidVersion, localAndroidVersion)) {
            log('Current_version => 3333 ${packageInfo.version}');

            if (forcedUpdate == 'N') {
              log('Current_version => NNNNN ${packageInfo.version}');

              showDialog(
                context: context,
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
                        child: const Text(
                          'Update',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              );
            } else if (forcedUpdate == 'Y') {
              log('Current_version => 44444 ${packageInfo.version}');

              showDialog(
                context: context,
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
                        child: const Text(
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
        } else {
          log("Unexpected JSON format");
        }
      } else {
        log('Error Response: ${response.statusCode}');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  bool _isVersionGreater(String newVersion, String currentVersion) {
    List<int> newParts =
        newVersion.split('.').map((e) => int.parse(e)).toList();
    List<int> currentParts =
        currentVersion.split('.').map((e) => int.parse(e)).toList();

    for (int i = 0; i < newParts.length; i++) {
      if (i >= currentParts.length) {
        return true;
      }
      if (newParts[i] > currentParts[i]) {
        return true;
      } else if (newParts[i] < currentParts[i]) {
        return false;
      }
    }

    return false;
  }

  Widget buildMyNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, -3))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.dashboard, label: 'Dashboard', index: 0),
          _buildNavItem(icon: Icons.calendar_month, label: 'Events', index: 1),
          _buildCenterNavItem(icon: Icons.currency_rupee_sharp, index: 5),
          _buildNavItem(icon: Icons.person, label: 'Profile', index: 2),
          _buildNavItem(icon: Icons.qr_code, label: 'QR', index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    bool isSelected = pageIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QRCodeScreen(regId: reg_id)),
          );
        } else {
          setState(() => pageIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? Colors.blue.shade400 : Colors.grey, size: 26),
          const SizedBox(height: 4),
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
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboardonlinefeespayment(
                  regId: reg_id,
                  paymentUrlShare: paymentUrlShare,
                  receiptUrl: receiptUrl,
                  shortName: shortName,
                  academicYr: academic_yr,
                  receipt_button: receipt_button,
                ),
              ));
        } else {
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
              offset: const Offset(0, 4),
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
    required this.imagePath,
    required this.title,
    required this.onTap,
  });
}

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
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
              children: [
                Text('Do you want to logout?',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              logout(context);
            },
          ),
        ],
      );
    },
  );
}

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  Fluttertoast.showToast(
    msg: 'Logged out successfully!',
    backgroundColor: Colors.black45,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
  );

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => UserNamePage()),
    (Route<dynamic> route) => false,
  );
}

class CustomPopup extends StatelessWidget {
  const CustomPopup({super.key});

  @override
  Widget build(BuildContext context) {
    List<CardItem> cardItems = [
      CardItem(
        imagePath: 'assets/parents.png',
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
        title: 'Fees Receipt',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiptWebViewScreen(
                receiptUrl:
                    '$receiptUrl?reg_id=$reg_id&academic_yr=$academic_yr&short_name=$shortName',
              ),
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
            MaterialPageRoute(
                builder: (_) => ChangePasswordPage(
                      academicYear: academic_yr,
                      shortName: shortName,
                      userID: user_id,
                      url: url,
                    )),
          );
        },
      ),
      CardItem(
        imagePath: 'assets/idcard.png',
        title: 'ID Card',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StudentFormScreen()),
          );
        },
      ),
      CardItem(
        imagePath: 'assets/almanac.png',
        title: 'Change Academic Year',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChangeAcademicYearScreen(
                    academic_yr: academic_yr, shortName: shortName)),
          );
        },
      ),
      CardItem(
        imagePath: 'assets/share.png',
        title: 'Share App',
        onTap: () {
          Share.share(
            'Download Evolvu: Smart Schooling App https://play.google.com/store/apps/details?id=in.aceventura.evolvuschool',
            subject: 'Parent App!',
          );
        },
      ),
      CardItem(
        imagePath: 'assets/ace.png',
        title: 'About Us',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AboutUsPage(
                    academic_yr: academic_yr, shortName: shortName)),
          );
        },
      ),
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.only(top: 65, bottom: 0, left: 0, right: 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 241, 241),
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
                        const SizedBox(height: 8),
                        Text(
                          cardItem.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            top: -50,
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
