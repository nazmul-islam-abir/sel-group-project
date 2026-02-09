// courses_page.dart
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart'; // Import Supabase connector

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // ================= STATE VARIABLES =================
  List<Map<String, dynamic>> courses = []; // List to store courses
  bool isLoading = true; // Loading state
  String studentId = ''; // To store student ID

  @override
  void initState() {
    super.initState();
    loadStudentCourses(); // Load courses when page opens
  }

  /// 📥 Function to load student's courses from Supabase
  Future<void> loadStudentCourses() async {
    try {
      setState(() {
        isLoading = true; // Show loading
      });

      // Step 1: Get student info to get student_id
      final studentData = await SupabaseConnector.getStudent();
      studentId = studentData['student_id'];

      // Step 2: Get enrolled courses using student_id
      final enrolledCourses = await SupabaseConnector.getEnrolledCourses(studentId);

      // Step 3: Update state with courses
      setState(() {
        courses = enrolledCourses;
        isLoading = false; // Hide loading
      });
    } catch (error) {
      // Handle errors
      print("Error loading courses: $error");
      setState(() {
        isLoading = false; // Hide loading even if error
      });
      
      // Show error message to user (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load courses: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 🔄 Function to refresh courses list
  Future<void> refreshCourses() async {
    await loadStudentCourses(); // Reload data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"), // Page title
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: refreshCourses, // Pull to refresh
        child: _buildBody(), // Build the main content
      ),
    );
  }

  /// 🏗️ Function to build the main content based on state
  Widget _buildBody() {
    if (isLoading) {
      // Show loading indicator
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // Loading spinner
            SizedBox(height: 16),
            Text("Loading your courses..."),
          ],
        ),
      );
    }

    if (courses.isEmpty) {
      // Show empty state
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No courses enrolled",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Check with your department",
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: refreshCourses, // Try again
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    // Show list of courses
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  /// 🎴 Function to build a course card
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
            // Course icon/avatar
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
            
            // Course details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course name
                  Text(
                    course['course_name'] ?? 'Unknown Course',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Course code
                  Text(
                    "Code: ${course['course_code'] ?? 'N/A'}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Additional info (you can add more fields here)
                  if (course['instructor'] != null)
                    Text(
                      "Instructor: ${course['instructor']}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            
            // Optional: More info button
            IconButton(
              onPressed: () {
                // You can add navigation to course details here
                _showCourseDetails(course);
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue.shade600,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ℹ️ Function to show course details (optional)
  void _showCourseDetails(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course['course_name'] ?? 'Course Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Course Code: ${course['course_code'] ?? 'N/A'}"),
            const SizedBox(height: 8),
            if (course['instructor'] != null)
              Text("Instructor: ${course['instructor']}"),
            const SizedBox(height: 8),
            if (course['credits'] != null)
              Text("Credits: ${course['credits']}"),
            const SizedBox(height: 8),
            Text(
              "More details coming soon...",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}