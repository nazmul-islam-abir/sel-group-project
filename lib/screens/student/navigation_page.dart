import 'package:flutter/material.dart';
import 'package:myapp/screens/student/marks_page.dart';
import 'package:myapp/screens/student/student_page.dart';
import 'package:myapp/screens/student/courses_page.dart';
import 'package:myapp/screens/student/attendance_page.dart';
import 'navigation_bar.dart';

/// This page controls which screen is shown
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> pages = const [
    MyStudent(),
    CoursesPage(),
    AttendancePage(),
    MarksPage()
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex], // Show selected page
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
