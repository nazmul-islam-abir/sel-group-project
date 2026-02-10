// attendance_page.dart
import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<Map<String, dynamic>> attendance = [];
  bool isLoading = true;
  String selectedCourse = 'All';

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    try {
      final student = await SupabaseConnector.getStudent();
      final studentId = student['student_id']?.toString() ?? '';
      
      attendance = await SupabaseConnector.getAttendance(studentId);
      setState(() => isLoading = false);
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (attendance.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No attendance records'),
            const SizedBox(height: 8),
            const Text('Attendance will be updated after classes'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loadAttendance,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Group attendance by course
    final Map<String, List<Map<String, dynamic>>> attendanceByCourse = {};
    for (var record in attendance) {
      final course = record['course_code']?.toString() ?? 'Unknown';
      attendanceByCourse.putIfAbsent(course, () => []).add(record);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendanceByCourse.length,
      itemBuilder: (context, index) {
        final courseCode = attendanceByCourse.keys.elementAt(index);
        final courseAttendance = attendanceByCourse[courseCode]!;
        return _buildCourseCard(courseCode, courseAttendance);
      },
    );
  }

  Widget _buildCourseCard(String courseCode, List<Map<String, dynamic>> records) {
    // Calculate stats
    int totalClasses = records.length;
    int present = records.where((r) => r['status'] == 'Present').length;
    int absent = records.where((r) => r['status'] == 'Absent').length;
    int late = records.where((r) => r['status'] == 'Late').length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course header
            Text(
              courseCode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Stats
            Row(
              children: [
                _buildStatBox('Total', totalClasses.toString(), Colors.blue),
                _buildStatBox('Present', present.toString(), Colors.green),
                _buildStatBox('Absent', absent.toString(), Colors.red),
                _buildStatBox('Late', late.toString(), Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            
            // Recent attendance
            const Text(
              'Recent Classes:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            ...records.take(5).map((record) {
              return _buildAttendanceRow(record);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(Map<String, dynamic> record) {
    final date = record['date']?.toString() ?? '';
    final status = record['status']?.toString() ?? '';
    final dateFormatted = _formatDate(date);
    
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.circle;
    
    if (status == 'Present') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'Absent') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (status == 'Late') {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(dateFormatted)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Unknown date';
    try {
      // Format: YYYY-MM-DD to DD/MM/YYYY
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }
}