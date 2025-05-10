

import 'package:evolvu/Parent/parentProfile_Page.dart';

import 'package:evolvu/username_page.dart';

import 'package:flutter/material.dart';



//const String dashBoardPage = '/dashBoardPage';
//const String loginPage = "/loginPage";
const String calendarPage = '/calendarPage';
const String profilePage = '/profilePage';
const String studentActivityPage = '/studentActivityPage';
//const String childDashBoardBoardPage = '/childDashBoardBoardPage';
const String parentDashBoardPage = '/parentDashBoardPage';
const String studentProfilePage = '/studentProfilePage';
const String teacherNotePage = '/teacherNotePage';
const String teacherDetailCard = '/teacherDetailCard';
const String infoCard = '/infoCard';
const String userName = '/userName';
const String parentProfilePage = '/parentProfilePage';
const String calenderPage = '/calenderPage';
const String homework ='/homework';







class RouterConfigs {
  static Route? onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case userName:
        return MaterialPageRoute(builder: (_) => UserNamePage());
      case studentActivityPage:
        // return MaterialPageRoute(builder: (_) => StudentActivityPage());
    // case childDashBoardBoardPage:
    // return MaterialPageRoute(builder: (_) => ChildDashBoardBoardPage());
    //   case parentDashBoardPage:
    //     return MaterialPageRoute(builder: (_) => ParentDashBoardPage());
      case studentProfilePage:
      //   return MaterialPageRoute(builder: (_) => StudentProfilePage());
      // case teacherNotePage:
      //   return MaterialPageRoute(builder: (_) => TeacherNotePage());
      // case teacherDetailCard:
      //   return MaterialPageRoute(builder: (_) => TeacherDetailCard());
      // case parentProfilePage:
        return MaterialPageRoute(builder: (_) => ParentProfilePage());
      case calenderPage:
      //   return MaterialPageRoute(builder: (_) => CalenderPage());
      // case homework:
        // return MaterialPageRoute(builder: (_) => HomeWorkPage());
    // //   case teacherNoteDeatilPage:


    // case studentActivityPage:
    //   return MaterialPageRoute(builder: (_) => StudentActivityPage());

    //  case calendarPage:
    //    return MaterialPageRoute(builder: (_) => const CalendarPage());
    //    case profilePage:
    //    return MaterialPageRoute(builder: (_) => const ProfilePage());
    // case heritagepage:
    //   return MaterialPageRoute(builder: (_) => const HeritagePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("Page Not Found"),
            ),
          ),
        );
    }
  }
}