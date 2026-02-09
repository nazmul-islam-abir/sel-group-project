import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class MyStudent extends StatefulWidget {
  const MyStudent({super.key});

  @override
  State<MyStudent> createState() => _MyStudentState();
}

class _MyStudentState extends State<MyStudent> {
  // ================= STUDENT INFO =================
  String name = '';
  String studentId = '';
  String semester = '';

  // ================= ENROLLED COURSES =================
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    loadStudentData(); // Load data when page opens
  }

  /// 🔄 Load student info + enrolled courses from Supabase
  Future<void> loadStudentData() async {
    // Step 1: Get student basic info
    final studentData = await SupabaseConnector.getStudent();

    // Step 2: Get enrolled courses using student_id
    final enrolledCourses =
        await SupabaseConnector.getEnrolledCourses(
      studentData['student_id'],
    );

    // Step 3: Update UI
    setState(() {
      name = studentData['name'];
      studentId = studentData['student_id'];
      semester = studentData['semester'];
      courses = enrolledCourses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Student Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= PROFILE HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),

                  // Student Name
                  Text(
                    name.isEmpty ? "Loading..." : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Student ID
                  Text(
                    "Student ID: ${studentId.isEmpty ? 'Loading...' : studentId}",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  // Semester
                  Text(
                    "Semester: ${semester.isEmpty ? 'Loading...' : semester}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= ENROLLED COURSES =================
            Container(
              width: MediaQuery.of(context).size.width * 0.92,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enrolled Courses",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // If no courses found
                  if (courses.isEmpty)
                    const Text("No courses enrolled"),

                  // Show list of courses
                  ...courses.map((course) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.book, color: Colors.blue),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['course_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                course['course_code'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= OTHER SECTIONS =================
            infoTile(
              context,
              icon: Icons.picture_as_pdf,
              title: "Course Materials",
              subtitle: "Lecture notes & resources",
            ),

            infoTile(
              context,
              icon: Icons.check_circle,
              title: "Attendance",
              subtitle: "Track class presence",
            ),

            infoTile(
              context,
              icon: Icons.bar_chart,
              title: "Marks Distribution",
              subtitle: "View exam & quiz results",
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= SIMPLE INFO TILE =================
  Widget infoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
