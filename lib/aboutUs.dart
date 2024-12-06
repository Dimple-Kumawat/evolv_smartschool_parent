import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  final String academic_yr;
  final String shortName;
   AboutUsPage({required this.academic_yr, required this.shortName});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "$shortName EvolvU Smart Parent App($academic_yr)",
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
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
              children: [
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20,0,0,0),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 90,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'EvolvU Smart School App for Parents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'EvolvU is the most effective way to assist in the progress of your child and connect with school real-time. Get all your school updates on EvolvU. We keep making it better for You with additional features in new releases.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'EvolvU is backed by a marvelous team of expert designers, developers, architects and quality.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We thank you, Parents and school management for your inputs and support.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _launchUrl('mailto:contact@aceventura.in'),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Send your new feature request on ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            
                              TextSpan(
                                text: 'contact@aceventura.in',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () =>
                            _launchUrl('mailto:aceventuraservices@gmail.com'),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Email: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'aceventuraservices@gmail.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Rate Us:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 35,
                            child: IconButton(
                              icon: Image.asset('assets/playstore.png'),
                              onPressed: () => _launchUrl(
                                  'https://play.google.com/store/apps/details?id=in.aceventura.evolvuschool'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Follow Us:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              icon: Image.asset('assets/linkdin.png'),
                              onPressed: () => _launchUrl(
                                  'https://www.linkedin.com/company/aceventura-services/'),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: IconButton(
                              icon: Image.asset('assets/facebook.png'),
                              onPressed: () => _launchUrl(
                                  'https://www.facebook.com/AceVenturaSol/'),
                            ),
                          ),
                          SizedBox(
                            width: 45,
                            child: IconButton(
                              icon: Image.asset('assets/google.png'),
                              onPressed: () =>
                                  _launchUrl('https://aceventura.in/'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  
  
  }
}
