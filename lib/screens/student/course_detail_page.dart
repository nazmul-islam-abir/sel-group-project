// course_detail_page.dart - UNIQUE & UNPREDICTABLE REDESIGN
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';
import 'smart_file_handler.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final VoidCallback onBack;

  const CourseDetailPage({
    super.key,
    required this.courseCode,
    required this.courseName,
    required this.onBack,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> materials = [];
  bool isLoading = true;
  
  // UNIQUE: No traditional tabs - instead use a "mood ring" concept
  String currentMood = 'all'; // all, news, docs, tasks
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  
  // UNIQUE: Random color palette for this course
  late final List<Color> coursePalette;
  final List<List<Color>> palettes = [
    [const Color(0xFF4158D0), const Color(0xFFC850C0), const Color(0xFFFFCC70)], // Cosmic
    [const Color(0xFF0093E9), const Color(0xFF80D0C7), const Color(0xFFE0F2FE)], // Ocean
    [const Color(0xFFFBAB7E), const Color(0xFFF7CE68), const Color(0xFFFFE5B4)], // Sunset
    [const Color(0xFF85FFBD), const Color(0xFFFFFB7D), const Color(0xFFB0FFB0)], // Mint
    [const Color(0xFFA9C9FF), const Color(0xFFFFBBEC), const Color(0xFFD9B0FF)], // Pastel
    [const Color(0xFFFA8BFF), const Color(0xFF2BD2FF), const Color(0xFFB88AFF)], // Neon
  ];

  @override
  void initState() {
    super.initState();
    
    // UNIQUE: Random palette based on course code
    final hash = widget.courseCode.hashCode.abs();
    coursePalette = palettes[hash % palettes.length];
    
    // UNIQUE: Ripple animation for mood selector
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _rippleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeInOut),
    );
    
    loadMaterials();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> loadMaterials() async {
    setState(() => isLoading = true);
    materials = await SupabaseConnector.getCourseMaterials(widget.courseCode);
    setState(() => isLoading = false);
  }

  // UNIQUE: Filter by mood
  List<Map<String, dynamic>> get moodMaterials {
    switch (currentMood) {
      case 'news':
        return materials.where((m) => m['material_type'] == 'announcement').toList();
      case 'docs':
        return materials.where((m) => m['material_type'] == 'file').toList();
      case 'tasks':
        return materials.where((m) => m['material_type'] == 'assignment').toList();
      default:
        return materials;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // UNIQUE: Abstract background
          Positioned.fill(
            child: CustomPaint(
              painter: CourseBackgroundPainter(
                colors: coursePalette,
                seed: widget.courseCode.hashCode,
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // UNIQUE: Floating header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // UNIQUE: Circular back button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 24),
                          color: coursePalette[0],
                          onPressed: widget.onBack,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // UNIQUE: Course code as floating badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: coursePalette[0].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: coursePalette[0].withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.courseCode,
                                style: TextStyle(
                                  color: coursePalette[0],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // UNIQUE: Course name with character limit
                            Text(
                              widget.courseName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // UNIQUE: Mood ring selector
                      GestureDetector(
                        onTap: () => _showMoodRing(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: coursePalette[1].withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _rippleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _rippleAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        coursePalette[1],
                                        coursePalette[2],
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getMoodIcon(currentMood),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // UNIQUE: Mood indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        _getMoodText(currentMood),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Content area
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
          
          // UNIQUE: Loading overlay
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: _buildDreamyLoader(),
              ),
            ),
        ],
      ),
    );
  }

  // UNIQUE: Mood ring dialog
  void _showMoodRing() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: coursePalette[0].withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'how do you feel?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodOption('all', Icons.dashboard_rounded, 'overview'),
                    _buildMoodOption('news', Icons.campaign_rounded, 'news'),
                    _buildMoodOption('docs', Icons.folder_rounded, 'docs'),
                    _buildMoodOption('tasks', Icons.task_alt_rounded, 'tasks'),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text('close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOption(String mood, IconData icon, String label) {
    final isSelected = currentMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() => currentMood = mood);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(colors: [coursePalette[0], coursePalette[1]])
                  : null,
              color: isSelected ? null : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? coursePalette[0] : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (moodMaterials.isEmpty && !isLoading) {
      return _buildDreamyEmptyState();
    }

    return RefreshIndicator(
      onRefresh: loadMaterials,
      color: coursePalette[0],
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: moodMaterials.length,
        itemBuilder: (context, index) {
          final material = moodMaterials[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDreamyMaterialCard(material, index),
          );
        },
      ),
    );
  }

  Widget _buildDreamyMaterialCard(Map<String, dynamic> material, int index) {
    final type = material['material_type'] ?? 'file';
    final hasFile = material['file_url'] != null && material['file_url'].toString().isNotEmpty;
    final isEven = index.isEven;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(
        left: isEven ? 0 : 20,
        right: isEven ? 20 : 0,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasFile ? () => _openMaterial(material) : null,
          borderRadius: BorderRadius.circular(24),
          splashColor: coursePalette[0].withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: coursePalette[index % coursePalette.length].withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(isEven ? 4 : -4, 6),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // UNIQUE: Color accent based on type
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: isEven ? 0 : null,
                  right: isEven ? null : 0,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: _getMaterialColor(type),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(isEven ? 24 : 0),
                        right: Radius.circular(isEven ? 0 : 24),
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with type badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getMaterialColor(type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getMaterialIcon(type),
                                  color: _getMaterialColor(type),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getMaterialLabel(type),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getMaterialColor(type),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // UNIQUE: Floating timestamp
                          Text(
                            _getRelativeTime(material['created_at']),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Title
                      Text(
                        material['title'] ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      
                      // Description
                      if (material['description'] != null && material['description'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            material['description'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      // File preview
                      if (hasFile)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getMaterialColor(type).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getMaterialColor(type).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getFileIcon(material['file_url']),
                                    color: _getMaterialColor(type),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        material['file_name'] ?? 'Attachment',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _getFileSize(material),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: _getMaterialColor(type),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                                    onPressed: () => _downloadFile(material),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Due date for assignments
                      if (type == 'assignment' && material['due_date'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_rounded, color: Colors.orange.shade700, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'due ${_formatDate(material['due_date'])}',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Teacher info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              (material['created_by'] ?? 'T')[0],
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            material['created_by'] ?? 'Instructor',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
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
        ),
      ),
    );
  }

  Widget _buildDreamyLoader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 2 * 3.14159),
              duration: const Duration(seconds: 3),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: coursePalette[0].withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Inner ring
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 2 * 3.14159, end: 0),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: value,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: coursePalette[1].withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Center dot
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [coursePalette[0], coursePalette[1]],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'gathering materials...',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDreamyEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: coursePalette[0].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                _getEmptyEmoji(currentMood),
                style: const TextStyle(fontSize: 50),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _getEmptyMessage(currentMood),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptySuggestion(currentMood),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: loadMaterials,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [coursePalette[0], coursePalette[1]],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'refresh',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions
 IconData _getMoodIcon(String mood) {
  switch (mood) {
    case 'news':
      return Icons.campaign_rounded;
    case 'docs':
      return Icons.folder_rounded;
    case 'tasks':
      return Icons.task_alt_rounded;
    default:
      return Icons.dashboard_rounded;
  }
}


  String _getMoodText(String mood) {
    switch (mood) {
      case 'news': return '📢 latest news';
      case 'docs': return '📁 documents';
      case 'tasks': return '✅ tasks & assignments';
      default: return '✨ everything';
    }
  }

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'announcement': return Icons.campaign_rounded;
      case 'assignment': return Icons.task_alt_rounded;
      case 'file': return Icons.insert_drive_file_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }

  Color _getMaterialColor(String type) {
    switch (type) {
      case 'announcement': return const Color(0xFF4CAF50);
      case 'assignment': return const Color(0xFFFF9800);
      case 'file': return const Color(0xFF2196F3);
      default: return Colors.grey;
    }
  }

  String _getMaterialLabel(String type) {
    switch (type) {
      case 'announcement': return 'ANNOUNCEMENT';
      case 'assignment': return 'ASSIGNMENT';
      case 'file': return 'FILE';
      default: return 'MATERIAL';
    }
  }

  IconData _getFileIcon(String? url) {
    if (url == null) return Icons.insert_drive_file_rounded;
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.pdf')) return Icons.picture_as_pdf_rounded;
    if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg') || lowerUrl.contains('.png')) {
      return Icons.image_rounded;
    }
    if (lowerUrl.contains('.doc')) return Icons.description_rounded;
    if (lowerUrl.contains('.ppt')) return Icons.slideshow_rounded;
    return Icons.insert_drive_file_rounded;
  }

  String _getFileSize(Map<String, dynamic> material) {
    // This would come from your backend
    return '~2.4 MB';
  }

  String _getRelativeTime(dynamic date) {
    if (date == null) return 'recent';
    try {
      final dateStr = date.toString();
      return 'just now'; // Simplified
    } catch (e) {
      return 'recent';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      final dateStr = date.toString();
      if (dateStr.length >= 10) {
        final parts = dateStr.substring(0, 10).split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}'; // DD/MM format
        }
      }
      return dateStr;
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getEmptyEmoji(String mood) {
    switch (mood) {
      case 'news': return '📭';
      case 'docs': return '📂';
      case 'tasks': return '✅';
      default: return '📦';
    }
  }

  String _getEmptyMessage(String mood) {
    switch (mood) {
      case 'news': return 'no news yet';
      case 'docs': return 'no documents';
      case 'tasks': return 'all done!';
      default: return 'empty space';
    }
  }

  String _getEmptySuggestion(String mood) {
    switch (mood) {
      case 'news': return 'check back later for updates';
      case 'docs': return 'materials will appear here';
      case 'tasks': return 'no pending assignments';
      default: return 'nothing to see here';
    }
  }

  void _openMaterial(Map<String, dynamic> material) {
    if (material['file_url'] != null) {
      SmartFileHandler.openFile(
        context: context,
        fileUrl: material['file_url'],
        fileName: material['file_name'] ?? 'file',
      );
    }
  }

  void _downloadFile(Map<String, dynamic> material) {
    SmartFileHandler.openFile(
      context: context,
      fileUrl: material['file_url'],
      fileName: material['file_name'] ?? 'file',
    );
  }
}

// UNIQUE: Custom background painter
class CourseBackgroundPainter extends CustomPainter {
  final List<Color> colors;
  final int seed;

  CourseBackgroundPainter({required this.colors, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = seed;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 8; i++) {
      paint.color = colors[i % colors.length].withOpacity(0.1);
      
      final x = (random * (i + 1) * 100) % size.width;
      final y = (random * (i + 2) * 100) % size.height;
      final radius = 40 + (i * 20);
      
      canvas.drawCircle(
        Offset(x, y),
        radius.toDouble(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}