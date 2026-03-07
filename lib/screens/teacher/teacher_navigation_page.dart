import 'package:flutter/material.dart';
import 'teacher_courses_page.dart';

class TeacherNavigationPage extends StatefulWidget {
  const TeacherNavigationPage({super.key});

  @override
  State<TeacherNavigationPage> createState() => _TeacherNavigationPageState();
}

class _TeacherNavigationPageState extends State<TeacherNavigationPage> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    const TeacherCoursesPage(), // This will be our main page with all actions
    const Center(child: Text('Profile - Coming Soon')),
    const Center(child: Text('Settings - Coming Soon')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Portal'),
        backgroundColor: Colors.green,
      ),
      body: _pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}