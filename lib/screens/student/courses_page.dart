// courses_page.dart
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class CoursesPage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onCourseSelected;
  
  const CoursesPage({
    super.key,
    this.onCourseSelected,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> filteredCourses = [];
  bool isLoading = true;
  String studentId = '';
  String searchQuery = '';
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Fix 1: Add ScrollController for better scroll handling
  final ScrollController _scrollController = ScrollController();
  
  // Random gradients for variety
  final List<List<Color>> courseGradients = [
    [const Color(0xFF4158D0), const Color(0xFFC850C0)],
    [const Color(0xFF0093E9), const Color(0xFF80D0C7)],
    [const Color(0xFF8EC5FC), const Color(0xFFE0C3FC)],
    [const Color(0xFFFBAB7E), const Color(0xFFF7CE68)],
    [const Color(0xFF85FFBD), const Color(0xFFFFFB7D)],
    [const Color(0xFFA9C9FF), const Color(0xFFFFBBEC)],
    [const Color(0xFFFA8BFF), const Color(0xFF2BD2FF)],
    [const Color(0xFF52E5E7), const Color(0xFF130CB7)],
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    loadStudentCourses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose(); // Fix 2: Dispose controller
    super.dispose();
  }

  Future<void> loadStudentCourses() async {
    try {
      setState(() => isLoading = true);
      final studentData = await SupabaseConnector.getStudent();
      studentId = studentData['student_id'];
      final enrolledCourses = await SupabaseConnector.getEnrolledCourses(studentId);
      
      setState(() {
        courses = enrolledCourses;
        filteredCourses = enrolledCourses;
        isLoading = false;
      });
      
      _animationController.forward();
    } catch (error) {
      print("Error: $error");
      // Fix 3: Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load courses: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => isLoading = false);
      }
    }
  }

  void _filterCourses(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredCourses = courses;
      } else {
        filteredCourses = courses.where((course) {
          final name = course['course_name']?.toString().toLowerCase() ?? '';
          final code = course['course_code']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || code.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // Fix 4: Add resizeToAvoidBottomInset for keyboard
      resizeToAvoidBottomInset: true,
      body: isLoading ? _buildLoadingScreen() : _buildMainContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: courseGradients[0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Fix 5: Add padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated book icon
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Fix 6: Remove ShaderMask for better performance
                const Text(
                  'Loading Your Courses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Preparing your learning journey...',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
                // Progress indicator
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      controller: _scrollController, // Fix 7: Add controller
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Enhanced Header
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          stretch: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: courseGradients[DateTime.now().second % courseGradients.length],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Abstract shapes
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -30,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                // Content
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Courses',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildHeaderChip(
                            icon: Icons.menu_book_rounded,
                            label: '${courses.length} ${courses.length == 1 ? 'Course' : 'Courses'}',
                          ),
                          const SizedBox(width: 10),
                          _buildHeaderChip(
                            icon: Icons.trending_up_rounded,
                            label: 'In Progress',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Search Bar
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          sliver: SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: _filterCourses,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search by course name or code...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 22),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500, size: 20),
                            onPressed: () => _filterCourses(''),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Results count
        if (filteredCourses.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    '${filteredCourses.length} ${filteredCourses.length == 1 ? 'course' : 'courses'} found',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(top: 8)),

        // Fix 8: Use SliverGrid with proper constraints
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          sliver: filteredCourses.isEmpty
              ? SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78, // Adjusted for better card proportions
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildCourseCard(filteredCourses[index], index),
                      );
                    },
                    childCount: filteredCourses.length,
                  ),
                ),
        ),
        
        // Fix 9: Add bottom padding for better scrolling
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 20),
        ),
      ],
    );
  }

  Widget _buildHeaderChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    final gradient = courseGradients[index % courseGradients.length];
    final code = course['course_code']?.toString() ?? 'N/A';
    final name = course['course_name']?.toString() ?? 'Unknown Course';
    
    return GestureDetector(
      onTap: () {
        if (widget.onCourseSelected != null) {
          widget.onCourseSelected!(course);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                ),
              ),
              
              // Decorative circles
              Positioned(
                right: -15,
                top: -15,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course code badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        _shortCourseCode(code),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Icon with subtle animation
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: Duration(milliseconds: 600 + (index * 100)),
                      curve: Curves.elasticOut,
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCourseIcon(code),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 14),
                    
                    // Course name
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Progress indicator
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (index * 0.12) % 1.0,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${((index * 0.12) % 1.0 * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Arrow indicator
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Fix 10: Add padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        size: 70,
                        color: Colors.blue,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                searchQuery.isEmpty ? 'No Courses Yet' : 'No Results Found',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  searchQuery.isEmpty 
                      ? "You haven't enrolled in any courses yet.\nExplore and enroll in new courses!"
                      : 'No courses matching "$searchQuery"',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              // Action button
              if (searchQuery.isNotEmpty)
                ElevatedButton(
                  onPressed: () => _filterCourses(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Clear Search'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _shortCourseCode(String code) {
    if (code.length > 7) {
      return '${code.substring(0, 5)}..';
    }
    return code;
  }

  IconData _getCourseIcon(String code) {
    final upperCode = code.toUpperCase();
    if (upperCode.contains('MATH') || upperCode.contains('MAT')) {
      return Icons.calculate_rounded;
    } else if (upperCode.contains('PHY')) {
      return Icons.science_rounded;
    } else if (upperCode.contains('CSE') || upperCode.contains('CS') || upperCode.contains('COMP')) {
      return Icons.computer_rounded;
    } else if (upperCode.contains('ENG')) {
      return Icons.translate_rounded;
    } else if (upperCode.contains('BUS') || upperCode.contains('ECO') || upperCode.contains('ACCT')) {
      return Icons.trending_up_rounded;
    } else if (upperCode.contains('ART') || upperCode.contains('DES')) {
      return Icons.palette_rounded;
    } else if (upperCode.contains('HIST')) {
      return Icons.history_edu_rounded;
    } else {
      return Icons.menu_book_rounded;
    }
  }
}