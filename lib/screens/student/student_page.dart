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

  void calculateStats() {
    // Attendance
    if (attendanceRecords.isNotEmpty) {
      int total = attendanceRecords.length;
      int present = attendanceRecords.where((r) => 
        r['status'] == 'Present' || r['status'] == 'Late'
      ).length;
      overallAttendance = total > 0 ? (present / total * 100) : 0.0;

      // Streak
      int streak = 0;
      for (var record in attendanceRecords.take(10)) {
        if (record['status'] == 'Present' || record['status'] == 'Late') {
          streak++;
        } else {
          break;
        }
      }
      attendanceStreak = streak >= 5 ? '🔥 $streak day' :
                        streak >= 3 ? '✨ $streak in row' :
                        streak > 0 ? '📅 $streak cons' : '🎯 Start!';

      // Next class
      final latestAbsent = attendanceRecords.firstWhere(
        (r) => r['status'] == 'Absent',
        orElse: () => {},
      );
      nextClassInfo = latestAbsent.isNotEmpty 
          ? 'Next: ${latestAbsent['course_code'] ?? 'Class'}' 
          : '✅ All caught up!';
    }

    // Marks
    if (marks.isNotEmpty) {
      double total = 0;
      double highest = 0;
      String top = '';

      for (var mark in marks) {
        double courseTotal = 0;
        courseTotal += (mark['attendance'] ?? 0).toDouble();
        courseTotal += (mark['assignment'] ?? 0).toDouble();
        courseTotal += (mark['ct1'] ?? 0).toDouble();
        courseTotal += (mark['ct2'] ?? 0).toDouble();
        courseTotal += (mark['mid'] ?? 0).toDouble();
        courseTotal += (mark['final_exam'] ?? 0).toDouble();

        total += courseTotal;
        if (courseTotal > highest) {
          highest = courseTotal;
          top = mark['course_code'] ?? '';
        }
      }

      averageMarks = marks.isNotEmpty ? total / marks.length : 0.0;
      topPerformingCourse = top.isNotEmpty ? top : 'N/A';
    }

    // Tasks
    pendingTasksCount = todos.where((t) => t['is_completed'] == false).length;
  }

  // ==================== NAVIGATION ====================
  void _openTodoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TodoPage()),
    ).then((_) => loadAllStudentData());
  }

  void _logout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: loadAllStudentData,
        color: currentGradient.first,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ============ FIXED HEADER - NO OVERFLOW ============
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              stretch: true,
              backgroundColor: currentGradient.first,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                // Task badge - FIXED OVERFLOW
                if (pendingTasksCount > 0)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 24),
                        ),
                        onPressed: _openTodoPage,
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              pendingTasksCount > 9 ? '9+' : '$pendingTasksCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: currentGradient,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Abstract shapes
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -40,
                        bottom: -40,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      
                      // Profile content - FIXED OVERFLOW
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar with ring
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: currentGradient.first,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name and badges - USING COLUMN + WRAP FOR BETTER SPACE MANAGEMENT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  // WRAP instead of ROW for badges - FIXES OVERFLOW
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          department.isNotEmpty ? _shortDepartment(department) : 'CSE',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          'Sem $semester',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============ MAIN CONTENT ============
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ============ ATTENDANCE CARD - FIXED OVERFLOW ============
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.grey.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: currentGradient.first.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Row 1: Icon + Stats + Badge - FIXED OVERFLOW
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      currentGradient.first.withOpacity(0.1),
                                      currentGradient.last.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  overallAttendance >= 75 ? Icons.emoji_events_rounded :
                                  overallAttendance >= 60 ? Icons.trending_up_rounded :
                                  Icons.trending_down_rounded,
                                  color: overallAttendance >= 75 ? Colors.amber.shade700 :
                                        overallAttendance >= 60 ? Colors.blue.shade700 :
                                        Colors.orange.shade700,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Stats - Expanded with proper constraints
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Quote row
                                    Row(
                                      children: [
                                        Text(
                                          currentQuote['icon'] ?? '',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            currentQuote['text'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Attendance percentage
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${overallAttendance.toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: overallAttendance >= 75 ? Colors.green.shade700 :
                                                  overallAttendance >= 60 ? Colors.blue.shade700 :
                                                  Colors.orange.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            attendanceStreak,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Total classes badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: currentGradient.first.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${attendanceRecords.length}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: currentGradient.first,
                                      ),
                                    ),
                                    Text(
                                      'classes',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Status bars - FIXED LAYOUT
                          Row(
                            children: [
                              Expanded(child: _buildStatusBar(
                                'Present',
                                attendanceRecords.where((r) => r['status'] == 'Present').length,
                                attendanceRecords.length,
                                Colors.green,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: _buildStatusBar(
                                'Late',
                                attendanceRecords.where((r) => r['status'] == 'Late').length,
                                attendanceRecords.length,
                                Colors.orange,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: _buildStatusBar(
                                'Absent',
                                attendanceRecords.where((r) => r['status'] == 'Absent').length,
                                attendanceRecords.length,
                                Colors.red,
                              )),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Next class info - FIXED LAYOUT
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: currentGradient.first.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: currentGradient.first.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.school_rounded,
                                    color: currentGradient.first,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    nextClassInfo,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 2)),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: currentGradient.first,
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('→', style: TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ============ COURSES & MARKS GRID - FIXED ============
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Courses Card
                      Expanded(
                        child: _buildGlowingCard(
                          icon: Icons.book_rounded,
                          title: 'Courses',
                          count: enrolledCourses.length.toString(),
                          color: Colors.purple,
                          gradient: [Colors.purple.shade50, Colors.purple.shade100.withOpacity(0.3)],
                          child: enrolledCourses.isEmpty
                              ? _buildEmptyState('No courses', Icons.book_outlined)
                              : Column(
                                  children: [
                                    ...enrolledCourses.take(2).map((course) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: _buildCourseTile(course, Colors.purple),
                                    )),
                                    
                                    if (enrolledCourses.length > 2)
                                      Center(
                                        child: TextButton(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 1)),
                                          ),
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            '+${enrolledCourses.length - 2} more',
                                            style: TextStyle(fontSize: 12, color: Colors.purple.shade700),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Marks Card
                      Expanded(
                        child: _buildGlowingCard(
                          icon: Icons.emoji_events_rounded,
                          title: 'Top',
                          count: averageMarks.toStringAsFixed(0),
                          color: Colors.orange,
                          gradient: [Colors.orange.shade50, Colors.orange.shade100.withOpacity(0.3)],
                          child: marks.isEmpty
                              ? _buildEmptyState('No marks', Icons.analytics_outlined)
                              : Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.star_rounded,
                                        size: 32,
                                        color: Colors.amber.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _shortCourseCode(topPerformingCourse),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Best',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.insights_rounded, size: 14, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            averageMarks.toStringAsFixed(0),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ============ TASKS SECTION - FIXED ============
                  if (todos.where((t) => t['is_completed'] == false).isNotEmpty) ...[
                    _buildGlowingCard(
                      icon: Icons.task_alt_rounded,
                      title: 'Tasks',
                      count: '$pendingTasksCount pending',
                      color: Colors.green,
                      gradient: [Colors.green.shade50, Colors.teal.shade50],
                      child: Column(
                        children: [
                          ...todos.where((t) => t['is_completed'] == false).take(3).map((todo) {
                            final dueDate = DateTime.parse(todo['due_date']);
                            final isUrgent = dueDate.difference(DateTime.now()).inDays <= 1;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isUrgent ? Colors.red.shade200 : Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: (isUrgent ? Colors.red : Colors.green).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isUrgent ? Icons.priority_high_rounded : Icons.task_alt_rounded,
                                      color: isUrgent ? Colors.red.shade700 : Colors.green.shade700,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          todo['title'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          _formatDate(dueDate),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isUrgent ? Colors.red.shade700 : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: todo['is_completed'] ?? false,
                                    onChanged: (value) => _toggleTodoComplete(todo['id'], value!),
                                    shape: const CircleBorder(),
                                    activeColor: Colors.green,
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                          Center(
                            child: TextButton.icon(
                              onPressed: _openTodoPage,
                              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                              label: const Text('Manage', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green.shade700,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ============ QUICK ACTIONS ============
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildActionButton(
                            icon: Icons.calendar_month_rounded,
                            label: 'Attendance',
                            color: Colors.blue,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 2)),
                            ),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildActionButton(
                            icon: Icons.book_rounded,
                            label: 'Courses',
                            color: Colors.purple,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 1)),
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildActionButton(
                            icon: Icons.grade_rounded,
                            label: 'Marks',
                            color: Colors.orange,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NavigationPage(initialIndex: 3)),
                            ),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildActionButton(
                            icon: Icons.task_rounded,
                            label: 'Tasks',
                            color: Colors.green,
                            onTap: _openTodoPage,
                          )),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER FUNCTIONS ====================
  
  String _shortDepartment(String dept) {
    if (dept.length > 10) {
      return dept.split(' ').map((e) => e[0]).take(2).join('');
    }
    return dept;
  }

  String _shortCourseCode(String code) {
    if (code.length > 8) {
      return '${code.substring(0, 6)}...';
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
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                Text(
                  _getTimeBasedGreeting(),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading your dashboard...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: currentGradient,
                ),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: currentGradient.first,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'ID: ${studentId.isEmpty ? "N/A" : studentId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildDrawerTile(
                    icon: Icons.task_alt_rounded,
                    label: 'My Tasks',
                    count: pendingTasksCount,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _openTodoPage();
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _showStudentDetails();
                    },
                  ),
                  _buildDrawerTile(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    color: Colors.grey,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Settings coming soon!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 32, indent: 20, endIndent: 20),
                  _buildDrawerTile(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _logout();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
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