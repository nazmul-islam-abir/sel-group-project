// student_page.dart - FIXED, NO OVERFLOW ERRORS
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';
import 'navigation_page.dart';
import 'todo_page.dart';

class MyStudent extends StatefulWidget {
  const MyStudent({super.key});

  @override
  State<MyStudent> createState() => _MyStudentState();
}

class _MyStudentState extends State<MyStudent> with SingleTickerProviderStateMixin {
  // ==================== STUDENT DATA ====================
  String name = '';
  String studentId = '';
  String semester = '';
  String department = '';
  String email = '';
  
  // REAL DATA
  List<Map<String, dynamic>> enrolledCourses = [];
  List<Map<String, dynamic>> attendanceRecords = [];
  List<Map<String, dynamic>> marks = [];
  List<Map<String, dynamic>> todos = [];
  
  // DYNAMIC CALCULATIONS
  int pendingTasksCount = 0;
  double overallAttendance = 0.0;
  double averageMarks = 0.0;
  String topPerformingCourse = '';
  String weakestCourse = '';
  String attendanceStreak = '';
  String nextClassInfo = '';
  
  // UI STATES
  bool isLoading = true;
  bool hasError = false;
  late AnimationController _animationController;
  
  // RANDOM ELEMENTS
  final List<List<Color>> headerGradients = [
    [const Color(0xFF4158D0), const Color(0xFFC850C0)],
    [const Color(0xFF0093E9), const Color(0xFF80D0C7)],
    [const Color(0xFF8EC5FC), const Color(0xFFE0C3FC)],
    [const Color(0xFFFBAB7E), const Color(0xFFF7CE68)],
    [const Color(0xFF85FFBD), const Color(0xFFFFFB7D)],
    [const Color(0xFFA9C9FF), const Color(0xFFFFBBEC)],
    [const Color(0xFFFA8BFF), const Color(0xFF2BD2FF)],
  ];
  
  final List<Map<String, String>> quotes = [
    {'icon': '📚', 'text': 'Keep learning,'},
    {'icon': '⚡', 'text': 'Power level:'},
    {'icon': '🎯', 'text': 'Target:'},
    {'icon': '💫', 'text': 'Progress:'},
    {'icon': '🌟', 'text': 'Top:'},
  ];

  List<Color> currentGradient = [Colors.blue, Colors.purple];
  Map<String, String> currentQuote = {};

  @override
  void initState() {
    super.initState();
    _randomizeTheme();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    loadAllStudentData();
  }

  void _randomizeTheme() {
    setState(() {
      currentGradient = (headerGradients..shuffle()).first;
      currentQuote = (quotes..shuffle()).first;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==================== LOAD REAL DATA ====================
  Future<void> loadAllStudentData() async {
    try {
      setState(() { 
        isLoading = true; 
        hasError = false; 
      });

      final studentData = await SupabaseConnector.getStudent();
      
      setState(() {
        name = studentData['name']?.toString() ?? 'Student';
        studentId = studentData['student_id']?.toString() ?? '';
        semester = studentData['semester']?.toString() ?? '';
        department = studentData['department']?.toString() ?? '';
        email = studentData['email']?.toString() ?? '';
      });

      if (studentId.isNotEmpty) {
        enrolledCourses = await SupabaseConnector.getEnrolledCourses(studentId);
        attendanceRecords = await SupabaseConnector.getAttendance(studentId);
        marks = await SupabaseConnector.getStudentMarks(studentId);
        todos = await SupabaseConnector.getMyTodos(studentId);
        
        calculateStats();
      }

      _animationController.forward();
      
      setState(() { isLoading = false; });
    } catch (error) {
      print("Error: $error");
      setState(() { isLoading = false; hasError = true; });
    }
  }

  /// Load recent materials from enrolled courses
  Future<void> loadRecentMaterials(List<Map<String, dynamic>> courses) async {
    recentMaterials = [];
    
    for (var course in courses) {
      final courseCode = course['course_code'];
      final materials = await SupabaseConnector.getCourseMaterials(courseCode);
      if (materials.isNotEmpty) {
        // Add course name to each material
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
    
    // Sort by date and take only 3 most recent
    recentMaterials.sort((a, b) {
      final dateA = a['created_at']?.toString() ?? '';
      final dateB = b['created_at']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });
    
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
      // Sum all available marks
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

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    if (hasError) {
      return _buildErrorScreen();
    }

    return RefreshIndicator(
      onRefresh: loadAllStudentData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // ================= PROFILE HEADER =================
            _buildProfileHeader(),

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
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Loading your dashboard...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
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
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 15),

          // Student Name
          Text(
            studentInfo['name']?.toString() ?? 'Student Name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),

          // Student ID
          Text(
            'ID: ${studentInfo['student_id']?.toString() ?? 'N/A'}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),

          // Semester & Department
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                'Semester ${studentInfo['semester']?.toString() ?? 'N/A'}',
                Icons.school,
              ),
              const SizedBox(width: 10),
              _buildInfoChip(
                studentInfo['department']?.toString() ?? 'Department',
                Icons.business,
              ),
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
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
          // Courses Stat
          _buildStatCard(
            icon: Icons.school,
            value: enrolledCourses.length.toString(),
            label: 'Courses',
            color: Colors.blue,
          ),
          const SizedBox(width: 15),

          // Attendance Stat
          _buildStatCard(
            icon: Icons.percent,
            value: '${overallAttendance.toStringAsFixed(1)}%',
            label: 'Attendance',
            color: Colors.green,
          ),
          const SizedBox(width: 15),

          // Marks Stat
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
            Icon(
              icon,
              size: 30,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
          // Header with View All button
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

          // Courses List (limited to 3)
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
        child: const Icon(
          Icons.book,
          color: Colors.blue,
          size: 24,
        ),
      ),
      title: Text(
        course['course_name']?.toString() ?? 'Course',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
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

    // Add attendance section
    if (attendanceRecords.isNotEmpty) {
      sections.add(_buildRecentAttendance());
    }

    // Add materials section
    if (recentMaterials.isNotEmpty) {
      sections.add(_buildRecentMaterials());
    }

    // Add marks section
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
    return code;
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: currentGradient,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Container(
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

  Widget _buildDrawerTile({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    int? count,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: count != null && count > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          : const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      onTap: onTap,
      minLeadingWidth: 0,
    );
  }

  Widget _buildGlowingCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
    required List<Color> gradient,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
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

  Widget _buildCourseTile(Map<String, dynamic> course, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              course['course_code']?.toString().substring(0, 3) ?? 'CSE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _shortCourseName(course['course_name'] ?? 'Course'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                course['course_code'] ?? '',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _shortCourseName(String name) {
    if (name.length > 20) {
      return '${name.substring(0, 18)}...';
    }
    return name;
  }

  Widget _buildStatusBar(String label, int count, int total, Color color) {
    double percentage = total > 0 ? (count / total * 100) : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.all(20),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileDetailTile('Name', name, Icons.badge_rounded),
            _buildProfileDetailTile('ID', studentId, Icons.qr_code_scanner_rounded),
            _buildProfileDetailTile('Department', department, Icons.school_rounded),
            _buildProfileDetailTile('Semester', semester, Icons.grade_rounded),
            _buildProfileDetailTile('Email', email, Icons.email_rounded),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailTile(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : 'Not set',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTodoComplete(int id, bool value) async {
    await SupabaseConnector.markTodoCompleted(id, value);
    await loadAllStudentData();
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }
}