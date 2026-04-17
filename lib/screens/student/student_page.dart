// student_page.dart - FIXED, NO ERRORS
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';
import 'navigation_page.dart';

class MyStudent extends StatefulWidget {
  const MyStudent({super.key});

  @override
  State<MyStudent> createState() => _MyStudentState();
}

class _MyStudentState extends State<MyStudent> {
  // ==================== STUDENT DATA ====================
  Map<String, dynamic> studentInfo = {};
  List<Map<String, dynamic>> enrolledCourses = [];
  List<Map<String, dynamic>> attendanceRecords = [];
  List<Map<String, dynamic>> marks = [];
  List<Map<String, dynamic>> recentMaterials = [];
  
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadAllStudentData();
  }

  // ==================== LOAD REAL DATA ====================
  Future<void> loadAllStudentData() async {
    try {
      setState(() { 
        isLoading = true; 
        hasError = false; 
      });

      studentInfo = await SupabaseConnector.getStudent();
      final studentId = studentInfo['student_id']?.toString() ?? '';

      if (studentId.isNotEmpty) {
        enrolledCourses = await SupabaseConnector.getEnrolledCourses(studentId);
        attendanceRecords = await SupabaseConnector.getAttendance(studentId);
        marks = await SupabaseConnector.getStudentMarks(studentId);
        
        await loadRecentMaterials(enrolledCourses);
      }
      
      setState(() { isLoading = false; });
    } catch (error) {
      print("Error: $error");
      setState(() { 
        isLoading = false; 
        hasError = true; 
        errorMessage = error.toString();
      });
    }
  }

  /// Load recent materials from enrolled courses
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
<<<<<<< HEAD
    
    if (recentMaterials.length > 3) {
      recentMaterials = recentMaterials.take(3).toList();
    }
  }

  /// Calculate overall attendance percentage
  double get overallAttendance {
    if (attendanceRecords.isEmpty) return 0.0;
    
    int totalClasses = attendanceRecords.length;
    int presentCount = attendanceRecords
        .where((record) => record['status'] == 'Present')
        .length;
    
    return (presentCount / totalClasses) * 100;
  }

  /// Calculate average marks
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
          .whereType<num>()
          .map((value) => value.toDouble())
          .fold(0.0, (sum, value) => sum + value);
      
      total += courseTotal;
      count++;
    }
    
    return count > 0 ? total / count : 0.0;
=======
>>>>>>> origin/main
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: loadAllStudentData,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoading();
    }

    if (hasError) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: loadAllStudentData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildQuickStats(),
            _buildEnrolledCourses(),
            _buildRecentActivities(),
            _buildQuickLinks(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading your dashboard...'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: loadAllStudentData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.blue),
          ),
          const SizedBox(height: 15),
          Text(
            studentInfo['name']?.toString() ?? 'Student Name',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'ID: ${studentInfo['student_id']?.toString() ?? 'N/A'}',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip('Semester ${studentInfo['semester']?.toString() ?? 'N/A'}', Icons.school),
              const SizedBox(width: 10),
              _buildInfoChip(studentInfo['department']?.toString() ?? 'Department', Icons.business),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatCard(Icons.school, enrolledCourses.length.toString(), 'Courses', Colors.blue),
          const SizedBox(width: 15),
          _buildStatCard(Icons.percent, '${overallAttendance.toStringAsFixed(1)}%', 'Attendance', Colors.green),
          const SizedBox(width: 15),
          _buildStatCard(Icons.bar_chart, averageMarks.toStringAsFixed(1), 'Avg Marks', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrolledCourses() {
    if (enrolledCourses.isEmpty) {
      return _buildEmptySection(Icons.school, 'No Courses Enrolled', 'You haven\'t enrolled in any courses yet');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 1)));
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
          ),
<<<<<<< HEAD
          ...enrolledCourses.take(3).map((course) => _buildCourseListItem(course)).toList(),
          if (enrolledCourses.length > 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('+ ${enrolledCourses.length - 3} more courses', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
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
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.book, color: Colors.blue, size: 24),
      ),
      title: Text(course['course_name']?.toString() ?? 'Course', style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(course['course_code']?.toString() ?? 'Code', style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 1)));
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
      return _buildEmptySection(Icons.history, 'No Recent Activity', 'Activities will appear here');
    }

    return Column(children: sections);
  }

  Widget _buildRecentAttendance() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Recent Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...attendanceRecords.take(3).map((record) => _buildAttendanceItem(record)).toList(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 2)));
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
        child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w500)),
=======
        ),
>>>>>>> origin/main
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildRecentMaterials() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Recent Materials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...recentMaterials.map((material) => _buildMaterialItem(material)).toList(),
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
      title: Text(title),
      subtitle: Text('$course • $date'),
      trailing: const Icon(Icons.download, color: Colors.blue),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 1)));
      },
    );
  }

  Widget _buildRecentMarks() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Recent Marks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...marks.take(2).map((mark) => _buildMarkItem(mark)).toList(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 3)));
                },
                icon: const Icon(Icons.bar_chart, size: 16),
                label: const Text('View All Marks'),
=======
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.red.shade400, Colors.orange.shade400],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Connection Error',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load your data.\nPlease check your connection.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: loadAllStudentData,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
>>>>>>> origin/main
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
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.grade, color: Colors.orange),
      ),
      title: Text(course),
      subtitle: Text('Total Marks: $total'),
      trailing: Text(
        '${(total / 110 * 100).toStringAsFixed(1)}%',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildQuickLinkButton(Icons.school, 'Courses', Colors.blue, 1)),
              const SizedBox(width: 10),
              Expanded(child: _buildQuickLinkButton(Icons.calendar_today, 'Attendance', Colors.green, 2)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildQuickLinkButton(Icons.bar_chart, 'Marks', Colors.orange, 3)),
              const SizedBox(width: 10),
              Expanded(child: _buildQuickLinkButton(Icons.download, 'Materials', Colors.purple, 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkButton(IconData icon, String label, Color color, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage(initialIndex: index)));
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 15),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          const SizedBox(height: 5),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}