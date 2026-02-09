// course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../connectors/supabase_connector.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseCode;
  final String courseName;

  const CourseDetailPage({
    super.key,
    required this.courseCode,
    required this.courseName,
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

  // Simple function to load files
  Future<void> loadFiles() async {
    setState(() => loading = true);
    
    // Get files from Supabase
    files = await SupabaseConnector.getCourseFiles(widget.courseCode);
    
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (files.isEmpty) {
      return Center(
        child: Text("No files available for this course"),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Card(
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(file['file_name'] ?? 'Unknown File'),
            subtitle: Text('Click to view'),
            trailing: Icon(Icons.open_in_new),
            onTap: () => _openFile(file['file_url']),
          ),
        );
      },
    );
  }

  // Simple function to open file
  void _openFile(String url) async {
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot open file: $e")),
      );
    }
  }
}