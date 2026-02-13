// teacher_navigation_page.dart
import 'package:flutter/material.dart';

class TeacherNavigationPage extends StatefulWidget {
  final int? initialIndex; // Make it nullable or remove default value
  
  const TeacherNavigationPage({super.key, this.initialIndex}); // Remove default value or make it optional

  @override
  State<TeacherNavigationPage> createState() => _TeacherNavigationPageState();
}

class _TeacherNavigationPageState extends State<TeacherNavigationPage> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex ?? 0; // Use null-aware operator
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Portal"),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              "Welcome Teacher!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Teacher module is under development",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}