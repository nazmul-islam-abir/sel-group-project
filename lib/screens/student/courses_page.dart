// courses_page.dart - SIMPLE, UNIQUE, UNPREDICTABLE
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

class _CoursesPageState extends State<CoursesPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;
  bool hasError = false;
  String studentId = '';
  
  // UNIQUE: Random theme elements
  final List<Color> accentColors = [
    const Color(0xFFFF6B6B), // Coral
    const Color(0xFF4ECDC4), // Mint
    const Color(0xFF45B7D1), // Sky
    const Color(0xFF96CEB4), // Sage
    const Color(0xFFFFEAA7), // Vanilla
    const Color(0xFFD4A5A5), // Dusty rose
  ];
  
  final List<String> courseEmojis = [
    '📘', '📗', '📕', '📙', '📚', '📖', '🔬', '🧪', '💻', '🎨', '🎵', '📐'
  ];
  
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    // UNIQUE: Floating animation for cards
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    loadStudentCourses();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> loadStudentCourses() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });
      
      final studentData = await SupabaseConnector.getStudent();
      studentId = studentData['student_id']?.toString() ?? '';
      
      if (studentId.isNotEmpty) {
        final enrolledCourses = await SupabaseConnector.getEnrolledCourses(studentId);
        setState(() {
          courses = enrolledCourses;
          isLoading = false;
        });
      }
    } catch (error) {
      print("Error: $error");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // UNIQUE: Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UNIQUE: Minimal header with personality
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Simple back button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 22),
                          color: Colors.grey.shade700,
                          onPressed: () => Navigator.pop(context),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      
                      // UNIQUE: Floating emoji instead of title
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '📚',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${courses.length}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Simple refresh button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 22),
                          color: Colors.grey.shade700,
                          onPressed: loadStudentCourses,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // UNIQUE: Unexpected welcome text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRandomGreeting(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCourseMessage(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // UNIQUE: Course list with floating cards
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
          
          // UNIQUE: Loading or error overlay
          if (isLoading || hasError)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: isLoading 
                    ? _buildSimpleLoader()
                    : _buildSimpleError(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (courses.isEmpty && !isLoading && !hasError) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            final color = accentColors[index % accentColors.length];
            final emoji = courseEmojis[index % courseEmojis.length];
            final floatOffset = index.isEven ? _floatAnimation.value : -_floatAnimation.value;
            
            return Transform.translate(
              offset: Offset(0, floatOffset),
              child: _buildUniqueCourseCard(course, color, emoji, index),
            );
          },
        );
      },
    );
  }

  Widget _buildUniqueCourseCard(Map<String, dynamic> course, Color color, String emoji, int index) {
    final courseCode = course['course_code'] ?? 'N/A';
    final courseName = course['course_name'] ?? 'Unknown Course';
    
    // UNIQUE: Random rotation for each card
    final rotation = index % 3 == 0 ? -0.01 : (index % 3 == 1 ? 0.01 : 0.0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Transform.rotate(
        angle: rotation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (widget.onCourseSelected != null) {
                widget.onCourseSelected!(course);
              }
            },
            borderRadius: BorderRadius.circular(24),
            splashColor: color.withOpacity(0.1),
            highlightColor: color.withOpacity(0.05),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: Offset(index.isEven ? 4 : -4, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // UNIQUE: Color accent
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        // UNIQUE: Emoji container with personality
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              index.isEven ? 16 : 24, // UNIQUE: Different shapes
                            ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Course details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                courseCode,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: color,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                courseName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // UNIQUE: Arrow with personality
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            index.isEven 
                                ? Icons.arrow_forward_rounded 
                                : Icons.arrow_outward_rounded, // UNIQUE: Different arrows
                            color: color,
                            size: 20,
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
      ),
    );
  }

  Widget _buildSimpleLoader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // UNIQUE: Custom loader
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 2 * 3.14159),
          duration: const Duration(seconds: 2),
          builder: (context, double value, child) {
            return Transform.rotate(
              angle: value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColors[0].withOpacity(0.2),
                        width: 3,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColors[1].withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: accentColors[2],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          'gathering your courses...',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: accentColors[0].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.signal_cellular_0_bar_outlined,
            size: 40,
            color: Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'oops! connection lost',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'tap to try again',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: loadStudentCourses,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: accentColors[0],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              '↻',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // UNIQUE: Empty state with personality
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: accentColors[1].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              const Text(
                '📭',
                style: TextStyle(fontSize: 60),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'no courses yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'your courses will appear here\nonce you enroll',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            decoration: BoxDecoration(
              color: accentColors[2].withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 18, color: accentColors[2]),
                const SizedBox(width: 8),
                Text(
                  'refresh',
                  style: TextStyle(
                    color: accentColors[2],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRandomGreeting() {
    final greetings = [
      '📖 today\'s reading',
      '🎒 semester lineup',
      '✨ your curriculum',
      '📋 enrolled classes',
      '🎯 this semester',
      '💭 knowledge awaits',
    ];
    return greetings[DateTime.now().second % greetings.length];
  }

  String _getCourseMessage() {
    if (courses.isEmpty) return 'No courses yet';
    if (courses.length == 1) return '1 course loaded';
    if (courses.length < 4) return '${courses.length} courses';
    return '${courses.length} active courses';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _floatController.repeat(reverse: true);
  }
}

// UNIQUE: Custom background painter
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E5E5).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    final random = DateTime.now().millisecond;
    
    // Draw random circles
    for (int i = 0; i < 5; i++) {
      final x = (random * (i + 1)) % size.width;
      final y = (random * (i + 3)) % size.height;
      final radius = 30 + (i * 15);
      
      canvas.drawCircle(
        Offset(x, y),
        radius.toDouble(),
        paint,
      );
    }
    
    // Draw random lines
    for (int i = 0; i < 3; i++) {
      final startX = (random * (i + 2)) % size.width;
      final startY = (random * (i + 4)) % size.height;
      final endX = (random * (i + 6)) % size.width;
      final endY = (random * (i + 8)) % size.height;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}