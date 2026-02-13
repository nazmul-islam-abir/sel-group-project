// home_page.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/student/navigation_page.dart';
import 'package:myapp/screens/teacher/teacher_navigation_page.dart'; // You'll create this

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Academic Management System",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 121, 11, 11),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Student Button
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NavigationPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Student Portal"),
                    SizedBox(width: 20),
                    Icon(Icons.person_3_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Teacher Button
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherNavigationPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Teacher Portal"),
                    SizedBox(width: 20),
                    Icon(Icons.school),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}