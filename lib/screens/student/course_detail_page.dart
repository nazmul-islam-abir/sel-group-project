// course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../connectors/supabase_connector.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseCode;
  final String courseName;
  final VoidCallback onBack; // To go back to courses list

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
    
    // Create a simple course_files table in Supabase first
    // Table structure: id, course_code, file_name, file_url
    files = await SupabaseConnector.getCourseFiles(widget.courseCode);
    
    setState(() => loading = false);
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
        
        // Course content
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
            const SizedBox(height: 8),
            Text("Check back later for materials"),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(file['file_name'] ?? 'Unknown File'),
            subtitle: const Text('Click to view'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openFile(file['file_url']),
          ),
        );
      },
    );
  }

  void _openFile(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot open file")),
      );
    }
  }
}