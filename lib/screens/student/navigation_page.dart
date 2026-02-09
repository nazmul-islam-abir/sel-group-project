// navigation_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/student/marks_page.dart';
import 'package:myapp/screens/student/student_page.dart';
import 'package:myapp/screens/student/courses_page.dart';
import 'package:myapp/screens/student/attendance_page.dart';
import 'package:myapp/screens/student/course_detail_page.dart';
import 'base_page.dart'; // Add this

class NavigationPage extends StatefulWidget {
  final int initialIndex;
  const NavigationPage({super.key,
  this.initialIndex = 0,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int selectedIndex = 0;
  
  // To track if we're in course details
  bool showingDetails = false;
  Map<String, dynamic>? selectedCourse;
   @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex; // Set initial tab
  }

  void onItemTapped(int index) {
    // If clicking courses tab while in details, go back to list
    if (index == 1 && showingDetails) {
      setState(() {
        showingDetails = false;
        selectedCourse = null;
      });
      return;
    }
    
    // Normal navigation
    setState(() {
      selectedIndex = index;
      showingDetails = false;
      selectedCourse = null;
    });
  }

  // Function to open course details
  void openCourseDetails(Map<String, dynamic> course) {
    setState(() {
      showingDetails = true;
      selectedCourse = course;
      selectedIndex = 1; // Stay on courses tab
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current page
    Widget currentPage;
    
    if (showingDetails && selectedCourse != null) {
      // Show course details
      currentPage = CourseDetailPage(
        courseCode: selectedCourse!['course_code'],
        courseName: selectedCourse!['course_name'],
        onBack: () {
          setState(() {
            showingDetails = false;
            selectedCourse = null;
          });
        },
      );
    } else {
      // Show normal pages
      switch (selectedIndex) {
        case 0:
          currentPage = const MyStudent();
          break;
        case 1:
          currentPage = CoursesPage(onCourseSelected: openCourseDetails);
          break;
        case 2:
          currentPage = const AttendancePage();
          break;
        case 3:
          currentPage = const MarksPage();
          break;
        default:
          currentPage = const MyStudent();
      }
    }

    return BasePage(
      child: currentPage,
      currentIndex: selectedIndex,
      onNavItemTapped: onItemTapped,
    );
  }
}