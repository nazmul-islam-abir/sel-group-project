// courses_page.dart
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class CoursesPage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onCourseSelected; // NEW
  
  const CoursesPage({
    super.key,
    this.onCourseSelected, // NEW
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;
  String studentId = '';

  @override
  void initState() {
    super.initState();
    loadStudentCourses();
  }

  Future<void> loadStudentCourses() async {
    try {
      setState(() => isLoading = true);
      final studentData = await SupabaseConnector.getStudent();
      studentId = studentData['student_id'];
      final enrolledCourses = await SupabaseConnector.getEnrolledCourses(studentId);
      setState(() {
        courses = enrolledCourses;
        isLoading = false;
      });
    } catch (error) {
      print("Error: $error");
      setState(() => isLoading = false);
    }
  }

  Future<void> refreshCourses() async {
    await loadStudentCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshCourses,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text("No courses enrolled", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: refreshCourses,
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _buildCourseCard(courses[index]);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.school,
                color: Colors.blue.shade700,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['course_name'] ?? 'Unknown Course',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Code: ${course['course_code'] ?? 'N/A'}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            // UPDATED: Use the callback instead of Navigator
            IconButton(
              onPressed: () {
                if (widget.onCourseSelected != null) {
                  widget.onCourseSelected!(course);
                }
              },
              icon: Icon(Icons.arrow_forward_ios, color: Colors.blue.shade600),
            ),
          ],
        ),
      ),
    );
  }
}