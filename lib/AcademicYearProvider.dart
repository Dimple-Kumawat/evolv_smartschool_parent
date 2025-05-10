import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcademicYearProvider with ChangeNotifier {
  String _academicYear = "";

  String get academic_yr => _academicYear;

  AcademicYearProvider() {
    _loadAcademicYear();
  }

  Future<void> _loadAcademicYear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _academicYear = prefs.getString('academic_year') ?? "";
    notifyListeners();
  }

  void setAcademicYear(String newAcademicYear) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('academic_year', newAcademicYear);
    _academicYear = newAcademicYear;
    notifyListeners();
  }
}