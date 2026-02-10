// course_detail_page.dart
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

class _CourseDetailPageState extends State<CourseDetailPage> {
  List<Map<String, dynamic>> materials = [];
  bool isLoading = true;
  int selectedTab = 0; // 0=All, 1=Posts, 2=Files, 3=Assignments

  @override
  void initState() {
    super.initState();
    loadMaterials();
  }

  Future<void> loadMaterials() async {
    setState(() => isLoading = true);
    materials = await SupabaseConnector.getCourseMaterials(widget.courseCode);
    setState(() => isLoading = false);
  }

  // Filter materials based on selected tab
  List<Map<String, dynamic>> get filteredMaterials {
    if (selectedTab == 0) return materials; // All
    if (selectedTab == 1) { // Posts (announcements)
      return materials.where((m) => m['material_type'] == 'announcement').toList();
    }
    if (selectedTab == 2) { // Files
      return materials.where((m) => m['material_type'] == 'file').toList();
    }
    if (selectedTab == 3) { // Assignments
      return materials.where((m) => m['material_type'] == 'assignment').toList();
    }
    return materials;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
          color: Colors.blue,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.courseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          color: Colors.grey.shade100,
          child: Row(
            children: [
              _buildTabButton(0, Icons.dashboard, 'All'),
              _buildTabButton(1, Icons.announcement, 'Posts'),
              _buildTabButton(2, Icons.folder, 'Files'),
              _buildTabButton(3, Icons.assignment, 'Assignments'),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildTabButton(int tabIndex, IconData icon, String label) {
    final isSelected = selectedTab == tabIndex;
    return Expanded(
      child: TextButton.icon(
        onPressed: () => setState(() => selectedTab = tabIndex),
        icon: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
          size: 20,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredMaterials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(),
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadMaterials,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMaterials.length,
        itemBuilder: (context, index) {
          final material = filteredMaterials[index];
          return _buildMaterialItem(material);
        },
      ),
    );
  }

  Widget _buildMaterialItem(Map<String, dynamic> material) {
    final type = material['material_type'] ?? 'file';
    final hasFile = material['file_url'] != null && material['file_url'].toString().isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Icon(
                  _getMaterialIcon(type),
                  color: _getMaterialColor(type),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    material['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (type == 'assignment' && material['due_date'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Due: ${_formatDate(material['due_date'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Description (for announcements/assignments)
            if (material['description'] != null && material['description'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  material['description'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),

            // File section (if has file)
            if (hasFile)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(material['file_url']),
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material['file_name'] ?? 'Download',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getFileType(material['file_url']),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () {
                        SmartFileHandler.openFile(
                          context: context,
                          fileUrl: material['file_url'],
                          fileName: material['file_name'] ?? 'file',
                        );
                      },
                    ),
                  ],
                ),
              ),

            // Footer (date and teacher)
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _formatDate(material['created_at']),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Text(
                  material['created_by'] ?? 'Teacher',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper functions
  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'announcement': return Icons.announcement;
      case 'assignment': return Icons.assignment;
      case 'file': return Icons.insert_drive_file;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getMaterialColor(String type) {
    switch (type) {
      case 'announcement': return Colors.green;
      case 'assignment': return Colors.orange;
      case 'file': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getFileIcon(String? url) {
    if (url == null) return Icons.insert_drive_file;
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.pdf')) return Icons.picture_as_pdf;
    if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg') || lowerUrl.contains('.png')) {
      return Icons.image;
    }
    if (lowerUrl.contains('.doc')) return Icons.description;
    if (lowerUrl.contains('.ppt')) return Icons.slideshow;
    return Icons.insert_drive_file;
  }

  String _getFileType(String? url) {
    if (url == null) return 'File';
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.pdf')) return 'PDF';
    if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg')) return 'JPEG Image';
    if (lowerUrl.contains('.png')) return 'PNG Image';
    if (lowerUrl.contains('.doc')) return 'Word Document';
    if (lowerUrl.contains('.ppt')) return 'PowerPoint';
    return 'File';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    try {
      final dateStr = date.toString();
      if (dateStr.length >= 10) {
        return dateStr.substring(0, 10); // Show YYYY-MM-DD
      }
      return dateStr;
    } catch (e) {
      return 'Invalid date';
    }
  }

  IconData _getEmptyIcon() {
    switch (selectedTab) {
      case 0: return Icons.inbox;
      case 1: return Icons.announcement;
      case 2: return Icons.folder_open;
      case 3: return Icons.assignment;
      default: return Icons.inbox;
    }
  }

  String _getEmptyMessage() {
    switch (selectedTab) {
      case 0: return 'No materials yet';
      case 1: return 'No announcements';
      case 2: return 'No files uploaded';
      case 3: return 'No assignments';
      default: return 'No content';
    }
  }
}