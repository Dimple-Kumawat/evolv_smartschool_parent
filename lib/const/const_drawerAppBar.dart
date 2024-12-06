import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrwerAppBar extends StatelessWidget {
  const DrwerAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    AppBar(
        title: Text(
          "SASC EvolvU Smart Parent App(2024-2025)",
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(Icons.menu, color: Colors.red),
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      );
  }
}