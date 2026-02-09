// course_detail_page.dart
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';
import 'smart_file_handler.dart'; // Add this import

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
  List<Map<String, dynamic>> files = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  Future<void> loadFiles() async {
    setState(() => loading = true);
    files = await SupabaseConnector.getCourseFiles(widget.courseCode);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
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
        
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No files available",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        final fileUrl = file['file_url'] ?? '';
        final fileName = file['file_name'] ?? 'Unknown File';
        
        return Card(
          child: ListTile(
            leading: _getFileIcon(fileUrl, fileName), // Better icon
            title: Text(fileName),
            subtitle: Text(_getFileType(fileUrl)), // Show file type
            trailing: const Icon(Icons.open_in_new),
            // UPDATED: Use SmartFileHandler
            onTap: () {
              SmartFileHandler.openFile(
                context: context,
                fileUrl: fileUrl,
                fileName: fileName,
              );
            },
          ),
        );
      },
    );
  }

  // Helper to show better icons
  Widget _getFileIcon(String url, String name) {
    final lowerUrl = url.toLowerCase();
    final lowerName = name.toLowerCase();
    
    if (lowerUrl.contains('.pdf') || lowerName.contains('.pdf')) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30);
    } else if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg') || 
               lowerUrl.contains('.png') || lowerUrl.contains('.gif') ||
               lowerName.contains('.jpg') || lowerName.contains('.jpeg') || 
               lowerName.contains('.png') || lowerName.contains('.gif')) {
      return const Icon(Icons.image, color: Colors.green, size: 30);
    } else if (lowerUrl.contains('.doc') || lowerName.contains('.doc')) {
      return const Icon(Icons.description, color: Colors.blue, size: 30);
    } else if (lowerUrl.contains('.xls') || lowerName.contains('.xls')) {
      return const Icon(Icons.table_chart, color: Colors.green, size: 30);
    } else {
      return const Icon(Icons.insert_drive_file, color: Colors.grey, size: 30);
    }
  }

  // Helper to show file type
  String _getFileType(String url) {
    final lowerUrl = url.toLowerCase();
    
    if (lowerUrl.contains('.pdf')) return 'PDF Document';
    if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg')) return 'JPEG Image';
    if (lowerUrl.contains('.png')) return 'PNG Image';
    if (lowerUrl.contains('.gif')) return 'GIF Image';
    if (lowerUrl.contains('.doc') || lowerUrl.contains('.docx')) return 'Word Document';
    if (lowerUrl.contains('.xls') || lowerUrl.contains('.xlsx')) return 'Excel Spreadsheet';
    if (lowerUrl.contains('.ppt') || lowerUrl.contains('.pptx')) return 'PowerPoint';
    if (lowerUrl.contains('.txt')) return 'Text File';
    
    return 'File';
  }
}