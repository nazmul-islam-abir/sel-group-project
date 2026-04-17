import 'package:flutter/material.dart';
import 'teacher_profile_page.dart';
import 'teacher_courses_page.dart';
import 'teacher_attendance_page.dart';
import 'teacher_marks_page.dart';
import 'teacher_upload_page.dart';
import 'teacher_base_page.dart';

class TeacherNavigationPage extends StatefulWidget {
  final int initialIndex;
  const TeacherNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<TeacherNavigationPage> createState() => _TeacherNavigationPageState();
}

class _TeacherNavigationPageState extends State<TeacherNavigationPage> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    
    switch (selectedIndex) {
      case 0:
        currentPage = const TeacherProfilePage();
        break;
      case 1:
        currentPage = const TeacherCoursesPage();
        break;
      case 2:
        currentPage = const TeacherAttendancePage();
        break;
      case 3:
        currentPage = const TeacherMarksPage();
        break;
      case 4:
        currentPage = const TeacherUploadPage();
        break;
      default:
        currentPage = const TeacherProfilePage();
    }

    return TeacherBasePage(
      currentIndex: selectedIndex,
      onNavItemTapped: onItemTapped,
      child: currentPage,
    );
  }
}