// student_page.dart - Clean Student Dashboard with Menu Drawer
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';
import 'navigation_page.dart';

class MyStudent extends StatefulWidget {
  const MyStudent({super.key});

  @override
  State<MyStudent> createState() => _MyStudentState();
}

class _MyStudentState extends State<MyStudent> {
  // ================= STUDENT DATA =================
  String name = '';
  String studentId = '';
  String semester = '';
  String department = '';
  String email = '';
  
  // Other data
  List<Map<String, dynamic>> enrolledCourses = [];
  List<Map<String, dynamic>> attendanceRecords = [];
  List<Map<String, dynamic>> marks = [];
  List<Map<String, dynamic>> recentMaterials = [];
  
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadAllStudentData();
  }

  /// 🔄 Load ALL student data from Supabase
  Future<void> loadAllStudentData() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // 1. Get student basic info
      final studentData = await SupabaseConnector.getStudent();
      
      setState(() {
        name = studentData['name']?.toString() ?? 'Student Name';
        studentId = studentData['student_id']?.toString() ?? '';
        semester = studentData['semester']?.toString() ?? '';
        department = studentData['department']?.toString() ?? '';
        email = studentData['email']?.toString() ?? '';
      });

      // 2. Get enrolled courses
      if (studentId.isNotEmpty) {
        enrolledCourses = await SupabaseConnector.getEnrolledCourses(studentId);
      }

      // 3. Get attendance records
      if (studentId.isNotEmpty) {
        attendanceRecords = await SupabaseConnector.getAttendance(studentId);
        if (attendanceRecords.length > 5) {
          attendanceRecords = attendanceRecords.take(5).toList();
        }
      }

      // 4. Get marks
      if (studentId.isNotEmpty) {
        marks = await SupabaseConnector.getStudentMarks(studentId);
      }

      // 5. Get recent materials
      await loadRecentMaterials(enrolledCourses);

      setState(() => isLoading = false);
    } catch (error) {
      print("Error loading student data: $error");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> loadRecentMaterials(List<Map<String, dynamic>> courses) async {
    recentMaterials = [];
    
    for (var course in courses) {
      final courseCode = course['course_code'];
      final materials = await SupabaseConnector.getCourseMaterials(courseCode);
      if (materials.isNotEmpty) {
        final materialsWithCourse = materials.map((material) {
          return {
            ...material,
            'course_name': course['course_name'],
            'course_code': courseCode,
          };
        }).toList();
        
        recentMaterials.addAll(materialsWithCourse);
      }
    }
    
    recentMaterials.sort((a, b) {
      final dateA = a['created_at']?.toString() ?? '';
      final dateB = b['created_at']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });
    
    if (recentMaterials.length > 3) {
      recentMaterials = recentMaterials.take(3).toList();
    }
  }

  double get overallAttendance {
    if (attendanceRecords.isEmpty) return 0.0;
    
    int totalClasses = attendanceRecords.length;
    int presentCount = attendanceRecords
        .where((record) => record['status'] == 'Present')
        .length;
    
    return totalClasses > 0 ? (presentCount / totalClasses) * 100 : 0.0;
  }

  double get averageMarks {
    if (marks.isEmpty) return 0.0;
    
    double total = 0.0;
    int count = 0;
    
    for (var mark in marks) {
      List<dynamic> markValues = [
        mark['attendance'] ?? 0,
        mark['assignment'] ?? 0,
        mark['ct1'] ?? 0,
        mark['ct2'] ?? 0,
        mark['mid'] ?? 0,
        mark['final_exam'] ?? 0,
      ];
      
      double courseTotal = markValues
          .where((value) => value is num)
          .map((value) => value.toDouble())
          .fold(0.0, (sum, value) => sum + value);
      
      total += courseTotal;
      count++;
    }
    
    return count > 0 ? total / count : 0.0;
  }

  /// Show simple student details dialog
  void _showStudentDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Student Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Student ID', studentId.isEmpty ? 'Not assigned' : studentId),
                const Divider(),
                _buildDetailRow('Full Name', name),
                const Divider(),
                _buildDetailRow('Department', department.isEmpty ? 'Not set' : department),
                const Divider(),
                _buildDetailRow('Semester', semester.isEmpty ? 'Not set' : semester),
                const Divider(),
                _buildDetailRow('Email', email.isEmpty ? 'No email provided' : email),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: loadAllStudentData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu), // 3-line menu icon
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header with student info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentId.isEmpty ? 'ID: Not assigned' : 'ID: $studentId',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Drawer Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Student Details Menu
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text(
                      'Student Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      _showStudentDetails(); // Show details dialog
                    },
                  ),
                  
                  // Settings Menu
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.grey),
                    title: const Text(
                      'Settings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      // Settings page will be added later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadAllStudentData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ================= CLEAN PROFILE HEADER =================
              _buildCleanProfileHeader(),

              // ================= QUICK STATS =================
              _buildQuickStats(),

              // ================= ENROLLED COURSES =================
              _buildEnrolledCourses(),

              // ================= RECENT ACTIVITIES =================
              _buildRecentActivities(),

              // ================= QUICK LINKS =================
              _buildQuickLinks(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Clean profile header - only essential info
  Widget _buildCleanProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 20),

          // Student Name and ID only
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  studentId.isEmpty ? 'ID: Not assigned' : 'ID: $studentId',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Quick info badge - Semester
          if (semester.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Sem $semester',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.school,
            value: enrolledCourses.length.toString(),
            label: 'Courses',
            color: Colors.blue,
          ),
          const SizedBox(width: 15),
          _buildStatCard(
            icon: Icons.percent,
            value: '${overallAttendance.toStringAsFixed(1)}%',
            label: 'Attendance',
            color: Colors.green,
          ),
          const SizedBox(width: 15),
          _buildStatCard(
            icon: Icons.bar_chart,
            value: averageMarks.toStringAsFixed(1),
            label: 'Avg Marks',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrolledCourses() {
    if (enrolledCourses.isEmpty) {
      return _buildEmptySection(
        icon: Icons.school,
        title: 'No Courses Enrolled',
        subtitle: 'You haven\'t enrolled in any courses yet',
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Courses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NavigationPage(initialIndex: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
          ),

          ...enrolledCourses.take(3).map((course) {
            return _buildCourseListItem(course);
          }).toList(),

          if (enrolledCourses.length > 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '+ ${enrolledCourses.length - 3} more courses',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCourseListItem(Map<String, dynamic> course) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.book, color: Colors.blue, size: 24),
      ),
      title: Text(
        course['course_name']?.toString() ?? 'Course',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        course['course_code']?.toString() ?? 'Code',
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NavigationPage(initialIndex: 1),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    final List<Widget> sections = [];

    if (attendanceRecords.isNotEmpty) {
      sections.add(_buildRecentAttendance());
    }

    if (recentMaterials.isNotEmpty) {
      sections.add(_buildRecentMaterials());
    }

    if (marks.isNotEmpty) {
      sections.add(_buildRecentMarks());
    }

    if (sections.isEmpty) {
      return _buildEmptySection(
        icon: Icons.history,
        title: 'No Recent Activity',
        subtitle: 'Activities will appear here',
      );
    }

    return Column(children: sections);
  }

  Widget _buildRecentAttendance() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Recent Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ...attendanceRecords.map((record) {
            return _buildAttendanceItem(record);
          }).toList(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NavigationPage(initialIndex: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text('View Full Attendance'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> record) {
    final status = record['status']?.toString() ?? 'Unknown';
    final date = record['date']?.toString() ?? '';
    final course = record['course_code']?.toString() ?? '';

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.circle;

    if (status == 'Present') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'Absent') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (status == 'Late') {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    }

    return ListTile(
      leading: Icon(statusIcon, color: statusColor),
      title: Text(course),
      subtitle: Text(date),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMaterials() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Recent Materials',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ...recentMaterials.map((material) {
            return _buildMaterialItem(material);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(Map<String, dynamic> material) {
    final type = material['material_type'] ?? 'file';
    final title = material['title'] ?? 'Untitled';
    final course = material['course_name'] ?? material['course_code'] ?? '';
    final date = material['created_at']?.toString().substring(0, 10) ?? '';

    IconData icon;
    Color color;

    switch (type) {
      case 'announcement':
        icon = Icons.announcement;
        color = Colors.green;
        break;
      case 'assignment':
        icon = Icons.assignment;
        color = Colors.orange;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.blue;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('$course • $date'),
      trailing: const Icon(Icons.download, color: Colors.blue),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NavigationPage(initialIndex: 1),
          ),
        );
      },
    );
  }

  Widget _buildRecentMarks() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Recent Marks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ...marks.take(2).map((mark) {
            return _buildMarkItem(mark);
          }).toList(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NavigationPage(initialIndex: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart, size: 16),
                label: const Text('View All Marks'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkItem(Map<String, dynamic> mark) {
    final course = mark['course_code']?.toString() ?? 'Course';
    final total = (mark['final_exam'] ?? 0) +
        (mark['mid'] ?? 0) +
        (mark['ct1'] ?? 0) +
        (mark['ct2'] ?? 0) +
        (mark['assignment'] ?? 0) +
        (mark['attendance'] ?? 0);

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.grade, color: Colors.orange),
      ),
      title: Text(course),
      subtitle: Text('Total Marks: $total'),
      trailing: Text(
        '${(total / 110 * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickLinkButton(
                  icon: Icons.school,
                  label: 'Courses',
                  color: Colors.blue,
                  index: 1,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickLinkButton(
                  icon: Icons.calendar_today,
                  label: 'Attendance',
                  color: Colors.green,
                  index: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildQuickLinkButton(
                  icon: Icons.bar_chart,
                  label: 'Marks',
                  color: Colors.orange,
                  index: 3,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickLinkButton(
                  icon: Icons.download,
                  label: 'Materials',
                  color: Colors.purple,
                  index: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkButton({
    required IconData icon,
    required String label,
    required Color color,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationPage(initialIndex: index),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}