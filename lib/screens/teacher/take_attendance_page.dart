import 'package:flutter/material.dart';
import '../../connectors/supabase_connector.dart';

class TakeAttendancePage extends StatefulWidget {
  final Map<String, dynamic> course;
  
  const TakeAttendancePage({super.key, required this.course});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  List<Map<String, dynamic>> students = [];
  Map<String, String> attendanceStatus = {}; // student_id -> status
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEnrolledStudents();
  }

  Future<void> _loadEnrolledStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final courseCode = widget.course['course_code'] ?? widget.course['code'];
      
      // Get enrolled students using the method from your connector
      final enrolledStudents = await SupabaseConnector.getEnrolledStudents(courseCode);
      
      if (enrolledStudents.isEmpty) {
        setState(() {
          students = [];
          isLoading = false;
        });
        return;
      }
      
      // Initialize all enrolled students as 'Present' by default
      for (var student in enrolledStudents) {
        final studentId = student['student_id']?.toString() ?? '';
        if (studentId.isNotEmpty) {
          attendanceStatus[studentId] = 'Present';
        }
      }
      
      setState(() {
        students = enrolledStudents;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _saveAttendance() async {
    setState(() => isSaving = true);

    try {
      final courseCode = widget.course['course_code'] ?? widget.course['code'];
      
      // Prepare attendance records
      final attendanceRecords = students.map((student) {
        final studentId = student['student_id']?.toString() ?? '';
        return {
          'student_id': studentId,
          'course_code': courseCode,
          'date': selectedDate.toIso8601String().split('T')[0],
          'status': attendanceStatus[studentId] ?? 'Present',
        };
      }).toList();

      // Save to database
      await SupabaseConnector.saveAttendance(attendanceRecords);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseCode = widget.course['course_code'] ?? widget.course['code'] ?? 'Course';
    final courseName = widget.course['course_name'] ?? widget.course['name'] ?? 'Course';

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance - $courseCode'),
        backgroundColor: Colors.green,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : errorMessage != null
          ? _buildErrorWidget()
          : students.isEmpty
            ? _buildEmptyWidget(courseCode)
            : _buildAttendanceWidget(courseName),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading students',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEnrolledStudents,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String courseCode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No students enrolled',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Course: $courseCode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceWidget(String courseName) {
    return Column(
      children: [
        // Header with date picker
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                courseName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                    '${selectedDate.year}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 20),
                    onPressed: _selectDate,
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Student list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student['student_id']?.toString() ?? '';
              final studentName = student['name']?.toString() ?? 'Unknown';
              final currentStatus = attendanceStatus[studentId] ?? 'Present';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'ID: $studentId',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      DropdownButton<String>(
                        value: currentStatus,
                        items: const [
                          DropdownMenuItem(value: 'Present', child: Text('Present')),
                          DropdownMenuItem(value: 'Late', child: Text('Late')),
                          DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              attendanceStatus[studentId] = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('SAVE ATTENDANCE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}