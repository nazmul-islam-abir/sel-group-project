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
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final courseCode = widget.course['code'] ?? widget.course['course_code'] ?? '';
      
      if (courseCode.isEmpty) {
        throw Exception('Course code is missing');
      }

      // Get students enrolled in this course
      final enrolledStudents = await SupabaseConnector.getStudentsByCourse(courseCode);
      
      if (enrolledStudents.isEmpty) {
        setState(() {
          students = [];
          isLoading = false;
        });
        return;
      }

      // Initialize all students as 'Present' by default with null safety
      for (var student in enrolledStudents) {
        final studentId = student['student_id']?.toString() ?? 
                         student['id']?.toString() ?? 
                         '';
        
        if (studentId.isNotEmpty) {
          attendanceStatus[studentId] = 'Present';
        }
      }
      
      setState(() {
        students = enrolledStudents;
        isLoading = false;
      });

    } catch (e) {
      print('Error loading students: $e'); // For debugging
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
      final courseCode = widget.course['code'] ?? widget.course['course_code'] ?? '';
      
      if (courseCode.isEmpty) {
        throw Exception('Course code is missing');
      }

      // Prepare attendance records for database with null safety
      final attendanceRecords = students.where((student) {
        final studentId = student['student_id']?.toString() ?? 
                         student['id']?.toString() ?? 
                         '';
        return studentId.isNotEmpty;
      }).map((student) {
        final studentId = student['student_id']?.toString() ?? 
                         student['id']?.toString() ?? 
                         '';
        
        return {
          'student_id': studentId,
          'course_code': courseCode,
          'date': selectedDate.toIso8601String().split('T')[0],
          'status': attendanceStatus[studentId] ?? 'Present',
        };
      }).toList();

      if (attendanceRecords.isEmpty) {
        throw Exception('No valid students to save attendance for');
      }

      // Save to Supabase
      await SupabaseConnector.saveAttendance(attendanceRecords);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Go back after saving
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
    final courseCode = widget.course['code'] ?? widget.course['course_code'] ?? 'Course';
    final courseName = widget.course['name'] ?? widget.course['course_name'] ?? 'Course';

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
            ? _buildEmptyWidget()
            : _buildAttendanceWidget(),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStudents,
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

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No students enrolled in this course',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Course Code: ${widget.course['code'] ?? widget.course['course_code'] ?? 'N/A'}',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceWidget() {
    return Column(
      children: [
        // Course info and date picker
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course['name'] ?? widget.course['course_name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total Students: ${students.length}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
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

        // Legend
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('P', 'Present', Colors.green),
              _buildLegendItem('L', 'Late', Colors.orange),
              _buildLegendItem('A', 'Absent', Colors.red),
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
              final studentId = student['student_id']?.toString() ?? 
                               student['id']?.toString() ?? 
                               '';
              final studentName = student['name']?.toString() ?? 'Unknown Student';
              final currentStatus = attendanceStatus[studentId] ?? 'Present';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Student info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'ID: $studentId',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Status buttons
                      _buildStatusButton('Present', studentId, currentStatus, Colors.green),
                      const SizedBox(width: 4),
                      _buildStatusButton('Late', studentId, currentStatus, Colors.orange),
                      const SizedBox(width: 4),
                      _buildStatusButton('Absent', studentId, currentStatus, Colors.red),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Save button
        Container(
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
                : const Text('SAVE ATTENDANCE', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String letter, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildStatusButton(
    String status,
    String studentId,
    String currentStatus,
    Color color,
  ) {
    final isSelected = currentStatus == status;
    
    return Container(
      margin: const EdgeInsets.only(left: 4),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            attendanceStatus[studentId] = status;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(50, 36),
        ),
        child: Text(
          status == 'Present' ? 'P' : status == 'Late' ? 'L' : 'A',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}