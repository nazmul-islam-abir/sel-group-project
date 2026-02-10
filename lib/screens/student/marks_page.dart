// marks_page.dart - SIMPLEST VERSION
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  List<Map<String, dynamic>> marks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMarks();
  }

  Future<void> loadMarks() async {
    try {
      final student = await SupabaseConnector.getStudent();
      final studentId = student['student_id']?.toString() ?? '';
      marks = await SupabaseConnector.getStudentMarks(studentId);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (marks.isEmpty) {
      return const Center(
        child: Text('No marks available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: marks.length,
      itemBuilder: (context, index) {
        final mark = marks[index];
        return _buildCourseCard(mark);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> mark) {
    final courseCode = mark['course_code']?.toString() ?? 'Course';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course name
            Text(
              courseCode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Just show marks in simple rows
            _buildRow('Attendance', mark['attendance'], 10),
            _buildRow('Assignment', mark['assignment'], 10),
            _buildRow('CT 1', mark['ct1'], 10),
            _buildRow('CT 2', mark['ct2'], 10),
            _buildRow('Mid Term', mark['mid'], 20),
            _buildRow('Final Exam', mark['final_exam'], 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, dynamic mark, int outOf) {
    // Show '--' if mark is null, otherwise show number
    final markValue = mark?.toString() ?? '--';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          
          // Just show the numbers
          Text(
            '$markValue/$outOf',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}