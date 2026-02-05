import 'package:flutter/material.dart';

class MyStudent extends StatelessWidget {
  const MyStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [

              const SizedBox(height: 20),

              studentBox(
                context: context,
                title: "Student ID: 221-15-1234\nSemester: Spring 2025",
                icon: Icons.person,
                colors: [Colors.blueGrey, Colors.blue],
              ),

              const SizedBox(height: 30),

              studentBox(
                context: context,
                title: "Enrolled Courses",
                icon: Icons.menu_book,
                colors: [Colors.black, Colors.deepPurple],
              ),

              const SizedBox(height: 20),

              studentBox(
                context: context,
                title: "Course Materials",
                icon: Icons.picture_as_pdf,
                colors: [Colors.teal, Colors.green],
              ),

              const SizedBox(height: 20),

              studentBox(
                context: context,
                title: "Attendance",
                icon: Icons.check_circle,
                colors: [Colors.orange, Colors.deepOrange],
              ),

              const SizedBox(height: 20),

              studentBox(
                context: context,
                title: "Marks Distribution",
                icon: Icons.bar_chart,
                colors: [Colors.red, Colors.redAccent],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Widget studentBox({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<Color> colors,
}) {
  return Container(
    width: MediaQuery.of(context).size.width * .9,
    height: 120,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.topRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.2),
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
